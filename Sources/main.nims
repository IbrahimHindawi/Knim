import os

mode = ScriptMode.Verbose
echo "executing nim script..."



#echo getCurrentDir()
#echo projectPath()
#cd("Kinc")
#echo getCurrentDir()
#echo findExe("Shader.exe")
#--outdir:"./DeploymentN"
#--path:"../Backend"

#exec "node Kinc/make.js" & " --graphics " & "opengl"
exec "node Kinc/make.js"

var depldir = "DeploymentN"
if dirExists(depldir):
  echo depldir & " directory found"
else:
  mkDir(depldir)
  echo depldir & " directory not found, creating directory."

switch("outdir",depldir)

#switch("forceBuild","on")

var 
  #backend = "Direct3D11"
  backend = "OpenGL"
switch("define",backend)