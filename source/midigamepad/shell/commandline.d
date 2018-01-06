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
module midigamepad.shell.commandline;

import std.conv : ConvException, parse;
import std.file : exists;
import std.stdio;

import midigamepad.lib.midi;
import midigamepad.lib.translation.mappingsfile;
import midigamepad.shell.program;
import midigamepad.shell.texts;
import midigamepad.shell.tui : launchTUI;

/++
    Launches MIDI GamePad based on the passed arguments
 +/
int launchCommandline(string[] args)
{
    if (args[1] == "--help" || args[1] == "/?")
    {
        // Show help
        printHeader();
        printHelp(args[0]);
        return 0;
    }
    else if (args[1] == "--version" || args[1] == "-v")
    {
        // Show version
        printHeader();
        return 0;
    }
    else if (args.length >= 2)
    {
        uint selection;

        try
        {
            selection = args[1].parse!uint;
        }
        catch (ConvException)
        {
            // The 1st argument is not a valid (uint) device ID
            writeln("Invalid device ID passed.");
            return 1;
        }

        const uint devicesCount = getMIDIInputDevicesCount();

        // Check whether there is a such a MIDI input device
        if (selection >= devicesCount)
        {
            writeln("The passed device ID was out of range.");
            return 1;
        }

        // Check whether the specified mappings file exists
        if (!args[2].exists)
        {
            writeln("The specified mappings file does not exists.");
            return 1;
        }

        MIDIDeviceInfo dev = getMIDIInputDeviceInfo(selection);
        MappingsCollection mpc = void;

        try
        {
            mpc = parseFile(args[2]);
        }
        catch (MappingsParserException ex)
        {
            printMappingsParserException(ex);
            return 1;
        }

        // Launch the main IO processor
        return runMIDIGamePad(dev, mpc);
    }
    else
    {
        writeln("No mappings file specified.");
        return 1;
    }
}
