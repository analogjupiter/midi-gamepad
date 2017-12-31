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
module midigamepad.lib.midi.input;

import core.sys.windows.windef : LOBYTE, LOWORD, HIBYTE, HIWORD;
import core.sys.windows.mmsystem;
import std.conv : to;

import midigamepad.lib.util;

public import dplug.client.midi : MidiMessage;
public import midigamepad.lib.midi.device : MIDIDeviceInfo, MIDIDeviceType;
public import core.sys.windows.mmsystem : MIDIINCAPS, MMRESULT;

/++
    Opens a handle for the specified MIDI input device and starts it

    Returns:
        true on success
 +/
bool bootstrapMIDIInputDevice(uint deviceID, MidiInProc callback,
        out HMIDIIN handle, size_t callbackData = 0) @nogc nothrow
{
    if (openMIDIInputDevice(deviceID, callback, handle, callbackData) != MMSYSERR_NOERROR)
        return false;

    return startMIDIInputDevice(handle);
}

/++ ditto +/
bool bootstrapMIDIInputDevice(MIDIDeviceInfo di, MidiInProc callback,
        out HMIDIIN handle, size_t callbackData = 0) @nogc nothrow
{
    return bootstrapMIDIInputDevice(di.id, callback, handle, callbackData);
}

/++
    Disposes the specified MIDI input device

    Returns:
        MMSYSERR_NOERROR on success
 +/
MMRESULT closeMIDIInputDevice(HMIDIIN handle)
{
    return midiInClose(handle);
}


/++
    Returns: All connected MIDI input devices
 +/
MIDIDeviceInfo[] getAllMIDIInputDevices()
{
    const uint count = getMIDIInputDevicesCount();
    MIDIDeviceInfo[] output = new MIDIDeviceInfo[count];

    for (uint i = 0; i < count; i++)
    {
        output[i] = getMIDIInputDeviceInfo(i);
    }

    return output;
}

/++
    Returns: the count of connected MIDI input devices
 +/
uint getMIDIInputDevicesCount() @nogc nothrow
{
    return midiInGetNumDevs();
}

/++
    Returns: the name of the given MIDI input device
 +/
string getMIDIInputDeviceName(MIDIINCAPS caps) pure @safe
{
    return caps.szPname.trimEndNull.to!string;
}

/++
    Returns: the device info of the specified MIDI input device
 +/
MIDIDeviceInfo getMIDIInputDeviceInfo(uint deviceID)
{
    MIDIINCAPS caps = getWinDeviceInfo(deviceID);
    auto output = MIDIDeviceInfo(caps.getMIDIInputDeviceName(), deviceID, MIDIDeviceType.input);

    return output;
}

/++
    Returns: the capabilities of the specified MIDI input device
 +/
MIDIINCAPS getWinDeviceInfo(uint deviceID) @nogc nothrow
{
    MIDIINCAPS capabilities = MIDIINCAPS();

    MMRESULT rslt;
    if ((rslt = midiInGetDevCaps(deviceID, &capabilities, MIDIINCAPS.sizeof)) == MMSYSERR_NOERROR)
    {
        return capabilities;
    }
    else
    {
        switch (rslt)
        {
        case MMSYSERR_BADDEVICEID:
            assert(0, MMSYSERR_BADDEVICEID.stringof);

        case MMSYSERR_INVALPARAM:
            assert(0, MMSYSERR_INVALPARAM.stringof);

        case MMSYSERR_NODRIVER:
            assert(0, MMSYSERR_NODRIVER.stringof);

        case MMSYSERR_NOMEM:
            assert(0, MMSYSERR_NOMEM.stringof);

        default:
            assert(0);
        }
    }
}

extern (Windows) alias MidiInProc = void function(HMIDIIN, uint, size_t, size_t, size_t);

/++
    Opens a handle for the specified MIDI input device

    Returns:
        MMSYSERR_NOERROR on success
 +/
MMRESULT openMIDIInputDevice(uint deviceID, MidiInProc callback,
        out HMIDIIN handle, size_t callbackData = 0) @nogc nothrow
{
    // BUG: THIS RETURNS 1 (MMSYSERR_ERROR) WHEN COMPILED IN x86 MODE
    return midiInOpen(&handle, deviceID, cast(size_t)(callback), callbackData, CALLBACK_FUNCTION);
}

/++ ditto ++/
MMRESULT openMIDIInputDevice(MIDIDeviceInfo di, MidiInProc callback,
        out HMIDIIN handle, size_t callbackData = 0) @nogc nothrow
{
    return openMIDIInputDevice(di.id, callback, handle, callbackData);
}

/++
    Starts the MIDI input device which is represented by the passed handle

    Returns:
        true on success
        false if the passed handle was invalid
 +/
bool startMIDIInputDevice(HMIDIIN handle) @nogc nothrow
{
    return (midiInStart(handle) == MMSYSERR_NOERROR);
}

/++
    Parses param1 of a MIM_DATA message

    See_Also:
        https://msdn.microsoft.com/en-us/library/vs/alm/dd757284(v=vs.85).aspx,
        https://users.cs.cf.ac.uk/Dave.Marshall/Multimedia/node158.html
 +/
MidiMessage parseMIMDATA(size_t param1) @nogc nothrow pure
{
    immutable ubyte status = param1.LOWORD.LOBYTE;
    immutable ubyte data1 = param1.LOWORD.HIBYTE;
    immutable ubyte data2 = param1.HIWORD.LOBYTE;

    return MidiMessage(0, status, data1, data2);
}
