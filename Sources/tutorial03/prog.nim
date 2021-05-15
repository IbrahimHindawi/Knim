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
  vertexBuff: kinc_g4_vertex_buffer_t
  indexBuff: kinc_g4_index_buffer_t
  pipe: kinc_g4_pipeline_t

  vertex_shader: kinc_g4_shader_t
  fragment_shader: kinc_g4_shader_t

  mvp = mat4(1.0f)
  kmvp: kinc_matrix4x4_t
  mvpID: kinc_g4_constant_location_t

proc load_shader(filename: cstring, shader: ptr kinc_g4_shader_t, shader_type: kinc_g4_shader_type_t) =
  var file: kinc_file_reader_t 
  discard kinc_file_reader_open(file.addr, filename, KINC_FILE_TYPE_ASSET)
  var
    data_size: csize_t = kinc_file_reader_size(file.addr)
    data: ptr uint8 = cast[ptr uint8](alloc(data_size))
  discard kinc_file_reader_read(file.addr, data, data_size)
  kinc_file_reader_close(file.addr)
  kinc_g4_shader_init(shader, data, data_size, shader_type)

proc update {.cdecl.} =
  kinc_g4_begin(0)
  kinc_g4_clear(kinc_g4_clear_color.cuint, KINC_COLOR_BLUE.cuint, 0.0f, 0)

  kinc_g4_set_vertex_buffer(vertexBuff.addr)
  kinc_g4_set_index_buffer(indexBuff.addr)
  kinc_g4_set_pipeline(pipe.addr)

  kmvp = translate_matrix(kmvp, mvp)
  kinc_g4_set_matrix4(mvpID, kmvp.addr)

  kinc_g4_draw_indexed_vertices()

  kinc_g4_end(0)
  discard kinc_g4_swap_buffers()

proc nim_start() {.exportc.} =
  discard kinc_init("Shader", 1024, 768, nil, nil)
  kinc_set_update_callback(update)

  load_shader("mvp.vert", vertex_shader.addr, KINC_G4_SHADER_TYPE_VERTEX)
  load_shader("mvp.frag", fragment_shader.addr, KINC_G4_SHADER_TYPE_FRAGMENT)

  var structure: kinc_g4_vertex_structure_t
  kinc_g4_vertex_structure_init(structure.addr)
  kinc_g4_vertex_structure_add(structure.addr, "pos", KINC_G4_VERTEX_DATA_FLOAT3)
  const structureLength = 3

  kinc_g4_pipeline_init(pipe.addr)
  var imgfmt: kinc_image_format_t
  pipe.vertex_shader = vertex_shader.addr
  pipe.fragment_shader = fragment_shader.addr
  pipe.input_layout[0] = structure.addr
  pipe.input_layout[1] = nil  
  pipe.color_attachment_count = 1
  #pipe.color_attachment[0] = imgfmt.KINC_IMAGE_FORMAT_RGBA32
  kinc_g4_pipeline_compile(pipe.addr)

  mvpID = kinc_g4_pipeline_get_constant_location(pipe.addr, "MVP")

  var
    model = mat4(1.0f)
    view = lookAt(vec3(4.0f, 4.0f, -3.0f), 
                vec3(0.0f, 0.0f, 0.0f), 
                vec3(0.0f, 1.0f, 0.0f))
    projection = perspective(radians(45.0f), 4.0f/3.0f, 0.1f, 100.0f)

  mvp = model * projection * view

  kinc_g4_vertex_buffer_init(vertexBuff.addr, (vertices.len/structureLength).cint, structure.addr, KINC_G4_USAGE_STATIC, 0)
  block:
    var
      vertexBufferData = cast[PArray[float32]](kinc_g4_vertex_buffer_lock_all(vertexBuff.addr))
    for i in 0 ..< vertices.len:
      vertexBufferData[i] = vertices[i]

    kinc_g4_vertex_buffer_unlock_all(vertexBuff.addr)

  kinc_g4_index_buffer_init(indexBuff.addr, 3, KINC_G4_INDEX_BUFFER_FORMAT_32BIT)
  block:
    var
      indexBufferData = cast[PArray[int32]](kinc_g4_index_buffer_lock(indexBuff.addr))
    for i in 0 ..< indices.len:
      indexBufferData[i] = indices[i].int32

    kinc_g4_index_buffer_unlock(indexBuff.addr)

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