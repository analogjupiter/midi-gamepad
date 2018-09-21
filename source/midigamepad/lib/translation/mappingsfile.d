/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
 +/
module midigamepad.lib.translation.mappingsfile;

import std.ascii : isAlpha;
import std.conv : ConvException, to;
import std.exception;
import std.file : readText;
import std.json;
import std.string;
import std.stdio : write, writeln;
import std.utf : UTFException;

import midigamepad.lib.keyboard;
import midigamepad.lib.util;

public import midigamepad.lib.translation.mapping;

/++
    Parses the specified mappings file
 +/
MappingsCollection parseFile(string filePath)
{
    string json = void;

    try
    {
        json = readText(filePath);
    }
    catch (UTFException ex)
    {
        throw new MappingsParserException("Not a text file", ex);
    }

    return parse(json);
}

/++
    Parses the specified mappings json
 +/
MappingsCollection parse(string json)
{
    JSONValue root = void;

    try
    {
        root = parseJSON(json, JSONOptions.escapeNonAsciiChars);
    }
    catch (JSONException ex)
    {
        throw new MappingsParserException("Bad JSON", ex);
    }

    // Make sure there is a 'map' field
    enforce(("map" in root.object), new MappingsParserException("Missing 'map' field", root));
    immutable JSONValue map = root.object["map"];

    MappingsCollection output = MappingsCollection();

    // onNote mappings
    if ("onNote" in map.object)
    {
        immutable JSONValue onNote = map.object["onNote"];
        output.noteOnOff = parseNoteOnOffMappings(onNote);
    }

    return output;
}

/++
    Parses the specified NoteOnOffMappings
 +/
NoteOnOffMapping[] parseNoteOnOffMappings(JSONValue noteOnOffRoot)
{
    auto ar = noteOnOffRoot.array;
    NoteOnOffMapping[] output = new NoteOnOffMapping[ar.length];

    foreach (size_t i, JSONValue m; ar)
    {
        uint vKey = void;

        // Ensure that the required elements exist
        enforce(("vkey" in m), new MappingsParserException("Missing 'vkey' field", m));
        enforce(("note" in m), new MappingsParserException("Missing 'note' field", m));

        immutable string vKeyStr = m["vkey"].str;
        immutable string noteStr = m["note"].str;

        // Try to parse the vKey
        if (!vKeyStr.tryParseVKEY(vKey))
            throw new MappingsParserException("Cannot parse invalid vKey: `" ~ vKeyStr ~ "`", m);

        immutable ushort scancode = vKey.toScancode.to!ushort;
        immutable bool isExtended = vKey.hasExtendedScancode;

        try
        {
            immutable byte note = noteStr.hexOrDecToNumber!byte;
            output[i] = NoteOnOffMapping(scancode, isExtended, note);
        }
        catch (ConvException ex)
        {
            throw new MappingsParserException(
                    "Cannot parse invalid MIDI note number: `" ~ noteStr ~ "`", m, ex);
        }
    }

    return output;
}

/++
    Tries to parse the passed vKey string and converts it into a scan

    Params:
        input   = input vKey string
        vKey    = contains the vKey

    Returns:
        true = success
 +/
bool tryParseVKEY(string input, out uint vKey) nothrow pure @safe
{
    // Check whether vKey is a number (hex or dec)
    if (input.startsWith("0x") || input.isNumeric)
    {
        try
        {
            vKey = input.hexOrDecToNumber!uint;
            return true;
        }
        catch (Exception)
        {
            // Conversion failure
            return false;
        }
    }

    // Check whether vKey is a single char
    else if ((input.length == 1) && input[0].isAlpha)
    {
        vKey = uint(input[0].toUpper);
        return true;
    }

    // Not parseable
    return false;
}

@safe unittest
{
    uint output;

    assert("0x12".tryParseVKEY(output));
    assert(output == 0x12);

    assert("0x1B".tryParseVKEY(output));
    assert(output == 0x1B);

    assert("31".tryParseVKEY(output));
    assert(output == 31);

    assert("A".tryParseVKEY(output));
    assert(output == 'A');

    assert("b".tryParseVKEY(output));
    assert(output == 'B');

    assert(!"".tryParseVKEY(output));
    assert(!"yy".tryParseVKEY(output));
    assert(!"DD".tryParseVKEY(output));
    assert(!"→".tryParseVKEY(output));
    assert(!"♠".tryParseVKEY(output));
    assert(!".".tryParseVKEY(output));
}

/++
    This is exception is thrown when the parser fails to parse a mapping.

    Check the .faulyMapping property to see which one caused the problem.
 +/
class MappingsParserException : Exception
{
@nogc nothrow pure @safe:

    private
    {
        JSONValue _faultyMapping;
    }

    /++
        The faulty mapping that could not be parsed
     +/
    public @property JSONValue faultyMapping() const
    {
        return this._faultyMapping;
    }

    /++
        ctor
     +/
    public this(string msg, Throwable next = null)
    {
        super(msg, next);
    }

    /++ ditto +/
    public this(string msg, JSONValue faultyMapping, Throwable next = null)
    {
        this(msg, next);
        this._faultyMapping = faultyMapping;
    }
}
