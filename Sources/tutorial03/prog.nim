#[
  build commands:
    dynamic:
      nim -d:dynamic -d:direct3d11 Sources/build.nims Sources/tutorial03/prog.nim
    codegen:
      nim -d:codegen -d:direct3d11 Sources/build.nims Sources/tutorial03/prog.nim
]#

import kinc/graphics4/graphics
import kinc/graphics4/pipeline
import kinc/graphics4/vertexstructure
import kinc/graphics4/vertexbuffer
import kinc/graphics4/indexbuffer
import kinc/graphics4/shader
import kinc/graphics4/constantlocation
import kinc/math/matrix
#import kinc/math/vector
import kinc/io/filereader
import kinc/image
import kinc/system
import kinc/color

import glm

proc translate_matrix(kincMatrix: var kinc_matrix4x4_t, glmMatrix: Mat4x4): kinc_matrix4x4_t =
  kincMatrix.m[0] = glmMatrix[0][0]
  kincMatrix.m[1] = glmMatrix[0][1]
  kincMatrix.m[2] = glmMatrix[0][2]
  kincMatrix.m[3] = glmMatrix[0][3]
  kincMatrix.m[4] = glmMatrix[1][0]
  kincMatrix.m[5] = glmMatrix[1][1]
  kincMatrix.m[6] = glmMatrix[1][2]
  kincMatrix.m[7] = glmMatrix[1][3]
  kincMatrix.m[8] = glmMatrix[2][0]
  kincMatrix.m[9] = glmMatrix[2][1]
  kincMatrix.m[10] = glmMatrix[2][2]
  kincMatrix.m[11] = glmMatrix[2][3]
  kincMatrix.m[12] = glmMatrix[3][0]
  kincMatrix.m[13] = glmMatrix[3][1]
  kincMatrix.m[14] = glmMatrix[3][2]
  kincMatrix.m[15] = glmMatrix[3][3]
  result = kincMatrix

type
  PArray[T] = ptr UncheckedArray[T]
var 
  vertices: array[9, float32] = [
    -1.0'f32, -1.0, 0.0,
     1.0, -1.0, 0.0,
     0.0,  1.0, 0.0
  ]
  indices: array[3, int32] = [
    0'i32,
    1,
    2
  ]
  vertexBuff: VertexBuffer
  indexBuff: IndexBuffer
  pipe: Pipeline

  vertex_shader: Shader
  fragment_shader: Shader

  mvp = mat4(1.0f)
  kmvp: kinc_matrix4x4_t
  mvpID: kinc_g4_constant_location_t

proc load_shader(filename: cstring, shader: ptr Shader, shader_type: ShaderType) =
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
  g4Clear(ClearColor.cuint, ColorBlue.cuint, 0.0f, 0)

  setVertexBuffer(vertexBuff.addr)
  setIndexBuffer(indexBuff.addr)
  setPipeline(pipe.addr)

  kmvp = translate_matrix(kmvp, mvp)
  kinc_g4_set_matrix4(mvpID, kmvp.addr)

  g4DrawIndexedVertices()

  g4End(0)
  discard g4SwapBuffers()

proc nim_start() {.exportc.} =
  discard init("Shader", 1024, 768, nil, nil)
  setUpdateCallback(update)

  load_shader("mvp.vert", vertex_shader.addr, stVertex)
  load_shader("mvp.frag", fragment_shader.addr, stFragment)

  var structure: VertexStructure
  initVertexStructure(structure.addr)
  vertexStructureAdd(structure.addr, "pos", vdFloat3)
  const structureLength = 3

  initPipeline(pipe.addr)
  var imgfmt: kinc_image_format_t
  pipe.vertex_shader = vertex_shader.addr
  pipe.fragment_shader = fragment_shader.addr
  pipe.input_layout[0] = structure.addr
  pipe.input_layout[1] = nil  
  pipe.color_attachment_count = 1
  #pipe.color_attachment[0] = imgfmt.KINC_IMAGE_FORMAT_RGBA32
  pipelineCompile(pipe.addr)

  mvpID = pipelineGetConstantLocation(pipe.addr, "MVP")

  var
    model = mat4(1.0f)
    view = lookAt(vec3(4.0f, 4.0f, -3.0f), 
                vec3(0.0f, 0.0f, 0.0f), 
                vec3(0.0f, 1.0f, 0.0f))
    projection = perspective(radians(45.0f), 4.0f/3.0f, 0.1f, 100.0f)

  mvp = model * projection * view

  initVertexBuffer(vertexBuff.addr, (vertices.len/structureLength).cint, structure.addr, uStatic, 0)
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
      indexBufferData[i] = indices[i].int32

    indexBufferUnlock(indexBuff.addr)

  kinc_start()

when defined(dynamic):
  nim_start()
elif defined(codegen):
  echo "nim_start procedure called from C..."


  # var
  #   ##mvp: kinc_matrix4x4_t = kinc_matrix4x4_identity() ## weirdness
  #   projection: kinc_matrix4x4_t = kinc_matrix4x4_perspective(45.0, 4.0/3.0, 0.1, 100.0)
  #   view: kinc_matrix4x4_t = kinc_matrix4x4_look_at(kinc_vector3_new(4,3,3), 
  #                                                   kinc_vector3_new(0,0,0), 
  #                                                   kinc_vector3_new(0,1,0))
  #   model: kinc_matrix4x4_t = kinc_matrix4x4_identity()

  
  # mvp = kinc_matrix4x4_multiply(mvp.addr, projection.addr)
  # ##mvp = kinc_matrix4x4_multiply(mvp.addr, view.addr)
  # mvp = kinc_matrix4x4_multiply(mvp.addr, model.addr)
  
  
  # for n in 0 ..< 4*4:
  #   if n mod 4 == 0:
  #     echo ""
  #   stdout.write mvp[n], ", "
  # echo ""