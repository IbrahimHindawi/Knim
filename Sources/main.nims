mode = ScriptMode.Verbose
echo "executing nim script..."
#echo getCurrentDir()
#echo projectPath()
#cd("Kinc")
#echo getCurrentDir()
#echo findExe("Shader.exe")
#--outdir:"./DeploymentN"
#--path:"../Backend"

switch("outdir","DeploymentN")

switch("forceBuild","on")
#switch("define","Direct3D11")
switch("define","OpenGL")
