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

exec "node Kinc/make.js" & " --graphics " & backend.toLower()

var depldir = "DeploymentN"
if dirExists(depldir):
  echo depldir & " directory found"
else:
  mkDir(depldir)
  echo depldir & " directory not found, creating directory."

# TODO: copy file error: access is denied
# cpFile("Deployment/shader.frag", "DeploymentN")
# cpFile("Deployment/shader.vert", "DeploymentN")

#switch("forceBuild","on")
switch("outdir",depldir)
switch("define",backend)






#echo getCurrentDir()
#echo projectPath()
#cd("Kinc")
#echo getCurrentDir()
#echo findExe("Shader.exe")
#--outdir:"./DeploymentN"
#--path:"../Backend"
