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
