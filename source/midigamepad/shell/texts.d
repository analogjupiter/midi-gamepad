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
module midigamepad.shell.texts;

import std.stdio;

import midigamepad.lib.translation.mappingsfile;

/++
    LF + 2 tabulators
 +/
enum newLineDoubleTab = "\n\t\t";

/++
    Prints the app+version info and the license header
 +/
void printHeader()
{
    writeln("\nMIDI GamePad [v" ~ import("version.txt") ~ `]
Copyright (C) 2017 0xEAB


    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it under certain conditions.
    For more information, please refer to <https://www.gnu.org/licenses/gpl-3.0.html>

`);
}

/++
    Prints the help text
 +/
void printHelp(string app)
{
    writeln(` Usage
=======

    ` ~ app ~ `  [(deviceID mpPath) |--args]


        deviceID            Numeric ID of the selected MIDI input device
        mpPath              Path to selected mappings file


        --help | /?         Displays this help text

        --tui | <no args>   Launches MIDI GamePad in TUI mode

        --version | -v      Prints the version info

`);
}

/++
    Prints the passed MappingsParserException
 +/
void printMappingsParserException(MappingsParserException ex)
{
    writeln("E:\tAn error occured while parsing the mappings file  :(");

    write(newLineDoubleTab);
    write(ex.msg);

    if (ex.faultyMapping.toString == "")
    {
        write(newLineDoubleTab);
        write("\t");
        writeln(ex.faultyMapping);
    }

    if (ex.next !is null)
    {
        write(newLineDoubleTab);
        write("\t");
        writeln(ex.next.msg);
    }
}
