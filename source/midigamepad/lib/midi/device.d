/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
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
