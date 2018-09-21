/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
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
