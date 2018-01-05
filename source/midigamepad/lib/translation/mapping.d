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
