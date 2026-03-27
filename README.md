# ASM Calculator

Console calculator written in x86 Assembly using NASM and GoLink.

## Features

- Addition, subtraction, multiplication and division
- Console input/output using WinAPI
- Manual ASCII to integer conversion
- Input validation

## Technologies

- x86 Assembly (NASM)
- Windows API (GetStdHandle, WriteConsoleA, ReadConsoleA)
- GoLink

## Build and Run

```powershell
nasm -f win32 main.asm -o main.obj
golink.exe /console /entry _start main.obj kernel32.dll user32.dll
main.exe
```

## VS Code

Project includes ready-to-use build tasks:

- Build ASM
- Link ASM
- Build and Run ASM

## Author

Alexander Davidov

## Demo
https://youtu.be/7Z3ZP239rGg
