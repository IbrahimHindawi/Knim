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
switch("path","../Knim-Standalone/Knim")


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

const 
  backend = Direct3D11

if backend == Direct3D11:
  echo Direct3D11 & " backend chosen"
  switch("define", Direct3D11)

elif backend == OpenGL:
  echo OpenGL & " backend chosen"
  switch("define", OpenGL)

# Check for Deployment Directory
makeDir(deploymentDir)

# Check for NimCache
makeDir(nimCache)

echo "Starting deployment"

# codegen compiler operating systems
#switch("os","android")
#switch("define","androidNDK")

# codegen compiler cpu architectures
# switch("cpu","arm64")

# codegen compiler
# switch("cc","vcc")
# switch("cc","clang")

#[
  build mode switching
]#
# switch("define","dynamic")
# switch("define","codegen")

# android
# nim compile --cc:clang --os:android --cpu:arm64 --d:androidNDK --compileOnly --nimcache:Knim-Standalone\cache -d:OpenGL -d:codegen --noMain --header:prog.h Knim-Standalone\Knim\prog.nim
# ndk {abiFilters "arm64-v8a"}

# windows
# nim compile --cc:vcc --compileOnly --nimcache:NimCache --noMain --header:prog.h -d:Direct3D11 -d:codegen Sources\prog.nim

# nim c -d:dynamic --run Sources\prog.nim
if defined(dynamic):
  echo "building nim dynamic..."
  
  execKincMake(backend)

  switch("outdir", deploymentDir)

  # go to deployment directory
  cd(deploymentDir)

elif defined(codegen):
  switch("nimcache",nimCache)
  
  #execKincMake(backend)

  echo "building nim codegen..."

echo "-------------------------------"


