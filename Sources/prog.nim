#[
  build commands:
    dynamic:
      nim -d:dynamic -d:direct3d11 Sources/build.nims Sources/prog.nim
    codegen:
      nim -d:codegen -d:direct3d11 Sources/build.nims Sources/prog.nim
]#

import kinc/graphics4/graphics
import kinc/graphics4/pipeline
import kinc/graphics4/vertexstructure
import kinc/graphics4/vertexbuffer
import kinc/graphics4/indexbuffer
import kinc/graphics4/shader
import kinc/io/filereader
import kinc/system
import kinc/color

type
  PArray[T] = ptr UncheckedArray[T]

var 
  vertices: array[9, float32] = [
    -0.5'f32, -0.5, 0.0, #0
     0.5, -0.5, 0.0, #1
     0.0,  0.5, 0.0, #2
  ]
  indices: array[3, int32] = [
    0'i32,
    1,
    2,
  ]
  vertexBuff: VertexBuffer
  indexBuff: IndexBuffer
  pipe: Pipeline
  vertexShader: Shader
  fragmentShader: Shader

proc loadShader(fileName: cstring, shader: ptr Shader, shaderType: ShaderType) =
  var file: fileReader 
  discard fileReaderOpen(file.addr, fileName, FileTypeAsset)
  var
    dataSize: csize_t = fileReaderSize(file.addr)
    data: ptr uint8 = cast[ptr uint8](alloc(dataSize))
  discard fileReaderRead(file.addr, data, dataSize)
  fileReaderClose(file.addr)
  initShader(shader, data, dataSize, shaderType)

proc update {.cdecl.} =
  g4Begin(0)
  g4Clear(ClearColor.cuint, 0xFF304040.cuint, 0.0f, 0)

  setPipeline(pipe.addr)
  setVertexBuffer(vertexBuff.addr)
  setIndexBuffer(indexBuff.addr)
  g4DrawIndexedVertices()

  g4End(0)
  discard g4SwapBuffers()

proc nim_start() {.exportc.} =
  discard kincInit("Shader", 1024, 768, nil, nil)
  setUpdateCallback(update)

  loadShader("shader.vert", vertexShader.addr, stVertex)
  loadShader("shader.frag", fragmentShader.addr, stFragment)

  var structure: VertexStructure
  initVertexStructure(structure.addr)
  vertexStructureAdd(structure.addr, "pos", vdFloat3)
  const structureLength = 3
  
  initPipeline(pipe.addr)
  pipe.vertexShader = vertexShader.addr
  pipe.fragmentShader = fragmentShader.addr
  pipe.inputLayout[0] = structure.addr
  pipe.inputLayout[1] = nil  
  pipe.colorAttachmentCount = 1
  pipelineCompile(pipe.addr)

  initVertexBuffer(vertexBuff.addr,
                  (vertices.len/structureLength).cint, # number of points
                  structure.addr,
                  uStatic, 0)
  block:
    var
      vertexBufferData = cast[PArray[float32]](vertexBufferLockAll(vertexBuff.addr))
    for i in 0 ..< vertices.len:
      vertexBufferData[i] = vertices[i]
    vertexBufferUnlockAll(vertexBuff.addr)

  initIndexBuffer(indexBuff.addr, 
                  indices.len.int32,
                  ibf32bit)
  block:
    var
      indexBufferData = cast[PArray[int32]](indexBufferLock(indexBuff.addr))
    for i in 0 ..< indices.len:
      indexBufferData[i] = indices[i]
    indexBufferUnlock(indexBuff.addr)

  kincStart()

when defined(dynamic):
  nim_start()
elif defined(codegen):
  echo "nim_start procedure called from C..."