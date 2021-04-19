# Knim
## _Kinc in Nim_

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Knim are the Nim bindings of the [Kinc](https://github.com/Kode/Kinc) low level ultra-portable graphics library.

⚠️This repository is still a work in progress⚠️

- Tested only on Windows (Direct3D11 and OpenGL) and linux (OpenGL)
- More Backends & Systems coming soon

## Dependencies

- You need node installed on your system PATH. (You can download the binary)

## Features

- Check out https://github.com/Kode/Kinc or  https://github.com/Kode/Kha for features

## How to get

- ```git clone --recursive https://github.com/IbrahimHindawi/Knim```

## How to run

- you must first generate the dll for your chosen backend:
    -  From the Knim root directory, run: ```node Kinc/make --dynlib -g opengl``` or ```node Kinc/make --dynlib -g direct3d11```
    -  Open the Visual Studio Solution in the ```Knim/build``` directory and build in visual studio to get ```Kinc.dll```
    -  Rename to ```KincDirect3D11.dll``` or ```KincOpenGL.dll```
    -  Place dll in a folder called ```DeploymentN``` in the root
- ```nim c -r Sources/<exampleName>.nim```
- you can switch backend from ```Sources/exampleName.nims``` file

## Tutorials

- [Lewis Lepton](https://www.youtube.com/playlist?list=PL4neAtv21WOmmR5mKb7TQvEQHpMh1h0po) - Kha Tutorial
- [Lubos Lenco](https://github.com/luboslenco/kha3d_examples/wiki) - Kha 3D Tutorial

## Documentation

- Unfortunately there are no docs for [Kinc](https://github.com/Kode/Kinc) yet.
- Minimal Kha docs here: [Kha](http://kha.tech/).
- I will attempt to write docs as I work more on binding this library.