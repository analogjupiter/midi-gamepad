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
module midigamepad.lib.keyboard;

import core.sys.windows.winbase;
import core.sys.windows.windef : HKL;
import core.sys.windows.winuser;
import std.conv : to;

/++
    Determines whether the specified vKey is an extended key or not

    See_Also:
        https://msdn.microsoft.com/en-us/library/windows/desktop/ms646267(v=vs.85).aspx#extended_key_flag
 +/
bool hasExtendedScancode(uint vkey)
{
    switch (vkey)
    {
    case VK_INSERT:
    case VK_DELETE:
    case VK_HOME:
    case VK_END:
    case VK_PRIOR:
    case VK_NEXT:
    case VK_LEFT:
    case VK_UP:
    case VK_RIGHT:
    case VK_DOWN:
    case VK_NUMLOCK:
    case VK_PRINT:
        return true;

    default:
        return false;
    }
}

/++
    Sends a keydown event to the OS

    Params:
        vKey =  virtual key to press
 +/
void synthesizeKeyDown(uint vKey)
{
    synthesize(Scancode(vKey.toScancode.to!ushort, vKey.hasExtendedScancode), false);
}

/++
    Sends a keyup event to the OS

    Params:
        vKey =  virtual key to release
 +/
void synthesizeKeyUp(uint vKey)
{
    synthesize(Scancode(vKey.toScancode.to!ushort, vKey.hasExtendedScancode), true);
}

/++
    Synthesizes a key press/release by sending its scancode

    Params:
        scancode =  scancode of the key to press
        
        up =        true  ... UP
                    false ... DOWN
 +/
void synthesize(Scancode scancode, bool up) @nogc nothrow
{
    INPUT input = INPUT();
    input.type = INPUT_KEYBOARD;

    input.ki.time = 0;
    input.ki.wVk = 0;
    input.ki.dwExtraInfo = 0;

    input.ki.dwFlags = KEYEVENTF_SCANCODE;
    if (scancode.extended)
    {
        input.ki.dwFlags |= KEYEVENTF_EXTENDEDKEY;
    }
    if (up)
    {
        input.ki.dwFlags |= KEYEVENTF_KEYUP;
    }

    input.ki.wScan = scancode.scancode;

    const uint rslt = SendInput(1, &input, INPUT.sizeof);
    assert(rslt != 0);
}

/++
    Returns: The scancode of the specified vKey
 +/
uint toScancode(uint vKey) @nogc nothrow
{
    static HKL keyboardLayout = null;

    if (keyboardLayout is null)
    {
        keyboardLayout = GetKeyboardLayout(0);
    }
    return MapVirtualKeyEx(vKey, MAPVK_VK_TO_VSC_EX, keyboardLayout);
}

/++
    Manager class for a key press/release loop
 +/
final class KeyboardSynthesizerLoopMgr
{
    import core.thread : Thread;
    import core.time : dur;
    import std.algorithm.mutation : remove;
    import std.algorithm.searching : canFind, countUntil;
    import std.range : empty;

    private
    {
        Scancode[] _down;
        Scancode[] _requestUp;
        Scancode[] _requestDown;

        Thread _loopThread;
        bool _loopThreadKill;
        long _loopThreadTimeout = 50;
    }

    public
    {
        @property
        {
            /++
                Returns: true = loop thread is running
             +/
            bool isRunning() @nogc nothrow
            {
                return ((this._loopThread !is null) && this._loopThread.isRunning);
            }
        }
    }

    public
    {
        /++
            Adds a key that will be "hold down" by the loop
         +/
        void press(Scancode scancode) nothrow pure @safe
        {
            if (!_down.canFind(scancode))
                this._requestDown ~= scancode;
        }

        /++ ditto +/
        void pressKey(uint vKey)
        {
            this.press(Scancode(vKey.toScancode.to!ushort, vKey.hasExtendedScancode));
        }

        /++
            "Releases" a key that is "hold down" by the loop
         +/
        void release(Scancode scancode) nothrow pure @safe
        in
        {
            assert(this._down.canFind(scancode));
        }
        body
        {
            if (!this._requestUp.canFind(scancode))
                this._requestUp ~= scancode;
        }

        /++ ditto +/
        void releaseKey(uint vKey)
        {
            this.release(Scancode(vKey.toScancode.to!ushort, vKey.hasExtendedScancode));
        }

        /++
            Starts the sending loop thread

            This will crash if the loop thread is already running.
            Check the .isRunning property first or call .tryStart() instead.
         +/
        void start()
        in
        {
            assert(!this.isRunning);
        }
        body
        {
            this._loopThread.destroy();
            this._loopThread = new Thread(&loop);
            this._loopThreadKill = false;
            this._loopThread.start();
        }

        /++
            Kills the sending loop thread
         +/
        void stop() @nogc nothrow pure @safe
        {
            this._loopThreadKill = true;
        }

        /++
            "Releases" a key if it has been "held down" by the loop

            Returns:
                true = if the key has been "held down" (which means the release will get performed)
         +/
        bool tryRelease(Scancode scancode) nothrow pure @safe
        {
            if (!this._down.canFind(scancode))
                return false;

            release(scancode);
            return true;
        }

        /++ ditto +/
        bool tryReleaseKey(uint vKey)
        {
            return tryRelease(Scancode(vKey.toScancode.to!ushort, vKey.hasExtendedScancode));
        }

        /++
            Starts the sending loop thread if it is not already running

            Returns:
                true  = loop thread got started
                false = loop thread has already been running
         +/
        bool tryStart()
        {
            if (this.isRunning)
                return false;

            this.start();
            return true;
        }
    }

    private
    {
        void loop()
        {
            do
            {
                if (!this._requestUp.empty)
                {
                    foreach (Scancode scancode; this._requestUp)
                    {
                        // send keyUp
                        synthesize(scancode, true);

                        // can only occurre once, so just remove its first occurrence
                        const ptrdiff_t idx = this._down.countUntil(scancode);
                        this._down = this._down.remove(idx);
                    }

                    this._requestUp = [];
                }

                if (!this._requestDown.empty)
                {
                    this._down ~= this._requestDown;
                    this._requestDown = [];
                }

                foreach (Scancode scancode; this._down)
                {
                    // send keyDown
                    synthesize(scancode, false);
                }

                // wait for a while
                Thread.sleep(dur!"msecs"(this._loopThreadTimeout));
            }
            while (!this._loopThreadKill);
        }
    }
}

/++
    Represents a keyboard scancode
 +/
struct Scancode
{
@nogc nothrow pure @safe:

    /++
        Specifies whether the scancode is an extended one
     +/
    bool extended;

    /++
        Keyboard scancode
     +/
    ushort scancode;

    /++
        ctor
     +/
    this(ushort scancode, bool extended)
    {
        this.scancode = scancode;
        this.extended = extended;
    }
}
