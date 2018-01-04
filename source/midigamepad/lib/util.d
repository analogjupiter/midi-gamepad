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
module midigamepad.lib.util;

import std.conv : to;
import std.string;

/++
    Trims the end of an array assuming that the end starts with null
 +/
T[] trimEndNull(T)(T[] arg) @nogc nothrow pure @safe
{
    size_t i = arg.length;

    foreach (idx, c; arg)
    {
        if (ushort(c) == 0)
        {
            i = idx;
            break;
        }
    }

    return arg[0 .. i];
}

Number hexOrDecToNumber(Number)(string input)
{
    if (input.startsWith("0x"))
    {
        // hex
        return input[2 .. $].to!Number(16);
    }
    else
    {
        // dec
        return input.to!Number;
    }
}
