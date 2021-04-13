mode = ScriptMode.Verbose
echo "executing nim script..."
#echo getCurrentDir()
#echo projectPath()
#cd("Kinc")
#echo getCurrentDir()
#echo findExe("Shader.exe")
#--outdir:"./DeploymentN"
#--path:"../Backend"
switch("outdir", "DeploymentN")
#switch("path","../Kinc/Backends/Graphics4/Direct3D11/Sources/kinc/backend/graphics4")
switch("path","../Kinc/Backends/Graphics4/OpenGL/Sources/kinc/backend/graphics4")
#switch("")
