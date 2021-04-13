#[
  Nim program used to replicate kinc's folder hierarchy
]#

import os

let
  rootDir = getCurrentDir()

  kincSourceDir = rootDir & "/Kinc/Sources/"
  kincDir = kincSourceDir & "kinc/"
  kincBackendDir = rootDir & "/Kinc/Backends/"

  kniSourceDir = rootDir & "/Kni/Sources/"
  kniDir = kniSourceDir & "kni/"
  kniBackendDir = rootDir & "/Kni/Backends/"

#echo rootDir
# echo kincSourceDir
# echo kincDir
# echo kincBackendDir
# createDir
# copyDir

#[
for kind, path in walkDir(kincDir):
  #echo type kind
  #echo(path)
  if kind == PathComponent.pcDir:
    #echo path
    #echo kniDir
    var
      path = path.splitPath
    #echo path.tail
    discard existsOrCreateDir(kniDir & path.tail)
]#

proc folderMirrorHierarchy(src: string, dest: string, extraTail: string = "") =  
  for directory in walkDirRec(src, {pcDir}):
    #echo directory
    #echo src
    let
      distance = src.len
      longTail = directory[distance..<directory.len]
    discard existsOrCreateDir(dest & longTail & extraTail)

# mirror sources folder hierarchy
folderMirrorHierarchy(kincDir, kniDir)

# mirror backends folder hierarchy
folderMirrorHierarchy(kincBackendDir, kniBackendDir, "/kni/")
