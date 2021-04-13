#[
  Nim program used to inject JavaScript code into KincMake
]#

import os, strutils

const
  JSproc = "fs.writeFile('Kni/Tools/BuildData/buildData.json', JSON.stringify(project), { flag: 'a+' }, err => {});"

let
  rootDir = getCurrentDir()
  kincfileDir = rootDir & "/Kinc/"
  kincfileName = "kincfile.js"

var
  f: File
if open(f, kincfileDir & kincfileName) == false:
  echo "failed to open file!"
var
  lines = f.readAll
f.close

var
  lineseq = lines.split("\n")
  nlines = lineseq.len

#for line in lineseq:
#  echo line

#if lineseq[nlines - 1] == JSproc:
# echo "JSON payload ready"
#echo lineseq[nlines - 1]
if find(lineseq[nlines - 1], JSproc) > 0:
  echo "JSON export procedure ready!"
else:
  echo "JSON export procedure missing! Adding..."
  var f: File
  if open(f, kincfileDir & kincfileName, fmAppend) == false:
    echo "failed to open file!"
  f.write( JSproc )
  f.close  


