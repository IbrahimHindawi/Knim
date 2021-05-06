let project = new Project('Kinc');

project.addFile('Sources/**');
project.setDebugDir('Deployment');


// PATH TO NIM LIBRARY
project.addIncludeDir('C:/Users/Administrator/nim-1.4.2/lib');
project.addIncludeDir('Knim-Standalone/cache');

// PATH TO NIM CODEGEN
project.addFile('Knim-Standalone/cache/**');

resolve(project);