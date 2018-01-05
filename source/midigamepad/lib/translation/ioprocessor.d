/++
    This file is part of MIDI GamePad.
    Copyright (c) 2017 0xEAB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 +/
module midigamepad.lib.translation.ioprocessor;

import core.sys.windows.mmsystem;
import core.thread;

import dplug.client.midi;

import midigamepad.lib.midi;

public import midigamepad.lib.midi.device;
public import midigamepad.lib.keyboard;
public import midigamepad.lib.translation.mapping;

/++
    Stops the IO processor based on the passed data.
    This will also stop the keyboard simulator thread.
 +/
bool haltIOProcessor(IOProcessorData pcd)
{
    if (pcd.keyboardSynthesizerLoopMgr.isRunning)
        pcd.keyboardSynthesizerLoopMgr.stop();

    return (closeMIDIInputDevice(pcd.deviceHandle) == MMSYSERR_NOERROR);
}

/++
    Bootstraps the specified MIDI input device,
    start the keyboard simulator thread,
    and enables the translation of MIDI input to keystrokes

    Returns: success = true
 +/
bool runIOProcessor(MIDIDeviceInfo di, IOProcessorData* pcd, out HMIDIIN handle)
in
{
    assert(di.type == MIDIDeviceType.input);
}
body
{
    if (!bootstrapMIDIInputDevice(di, &midigamepadProcessMIDIIn, handle, cast(size_t)(pcd)))
    {
        // initalization failure
        return false;
    }

    pcd.deviceHandle = handle;

    pcd.keyboardSynthesizerLoopMgr.tryStart();
    return true;
}

/++
    Data and config used by the IO processor
 +/
struct IOProcessorData
{
@nogc nothrow pure @safe:

    private
    {
        HMIDIIN _deviceHandle;
        KeyboardSynthesizerLoopMgr _keyboardSynthesizerLoopMgr;
        MappingsCollection _mappings;

    }

    /++
        ctor
     +/
    this(KeyboardSynthesizerLoopMgr keyboardSynthesizerLoopMgr, MappingsCollection mappings)
    {
        this._keyboardSynthesizerLoopMgr = keyboardSynthesizerLoopMgr;
        this._mappings = mappings;
    }

    /++
        Keyboard simulator to use
     +/
    @property KeyboardSynthesizerLoopMgr keyboardSynthesizerLoopMgr()
    {
        return this._keyboardSynthesizerLoopMgr;
    }

    /++
        MIDI input to keyboard mappings
     +/
    @property MappingsCollection mappings()
    {
        return this._mappings;
    }

    @property
    {
        /++
            OS handle for the MIDI input device
         +/
        HMIDIIN deviceHandle()
        {
            return this._deviceHandle;
        }

        protected void deviceHandle(HMIDIIN deviceHandle)
        {
            this._deviceHandle = deviceHandle;
        }
    }
}

private
{
    extern (Windows) void midigamepadProcessMIDIIn(HMIDIIN, uint msgType,
            size_t callbackData, size_t msgParam1, size_t)
    {
        auto pcd = cast(IOProcessorData*)(callbackData);

        switch (msgType)
        {
        case MIM_DATA:
            immutable auto msg = parseMIMDATA(msgParam1);
            switch (msg.status)
            {
            case MidiStatus.noteOn:
                {
                    if (msg.noteVelocity == 0)
                        goto case MidiStatus.noteOff;

                    foreach (NoteOnOffMapping mp; pcd.mappings.noteOnOff)
                    {
                        if (mp.noteNumber == msg.noteNumber)
                        {
                            pcd.keyboardSynthesizerLoopMgr.press(mp);
                        }
                    }

                    break;
                }

            case MidiStatus.noteOff:
                {
                    foreach (NoteOnOffMapping mp; pcd.mappings.noteOnOff)
                    {
                        if (mp.noteNumber == msg.noteNumber)
                        {
                            pcd.keyboardSynthesizerLoopMgr.tryRelease(mp);
                        }
                    }
                    break;
                }

            default:
                break;
            }
            break;

        default:
            break;
        }
    }
}
