/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
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
