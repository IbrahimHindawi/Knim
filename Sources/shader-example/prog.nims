#[
  nim c -d:Direct3D11 -d:dynamic  -r Sources\prog.nim
]#

import os
import strutils

mode = ScriptMode.Verbose

let 
  nimCache = "NimCache"
  deploymentDir = "Deployment"

proc execKincMake(backend: string) =
  # run SPIR-V shader compiler and build C project
  exec "node Kinc/make.js" & " --graphics " & backend.toLower() #../../


proc makeDir(dirName:string) =
  if dirExists(dirName):
    echo dirName & " directory found in root. skipping..."
  else:
    mkdir(dirName)
    echo dirName & " directory not found, creating in root."

echo "-------------------------------"
echo "Executing NimScript"

#[
  TODO(ibrahim): make nimnble package
]#
switch("path","../../Knim-Standalone/Knim")


#[
  Choose your backend here:
    Direct3D11 (Windows)
    OpenGL (Windows Linux)
    Metal (wip)
    Vulkan (wip)
]#

const
  Direct3D11 = "Direct3D11"
  OpenGL = "OpenGL"

var
  backend = ""

if defined(Direct3D11):
  echo "Backend: " & Direct3D11
  backend = Direct3D11
  switch("define", Direct3D11)

if defined(OpenGL):
  echo "Backend: " & OpenGL
  backend = OpenGL
  switch("define", OpenGL)

# Check for Deployment Directory
makeDir(deploymentDir)

# Check for NimCache
# makeDir(nimCache)

# echo "Starting dynamic deployment"

# execKincMake(backend)

# switch("outdir", deploymentDir)

# cd(deploymentDir)



if defined(dynamic):
  echo "Building nim dynamic..."
  
  execKincMake(backend)

  switch("outdir", deploymentDir)

  cd(deploymentDir)

elif defined(codegen):
  # echo "building nim codegen..."
  echo "Cannot codegen from here."
  echo "nim progCodegen.nims"

  
  # execKincMake(backend)

  # switch("nimcache",nimCache)


echo "-------------------------------"


