/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
 +/
module midigamepad.lib.translation.mapping;

import midigamepad.lib.keyboard : Scancode;

public import dplug.client.midi : MidiControlChange;

/++
    A collection that stores mappings
 +/
struct MappingsCollection
{
    NoteOnOffMapping[] noteOnOff;
}

/++
    Mapping base

    Used for mapping MIDI input messages to keyboard scancodes
 +/
struct Mapping
{
@nogc nothrow pure @safe:

    /++/
    Scancode _base;
    alias _base this;

    /++
        ctor
     +/
    this(ushort scancode, bool extended)
    {
        this._base = Scancode(scancode, extended);
    }
}

/++
    Used for mapping MIDI note on/off messages to keyboard scancodes
 +/
struct NoteOnOffMapping
{
@nogc nothrow pure @safe:

    /++/
    Mapping _base;
    alias _base this;

    /++
        MIDI note number
     +/
    byte noteNumber;

    /++
        ctor
     +/
    this(ushort scancode, bool extended, byte noteNumber)
    in
    {
        // validate MIDI note number
        // upper bound is ensured by the data type
        assert(noteNumber >= 0);
    }
    body
    {
        this._base = Mapping(scancode, extended);
        this.noteNumber = noteNumber;
    }
}

/++
    Used for mapping MIDI CC on/off messages to keyboard scancodes
 +/
struct CCOnOffMapping
{
@nogc nothrow pure @safe:

    /++/
    Mapping _base;
    alias _base this;

    /++
        MIDI CC
     +/
    MidiControlChange control;

    /++
        ctor
     +/
    this(ushort scancode, bool extended, MidiControlChange control)
    {
        this._base = Mapping(scancode, extended);
        this.control = control;
    }
}
