#[
  build commands:
    dynamic:
      nim -d:dynamic -d:direct3d11 Sources/build.nims Sources/tutorial04/prog.nim
    codegen:
      nim -d:codegen -d:direct3d11 Sources/build.nims Sources/tutorial04/prog.nim
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

var 
  vertices: seq[float32] = @[
    -1.0'f32,-1.0,-1.0,
    -1.0,-1.0, 1.0,
    -1.0, 1.0, 1.0,

     1.0, 1.0,-1.0,
    -1.0,-1.0,-1.0,
    -1.0, 1.0,-1.0,

     1.0,-1.0, 1.0,
    -1.0,-1.0,-1.0,
     1.0,-1.0,-1.0,

     1.0, 1.0,-1.0,
     1.0,-1.0,-1.0,
    -1.0,-1.0,-1.0,

    -1.0,-1.0,-1.0,
    -1.0, 1.0, 1.0,
    -1.0, 1.0,-1.0,

     1.0,-1.0, 1.0,
    -1.0,-1.0, 1.0,
    -1.0,-1.0,-1.0,

    -1.0, 1.0, 1.0,
    -1.0,-1.0, 1.0,
     1.0,-1.0, 1.0,

     1.0, 1.0, 1.0,
     1.0,-1.0,-1.0,
     1.0, 1.0,-1.0,

     1.0,-1.0,-1.0,
     1.0, 1.0, 1.0,
     1.0,-1.0, 1.0,

     1.0, 1.0, 1.0,
     1.0, 1.0,-1.0,
    -1.0, 1.0,-1.0,

     1.0, 1.0, 1.0,
    -1.0, 1.0,-1.0,
    -1.0, 1.0, 1.0,
    
     1.0, 1.0, 1.0,
    -1.0, 1.0, 1.0,
     1.0,-1.0, 1.0
  ]
  colors: seq[float32] = @[
    0.583'f32,  0.771,  0.014,
    0.609,  0.115,  0.436,
    0.327,  0.483,  0.844,

    0.822,  0.569,  0.201,
    0.435,  0.602,  0.223,
    0.310,  0.747,  0.185,

    0.597,  0.770,  0.761,
    0.559,  0.436,  0.730,
    0.359,  0.583,  0.152,

    0.483,  0.596,  0.789,
    0.559,  0.861,  0.639,
    0.195,  0.548,  0.859,

    0.014,  0.184,  0.576,
    0.771,  0.328,  0.970,
    0.406,  0.615,  0.116,

    0.676,  0.977,  0.133,
    0.971,  0.572,  0.833,
    0.140,  0.616,  0.489,

    0.997,  0.513,  0.064,
    0.945,  0.719,  0.592,
    0.543,  0.021,  0.978,

    0.279,  0.317,  0.505,
    0.167,  0.620,  0.077,
    0.347,  0.857,  0.137,

    0.055,  0.953,  0.042,
    0.714,  0.505,  0.345,
    0.783,  0.290,  0.734,

    0.722,  0.645,  0.174,
    0.302,  0.455,  0.848,
    0.225,  0.587,  0.040,

    0.517,  0.713,  0.338,
    0.053,  0.959,  0.120,
    0.393,  0.621,  0.362,

    0.673,  0.211,  0.457,
    0.820,  0.883,  0.371,
    0.982,  0.099,  0.879
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

  load_shader("colorcube.vert", vertex_shader.addr, stVertex)
  load_shader("colorcube.frag", fragment_shader.addr, stFragment)

  var structure: VertexStructure
  initVertexStructure(structure.addr)
  vertexStructureAdd(structure.addr, "pos", vdFloat3)
  vertexStructureAdd(structure.addr, "col", vdFloat3)
  const structureLength = 6

  initPipeline(pipe.addr)

  pipe.vertex_shader = vertex_shader.addr
  pipe.fragment_shader = fragment_shader.addr
  
  pipe.input_layout[0] = structure.addr
  pipe.input_layout[1] = nil  

  pipe.depth_write = true
  #pipe.depth_mode = KINC_G4_COMPARE_LESS
  pipe.color_attachment_count = 1

  pipelineCompile(pipe.addr)

  mvpID = pipelineGetConstantLocation(pipe.addr, "MVP")

  var
    model = mat4(1.0f)
    view = lookAt(vec3(4.0f, 4.0f, -3.0f), 
                vec3(0.0f, 0.0f, 0.0f), 
                vec3(0.0f, 1.0f, 0.0f))
    projection = perspective(radians(45.0f), 4.0f/3.0f, 0.1f, 100.0f)

  mvp = model * projection * view

  #echo "cube number of vertices = ", vertices.len
  #echo "cube number of position points = ", (vertices.len / 3).int
  #echo "cube number of color points = ", (colors.len / 3).int
  #echo "cube number of structures = ", (vertices.len / structureLength).int
  #echo "cube number of ??? = ", ((vertices.len/3) / structureLength).int

  initVertexBuffer(vertexBuff.addr, 
                  (vertices.len/3).int32,  
                  structure.addr, 
                  uStatic, 0)
  block:
    var
      vertexBufferData = cast[ptr UncheckedArray[float32]](vertexBufferLockAll(vertexBuff.addr))
      #vtx = cast[seq[float32]](kinc_g4_vertex_buffer_lock_all(vertexBuff.addr))
    for i in 0 ..< ((vertices.len/3)).int:  
      #vertexBufferData[i] = vertices[i]
      # echo "point ", i
      vertexBufferData[i * structureLength] = vertices[i * 3]
      # echo vtx[i * structureLength + 0]
      vertexBufferData[i * structureLength + 1] = vertices[i * 3 + 1]
      # echo vtx[i * structureLength + 1]
      vertexBufferData[i * structureLength + 2] = vertices[i * 3 + 2]
      # echo vtx[i * structureLength + 2]
      vertexBufferData[i * structureLength + 3] = colors[i * 3]
      # echo vtx[i * structureLength + 3]
      vertexBufferData[i * structureLength + 4] = colors[i * 3 + 1]
      # echo vtx[i * structureLength + 4]
      vertexBufferData[i * structureLength + 5] = colors[i * 3 + 2]
      # echo vtx[i * structureLength + 5]

    vertexBufferUnlockAll(vertexBuff.addr)

  var
    indices: seq[int32]
  
  for i in 0 ..< (vertices.len/3).int:
    indices.add(i.int32)

  initIndexBuffer(indexBuff.addr,
                  indices.len.int32,
                  ibf32bit)
  block:
    var
      indexBufferData = cast[ptr UncheckedArray[int32]](indexBufferLock(indexBuff.addr))
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