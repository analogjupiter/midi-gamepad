/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
 +/
module midigamepad.shell.tui;

import core.thread;
import core.sys.windows.mmsystem : HMIDIIN, midiInStart, MIM_OPEN, MMRESULT,
    MMSYSERR_NOERROR;

//import core.sys.windows.winuser;
import std.conv : ConvException, to;
import std.file : exists;
import std.json : JSONException;
import std.stdio;
import std.string : chomp;

import midigamepad.lib.keyboard;
import midigamepad.lib.midi.input;
import midigamepad.lib.translation;
import midigamepad.shell.program : runMIDIGamePad;
import midigamepad.shell.texts;

/++
    Launches MIDI GamePad's text-based user interface (TUI)

    NOTE: At the moment it's not a real TUI
 +/
int launchTUI()
{
    printHeader();

    MIDIDeviceInfo selectedDevice = void;
    MappingsCollection mappings = void;

    while (true)
    {
        const uint devicesCount = getMIDIInputDevicesCount();

        if (devicesCount == 0)
        {
            // No suitable devices connected
            writeln("E:\tNo MIDI Input Devices connected.\n\tExiting...  :(");
            return 1;
        }

        write("MIDI Input Devices connected: ");
        writeln(devicesCount);

        if (devicesCount == 1)
        {
            // Only 1 suitable devices connected, skipping selection
            selectedDevice = getMIDIInputDeviceInfo(0);
            break;
        }

        // Retrieving all suitable devices
        // Repeat this every iteration because the user might have (dis-)connected a device
        MIDIDeviceInfo[] devices = getAllMIDIInputDevices();

        foreach (dev; devices)
        {
            write(dev.id);
            write(" ... ");
            writeln(dev.name);
        }

        write("Select the input device to use [0]: ");
        write(" $> ");

        uint selection = 0;

        const string userInput = readln().chomp;

        if (userInput.length == 0)
        {
            // Empty selection, use default
            selectedDevice = devices[0];
        }
        else
        {
            try
            {
                selection = userInput.to!uint();
            }
            catch (ConvException)
            {
                writeln("\nE:\tInvalid device selection  :(\n");
            }

            if (selection >= devicesCount)
            {
                // invalid number (no such device)
                writeln("\nE:\tUnknown device :(\n");
            }
        }

        selectedDevice = devices[selection];
        break;
    }

    // Show the selection
    write("\nSelected device:\t(");
    write(selectedDevice.id);
    write(") ");
    writeln(selectedDevice.name);

    while (true)
    {
        writeln("\nWhich mappings file should be loaded: ");
        write(" $> ");
        immutable string selectedMappingsFile = readln().chomp;

        if (!selectedMappingsFile.exists)
        {
            writeln("\nE:\tCannot find the specified path  :(\n");
            continue;
        }

        try
        {
            mappings = parseFile(selectedMappingsFile);
            writeln("Mappings file successfully loaded  :D\n");
            break;
        }
        catch (MappingsParserException ex)
        {
            writeln();
            printMappingsParserException(ex);
            writeln("\n");
            continue;
        }
    }

    writeln("Bootstrapping ...");
    return runMIDIGamePad(selectedDevice, mappings, true);
}
