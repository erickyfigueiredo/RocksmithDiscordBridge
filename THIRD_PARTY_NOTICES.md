# Third-party notices

New bridge code is MIT licensed; see LICENSE. This repository patches RS_ASIO 0.7.4 and includes small upstream test fixtures. Releases include the modified RS_ASIO DLL and a bundled Python player, not the game, its music, Ubisoft software, ASIO drivers or Discord.

## RS_ASIO

Source: https://github.com/mdias/rs_asio (v0.7.4)

The modified DLL retains this license and copyright:

```text
MIT License

Copyright (c) 2019 Micael Dias

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```

## Windows player runtime

The Windows distribution includes license texts under `licenses/`, in addition to texts already collected with the runtime. Consult those files for full terms and copyright notices.

| Component | License | Source |
| --- | --- | --- |
| CPython | Python Software Foundation License and included historical licenses | https://www.python.org/ |
| NumPy | BSD-3-Clause and bundled numerical-library notices | https://numpy.org/ |
| sounddevice / PortAudio | MIT / PortAudio license | https://python-sounddevice.readthedocs.io/ |
| CFFI | MIT | https://cffi.readthedocs.io/ |
| pycparser | BSD-3-Clause | https://github.com/eliben/pycparser |
| Tcl/Tk | Tcl/Tk licenses, included with the runtime | https://www.tcl.tk/ |
| PyInstaller bootloader | GPL-2.0-or-later with the distribution exception stated in its license | https://pyinstaller.org/ |

PyInstaller is a build tool; its bootloader exception permits distributing bundled applications under their own licenses. Read its bundled COPYING text for the actual terms. Microsoft runtime components, if included by the bundler, remain subject to their respective redistribution terms.


## Graphical installer and optional prerequisite downloads

The graphical installer is built with Inno Setup (https://jrsoftware.org/). Its compiler license text is included under licenses/ when available at build time. ASIO4ALL and Microsoft runtime installers are not redistributed in the package: selected optional installers are downloaded from their official sources, hash-checked and opened under their own terms.
