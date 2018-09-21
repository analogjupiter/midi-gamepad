/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
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
Copyright (C) 2017-2018  0xEAB`);
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
