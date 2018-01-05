# 🎹🎮 MIDI GamePad [![Dub version](https://img.shields.io/dub/v/midi-gamepad.svg)](https://code.dlang.org/packages/midi-gamepad) [![GPL-3.0](https://img.shields.io/dub/l/midi-gamepad.svg)](LICENSE.txt)
This little tool allows you to **play your favorite games with your MIDI keyboard**.


## About
This program does *not* emulate a *GamePad*, it simulates a keyboard. Nevertheless, you can use it as input for a GamePad emulator.


## Usage
The easiest way to launch *MIDI GamePad* is to pass the `{deviceID}` and the `{mpPath}` parameters:
<br> `midi-gamepad 0 examples\abc.json`

To start in TUI mode, just pass *no* parameters (or `--tui`).
<br> `--version` prints the version info.
<br> `--help` displays a help text.


## Build

You can either build this app yourself (see both variants below) or just *download* a precompiled binary from the [releases page](releases).

### Using DUB
1. `git clone https://github.com/voidblaster/midi-gamepad`
2. `cd midi-gamepad`
3. `dub build`
4. You can now find the executable in the `bin/` directory.

### Using DUB (without Git)
1. `dub fetch midi-gamepad`
2. `dub build midi-gamepad`
3. You can now run the executable via `dub run`.
4. Pass any parameters after a double dash (`--`): <br> `dub run midi-gamepad -- <args>`


## Platform Support
Only Windows is supported, at the moment. If you want to add support for another OS, feel free to contribute! 😃


## Dependencies
For processing MIDI data this program
relies on [Dplug:client](https://github.com/AuburnSounds/Dplug)
by [AuburnSounds](https://www.auburnsounds.com/)
which has been licensed under the terms of the [Cockos WDL License](LICENSE.Dplug.txt).
