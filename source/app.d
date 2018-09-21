/+
              Copyright Elias Batek 2017 - 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
 +/
import midigamepad.shell.commandline;
import midigamepad.shell.tui;

int main(string[] args)
{
    return (args.length < 2 || args[1] == "--tui")
        ? launchTUI()
        : launchCommandline(args);
}
