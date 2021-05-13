# Knim
## _Kinc in Nim_

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Knim are the Nim bindings of the [Kinc](https://github.com/Kode/Kinc) low level ultra-portable graphics library.

⚠️This repository is still a work in progress⚠️

Tested on:
<li>Windows: Direct3D11 and OpenGL (Direct3D12 & Vulkan soon)</li> 
<li>Linux: OpenGL (Vulkan soon)</li>
<li>MacOSX: OpenGL (Metal soon)</li>
<li>Android: OpenGL (Vulkan soon)</li>

<br>Not tested on:
<li>IOS: Metal</li>
<li>PS4/PS5: LibGNM</li>
<li>XBOX: Direct3D12</li>
<li>WEB</li>
<li>...</li>

## Dependencies

- You need node installed on your system PATH. (You can download the binary).

## Features

- Check out https://github.com/Kode/Kinc or  https://github.com/Kode/Kha for features

## How to get

- ```git clone --recursive https://github.com/IbrahimHindawi/Knim```

## How to run

This library can be ran in two modes:<br>
dynamic: link against a dynamic library and debug Nim directly in VS Code using LLDB.<br>
codegen: inject the C generated from Nim into the target IDE and build/debug from IDE.<br><br>
- dynamic library mode:
    - You must first generate the dll for your chosen backend.
    - From the Knim root directory, run: ```node Kinc/make --dynlib -g opengl``` or ```node Kinc/make --dynlib -g direct3d11```.
    - Open the solution in the ```build``` directory and build to get ```Kinc.dll```.
    - Rename to ```KincDirect3D11.dll``` or ```KincOpenGL.dll```.
    - Place dll in a folder called ```Deployment``` in the root (Windows).
    - ```nim -d:dynamic -d:direct3d11 Sources\build.nims```

- codegen inject mode:
    - Edit kincfile.js to point to your local nim/lib directory.
    - Customize ```build.nims``` Nimscript file for target compiler/cpu/os.
    - for Android, add ```ndk {abiFilters "arm64-v8a"}``` to the ```gradle.build```
    - ```nim -d:codegen -d:direct3d11 Sources\build.nims```

## Tutorials

- [Lewis Lepton](https://www.youtube.com/playlist?list=PL4neAtv21WOmmR5mKb7TQvEQHpMh1h0po) - Kha Tutorial
- [Lubos Lenco](https://github.com/luboslenco/kha3d_examples/wiki) - Kha 3D Tutorial

## Documentation

- Unfortunately there are no docs for [Kinc](https://github.com/Kode/Kinc) yet.
- Minimal Kha docs here: [Kha](http://kha.tech/).

## To do:
- Automate the project ( there are already .vscode build tasks in the standalone subdirectory).
- Make Nimble Package(s).
- get rid of prog.nims
- I will attempt to write docs as I work more on binding this library.
