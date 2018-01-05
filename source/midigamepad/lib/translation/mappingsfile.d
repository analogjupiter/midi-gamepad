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
module midigamepad.lib.translation.mappingsfile;

import std.conv : to;
import std.file : readText;
import std.json;
import std.stdio : write, writeln;

import midigamepad.lib.keyboard;
import midigamepad.lib.util;

public import midigamepad.lib.translation.mapping;

/++
    Parses the specified mappings file
 +/
MappingsCollection parseFile(string filePath)
{
    immutable string json = readText(filePath);
    return parse(json);
}

/++
    Parses the specified mappings json
 +/
MappingsCollection parse(string json)
{
    MappingsCollection output = MappingsCollection();

    JSONValue root = parseJSON(json, JSONOptions.escapeNonAsciiChars);
    JSONValue map = root.object["map"];

    // onNote mappings
    JSONValue onNote = map.object["onNote"];
    output.noteOnOff = new NoteOnOffMapping[onNote.array.length];
    size_t i = 0;

    foreach (JSONValue m; onNote.array)
    {
        output.noteOnOff[i++] = NoteOnOffMapping(
                m["vkey"].str.hexOrDecToNumber!uint.toScancode.to!ushort,
                (m["extended"].type == JSON_TYPE.TRUE), m["note"].str.hexOrDecToNumber!byte);
    }

    return output;
}
