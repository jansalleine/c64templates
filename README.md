# C64 Programming Templates

Boilerplate-Code to quickly start a new C64 project.

## Prerequisties:

 - [Linux](https://www.linux.org/pages/download/) with [GNU core utilities](https://www.gnu.org/software/coreutils/) and [util-linux](https://github.com/util-linux/util-linux)
 - [ACME Crossassembler](https://sourceforge.net/projects/acme-crossass/) v0.97
 - [Exomizer](https://csdb.dk/release/?id=204524) v3.1.1
 - [PHP CLI](https://www.php.net/downloads.php) >=7.4
 - [png2prg 1.2](https://csdb.dk/release/?id=220484)
 - [VICE](https://vice-emu.sourceforge.io/) – the Versatile Commodore Emulator

The `compile.sh` and PHP scripts expects theese tools to be runable from **$PATH** under the following aliases:

| binary   | alias     |
| :------- | :-------- |
| dd       | dd        |
| hexdump  | hexdump   |
| acme     | acme      |
| exomizer | exomizer3 |
| png2prg  | png2prg   |
| x64sc    | vice      |

 **PHP** should be available for shell script usage with shebang `#!/usr/bin/env php`.

## License (MIT)

Copyright © 2023 Jan Wassermann, https://www.jansalleine.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
