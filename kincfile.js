let project = new Project('Kinc');

project.addFile('Sources/**');
project.setDebugDir('Deployment');

resolve(project);