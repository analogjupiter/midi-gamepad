/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
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
