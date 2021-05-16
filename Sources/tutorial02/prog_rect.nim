#[
  build commands:
    dynamic:
      nim -d:dynamic -d:direct3d11 Sources/build.nims Sources/tutorial02/prog.nim
    codegen:
      nim -d:codegen -d:direct3d11 Sources/build.nims Sources/tutorial02/prog.nim
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
  vertices: array[18, float32] = [
    -1.0'f32, -1.0, 0.0, #0
     1.0, -1.0, 0.0, #1
    -1.0,  1.0, 0.0, #2
     
     1.0,  1.0, 0.0, #3
     1.0, -1.0, 0.0, #1
    -1.0,  1.0, 0.0, #2
  ]

  indices: array[6, int32] = [
    0'i32,
    1,
    2,
    1,
    3,
    2,
  ]
  vertexBuff: VertexBuffer
  indexBuff: IndexBuffer
  pipe: Pipeline
  vertex_shader: Shader
  fragment_shader: Shader

proc loadShader(filename: cstring, shader: ptr Shader, shader_type: ShaderType) =
  var file: fileReader 
  discard fileReaderOpen(file.addr, filename, FileTypeAsset)
  var
    data_size: csize_t = fileReaderSize(file.addr)
    data: ptr uint8 = cast[ptr uint8](alloc(data_size))
  discard fileReaderRead(file.addr, data, data_size)
  fileReaderClose(file.addr)
  initShader(shader, data, data_size, shader_type)

proc update {.cdecl.} =
  g4Begin(0)
  g4Clear(ClearColor.cuint, ColorBlack.cuint, 0.0f, 0)

  setPipeline(pipe.addr)
  setVertexBuffer(vertexBuff.addr)
  setIndexBuffer(indexBuff.addr)
  g4DrawIndexedVertices()

  g4End(0)
  discard g4SwapBuffers()

proc nim_start() {.exportc.} =
  discard init("Shader", 1024, 768, nil, nil)
  setUpdateCallback(update)

  loadShader("shader.vert", vertex_shader.addr, stVertex)
  loadShader("shader.frag", fragment_shader.addr, stFragment)

  var 
    structure: VertexStructure
  initVertexStructure(structure.addr)
  vertexStructureAdd(structure.addr, "pos", vdFloat3)
  const structureLength = 3
  
  initPipeline(pipe.addr)
  pipe.vertex_shader = vertex_shader.addr
  pipe.fragment_shader = fragment_shader.addr
  pipe.input_layout[0] = structure.addr
  pipe.input_layout[1] = nil  
  pipe.color_attachment_count = 1
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

  initIndexBuffer(indexBuff.addr, indices.len.int32, ibf32bit)
  block:
    var
      indexBufferData = cast[PArray[int32]](indexBufferLock(indexBuff.addr))
    for i in 0 ..< indices.len:
      indexBufferData[i] = indices[i]
    indexBufferUnlock(indexBuff.addr)

  kinc_start()

when defined(dynamic):
  nim_start()
elif defined(codegen):
  echo "nim_start procedure called from C..."