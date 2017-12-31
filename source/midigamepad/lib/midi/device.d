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
module midigamepad.lib.midi.device;

/++
    Type of a MIDI device

    Specifies its functionality
 +/
enum MIDIDeviceType
{
    input,
    output
}

/++
    Represents a MIDI device
 +/
struct MIDIDeviceInfo
{
    /++
        Human-readable name of the device (e.g. "Keystation Mini 32")
     +/
    string name;

    /++
        Identifier of the device (used by the operating system)

        This number is *not* unique across different devices types and may change after reconnecting any devices.
     +/
    uint id;

    /++
        Type of the device
     +/
    MIDIDeviceType type;
}
