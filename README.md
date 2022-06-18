# screengrab
Perl Multi Platform Screenshot script that uploads over scp

## OS Compatibility
- Linux
- macOS
- Windows (requires clip command, [strawberry perl](https://strawberryperl.com/), and [git-bash](https://git-scm.com/download/win))

## Requirements
To use this script, it assumes you have several things setup:
1. For linux, you have a working installation of scrot and xclip 
(optional: notify-send)
2. You are using pubkey ssh authentication (or some other automated for) 
for scp

## Installing
### Linux and macOS
`chmod +x screengrab
 && sudo cp screengrab /usr/local/bin`

### Windows
- Download 
[screenCapture.bat](https://raw.githubusercontent.com/npocmaka/batch.scripts/master/hybrids/.net/c/screenCapture.bat) 
to %USERPROFILE%
- Copy screengrab.sh, screengrab.bat, screengrab.pl to %USERPROFILE%
- Create a shortcut for cmd.exe, right click and then click properties.
    - Name: Screengrab
    - Target: C:\Windows\System32\cmd.exe "/c title screengrab start /min 
screengrab.bat"
    - Start In: %USERPROFILE%
    - Shortcut Key: Shift + Prt Scrn (or whatever you want)
    - Run: Minimized
    - Icon: You can select a different icon from default list by browsing to C:\System32\SHELL32.dll

---
Written by Aaron Blakely <<aaron@ephasic.org>>

Copyright 2020-2022 (C) Aaron Blakely

