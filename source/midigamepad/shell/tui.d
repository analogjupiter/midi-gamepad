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

    MIDIDeviceInfo selectedDevice;
    MappingsCollection mappings;

    while (true)
    {
        const uint devicesCount = getMIDIInputDevicesCount();

        if (devicesCount == 0)
        {
            // No suitable devices connected
            writeln("E:\tNo MIDI Input Devices connected.\n\tExiting... :(");
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
                writeln("\nE:\tInvalid device selection :(\n");
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
            writeln("\nE:\tCannot find the specified path :(");
            continue;
        }

        try
        {
            mappings = parseFile(selectedMappingsFile);
            writeln("Mappings file successfully loaded :D\n");
            break;
        }
        catch (Exception ex)
        {
            writeln("\nE:\tThere is a problem with the specified file :(\n");
            write("\t\t");
            writeln(ex.msg);
            writeln("\n");
            continue;
        }

    }

    writeln("Bootstrapping ...");
    return runMIDIGamePad(selectedDevice, mappings, true);
}
