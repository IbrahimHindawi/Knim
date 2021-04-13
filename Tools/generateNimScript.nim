import os

var
  script: seq[string]

# script mode verbose
script.add("mode = ScriptMode.Verbose")
# echo status
script.add("echo \"executing Kni setup script...\"")
# setup deploymentN output directory

script.add("switch(\"outdir\", \"DeploymentN\")")
# inject js proc into kincmake

# parse buildData.json

# append pased data into --path switches

# compile shaders using kincmake

# move shaders into DeploymentN