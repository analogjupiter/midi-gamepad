/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
 +/
module midigamepad.shell.program;

import core.thread;
import core.sys.windows.mmsystem;
import std.conv : to;
import std.stdio;
import std.string : format;

import midigamepad.lib;

/++
    Starts the core MIDI GamePad program
 +/
int runMIDIGamePad(MIDIDeviceInfo inputDevice, MappingsCollection mappings,
        bool showStartMessage = false)
in
{
    assert(inputDevice.type == MIDIDeviceType.input);
}
body
{
    HMIDIIN handle;

    auto kb = new KeyboardSynthesizerLoopMgr();
    auto pcd = new IOProcessorData(kb, mappings);

    if (!runIOProcessor(inputDevice, pcd, handle))
    {
        writeln("An error occurred during the device initialization  :(");
        return 1;
    }

    if (showStartMessage)
    {
        writeln("\n\n.::  MIDI GamePad is ready to play ^^");
    }

    while (true)
    {
        // MessageLoop
        Thread.sleep(dur!"msecs"(100));
    }
}
