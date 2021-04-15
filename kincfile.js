let project = new Project('Kinc');

project.addFile('Sources/**');
project.setDebugDir('Deployment');
project.setDebugDir('DeploymentN');

resolve(project);