let project = new Project('Kinc');

project.addFile('Sources/**');
project.setDebugDir('Deployment');

// PATH TO NIM LIBRARY
project.addIncludeDir('C:/Users/Administrator/nim-1.4.2/lib');

// PATH TO NIM CODEGEN INCLUDE
project.addIncludeDir('NimCache');

// PATH TO NIM CODEGEN C FILES
project.addFile('NimCache/**');

resolve(project);