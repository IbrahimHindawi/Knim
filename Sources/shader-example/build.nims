
import os
import strutils

mode = ScriptMode.Verbose

# codegen compiler operating systems
# switch("os", "windows")
#switch("os","android")
#switch("define","androidNDK")

# codegen compiler cpu architectures
# switch("cpu","amd64")
# switch("cpu","arm64")


# codegen compiler
# switch("cc","vcc")
# switch("cc","clang")

#[
  build mode switching
]#
# switch("define","codegen")
# switch("define","dynamic")

# android
# nim compile --cc:clang --os:android --cpu:arm64 --d:androidNDK --compileOnly --nimcache:Knim-Standalone\cache -d:OpenGL -d:codegen --noMain --header:prog.h Knim-Standalone\Knim\prog.nim
# ndk {abiFilters "arm64-v8a"}

# windows
# nim compile --cc:vcc --compileOnly --nimcache:NimCache --noMain --header:prog.h -d:Direct3D11 -d:codegen Sources\prog.nim

# nim c -d:dynamic --run Sources\prog.nim

proc cleanBuildAndCache( buildDir:string, nimCacheDir:string ) = 
  rmDir(buildDir)
  rmDir(nimCacheDir)

proc makeDir(dirName:string) =
  if dirExists(dirName):
    echo dirName & " directory found in root. skipping..."
  else:
    mkdir(dirName)
    echo dirName & " directory not found, creating in root."


echo "-------------------------------"
echo "Executing NimScript"

cleanBuildAndCache("build", "NimCache")

#[
  TODO(ibrahim): make nimnble package
]#
#switch("path","../Knim-Standalone/Knim")

const
  pathcmd = " --path:../Knim-Standalone/Knim "

  dynamic = "dynamic"
  codegen = "codegen"

  Direct3D11 = "Direct3D11"
  OpenGL = "OpenGL"

var
  backend = ""

if defined(Direct3D11):
  echo "Backend: " & Direct3D11
  backend = Direct3D11
  switch("define", Direct3D11)

elif defined(OpenGL):
  echo "Backend: " & OpenGL
  backend = OpenGL
  switch("define", OpenGL)

else:
  echo "Backend: Unknown!"
  echo "Please choose a backend"

#[
  SHARED VARIABLES
]#
var
  progName = "prog"
  runmode = ""

#[
  DYNAMIC
]#

let
  deploymentDir = "Deployment"
  deploymentCmd = " --outdir:. "

if defined(dynamic):
  runmode = dynamic

  makeDir(deploymentDir)

  exec "node Kinc/make.js" & " --graphics " & backend.toLower()

  #switch("outdir", deploymentDir)

  #echo getCurrentDir()

  cd(deploymentDir)

  exec "nim c -r " & deploymentCmd & pathcmd & " -d:" & backend & " -d:" & runmode & " ../Sources/shader-example/" & progName & ".nim"

#[
  CODEGEN
]#

let
  compiler = "vcc"
  opersyst = "windows"
  cpuarchi = "amd64"
  nimcache = "NimCache"

if defined(codegen):
  runmode  = codegen

  exec "nim "     & "c "     & "--noMain " & "--compileOnly " & pathcmd &
    "--cc:"       & compiler & " " &
    "--os:"       & opersyst & " " &
    "--cpu:"      & cpuarchi & " " &
    "--nimcache:" & nimcache & " " &
    "--header:"   & progName & ".h " &
    "-d:"         & backend  & " " &
    "-d:"         & runmode  & " " &
    "Sources/shader-example/"    & progName & ".nim"

  exec "node Kinc/make.js" & " --graphics " & backend.toLower() & " --compile " & " --run "

