import os, strutils

mode = ScriptMode.Verbose
echo "executing nim script..."

#[
  Choose your backend here:
    Direct3D11 (Windows)
    OpenGL (Windows Linux)
    Metal (wip)
    Vulkan (wip)
]#

var 
  backend = "Direct3D11"
  #backend = "OpenGL"

# run SPIR-V shader compiler and build C project
exec "node Kinc/make.js" & " --graphics " & backend.toLower()

var deployDir = "DeploymentN"
if dirExists(deployDir):
  echo deployDir & " directory found"
else:
  mkDir(deployDir)
  echo deployDir & " directory not found, creating directory."
# go to deployment directory
cd(deployDir)

# TODO: copy file error: access is denied
# cpFile("Deployment/shader.frag", "DeploymentN")
# cpFile("Deployment/shader.vert", "DeploymentN")

#switch("forceBuild","on")
switch("define",backend)
# set output directory to current directory => deployment directory
switch("outdir",".")