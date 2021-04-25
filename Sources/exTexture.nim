import ptrops

import ../Kinc/Sources/kinc/input/input
import ../Kinc/Sources/kinc/graphics4/g4
import ../Kinc/Sources/kinc/system
import ../Kinc/Sources/kinc/io/filereader
import ../Kinc/Sources/kinc/image
import ../Kinc/Sources/kinc/math/matrix

var 
  vertex_shader: kinc_g4_shader_t
  fragment_shader: kinc_g4_shader_t
  pipe: g4.kinc_g4_pipeline_t
  vertices: kinc_g4_vertex_buffer_t
  indices: kinc_g4_index_buffer_t
  texture: kinc_g4_texture_t
  texunit: kinc_g4_texture_unit_t
  offset: kinc_g4_constant_location_t

const
  heapsize = 1024 * 1024
var
  heap: ptr uint8 = nil
  heap_top: csize_t = 0

proc allocate(size: csize_t): pointer =
  var old_top = heap_top
  heap_top += size
  assert(heap_top <= heapsize)
  return cast[pointer](cast[uint8](heap) + old_top)

proc load_shader(filename: cstring, shader: ptr kinc_g4_shader_t, shader_type: kinc_g4_shader_type_t) =
  var file: kinc_file_reader_t 
  discard kinc_file_reader_open(file.addr, filename, KINC_FILE_TYPE_ASSET)
  var
    data_size: csize_t = kinc_file_reader_size(file.addr)
    data: ptr uint8 = cast[ptr uint8](alloc(data_size))#create(uint8)
    #data: uint8 
  discard kinc_file_reader_read(file.addr, data, data_size)
  kinc_file_reader_close(file.addr)
  kinc_g4_shader_init(shader, data, data_size, shader_type)

proc update {.cdecl.} =
  kinc_g4_begin(0)
  kinc_g4_clear(1, 0, 0.0f, 0)

  kinc_g4_set_pipeline(pipe.addr)
  var
    matrix: kinc_matrix3x3_t  = kinc_matrix3x_rotation_z(kinc_time().float);
  kinc_g4_set_matrix3(offset, matrix.addr)
  kinc_g4_set_vertex_buffer(vertices.addr)
  kinc_g4_set_index_buffer(indices.addr)
  kinc_g4_set_texture(texunit, texture.addr)
  kinc_g4_draw_indexed_vertices()

  kinc_g4_end(0)
  discard kinc_g4_swap_buffers()

proc kickstart() =
  discard kinc_init("Shader", 1024, 768, nil, nil)
  kinc_set_update_callback(update)

  block:
    var
      image: kinc_image_t
      image_mem: pointer = alloc(250 * 250 * 4)
    discard kinc_image_init_from_file(image.addr, image_mem, "parrot.png")
    kinc_g4_texture_init_from_image(texture.addr, image.addr)
    kinc_image_destroy(image.addr)

  block:
    var reader: kinc_file_reader_t
    discard kinc_file_reader_open(reader.addr, "texture.vert", KINC_FILE_TYPE_ASSET)
    var
      size = kinc_file_reader_size(reader.addr)
      data: ptr uint8 = cast[ptr uint8](alloc(size))
    discard kinc_file_reader_read(reader.addr, data, size)
    kinc_file_reader_close(reader.addr)

    kinc_g4_shader_init(vertexShader.addr, data, size, KINC_G4_SHADER_TYPE_VERTEX)

  block:
    var reader: kinc_file_reader_t
    discard kinc_file_reader_open(reader.addr, "texture.frag", KINC_FILE_TYPE_ASSET)
    var
      size = kinc_file_reader_size(reader.addr)
      data: ptr uint8 = cast[ptr uint8](alloc(size))
    discard kinc_file_reader_read(reader.addr, data, size)
    kinc_file_reader_close(reader.addr)

    kinc_g4_shader_init(fragmentShader.addr, data, size, KINC_G4_SHADER_TYPE_FRAGMENT)
  
  # DeploymentN Sources
  #load_shader("DeploymentN/shader.vert", vertex_shader.addr, KINC_G4_SHADER_TYPE_VERTEX)
  #load_shader("DeploymentN/shader.frag", fragment_shader.addr, KINC_G4_SHADER_TYPE_FRAGMENT)

  var structure: kinc_g4_vertex_structure_t
  kinc_g4_vertex_structure_init(structure.addr)
  kinc_g4_vertex_structure_add(structure.addr, "pos", KINC_G4_VERTEX_DATA_FLOAT3)
  kinc_g4_vertex_structure_add(structure.addr, "tex", KINC_G4_VERTEX_DATA_FLOAT2)
  kinc_g4_pipeline_init(pipe.addr)
  pipe.input_layout[0] = structure.addr
  pipe.input_layout[1] = nil  
  pipe.vertex_shader = vertex_shader.addr
  pipe.fragment_shader = fragment_shader.addr
  kinc_g4_pipeline_compile(pipe.addr)

  texunit = kinc_g4_pipeline_get_texture_unit(pipe.addr, "texsampler")
  offset = kinc_g4_pipeline_get_constant_location(pipe.addr, "mvp")

  kinc_g4_vertex_buffer_init(vertices.addr, 3, structure.addr, KINC_G4_USAGE_STATIC, 0)
  var v: ptr cfloat = kinc_g4_vertex_buffer_lock_all(vertices.addr)
  v[0] = -1.0f
  v[1] = -1.0f
  v[2] = 0.5f
  v[3] = 0.0f
  v[4] = 1.0f
  v[5] = 1.0f
  v[6] = -1.0f
  v[7] = 0.5f
  v[8] = 1.0f
  v[9] = 1.0f
  v[10] = -1.0f
  v[11] = 1.0f
  v[12] = 0.5f
  v[13] = 0.0f
  v[14] = 0.0f
  kinc_g4_vertex_buffer_unlock_all(vertices.addr)

  kinc_g4_index_buffer_init(indices.addr, 3, KINC_G4_INDEX_BUFFER_FORMAT_32BIT)
  var i: ptr cint = kinc_g4_index_buffer_lock(indices.addr)
  i[0] = 0
  i[1] = 1
  i[2] = 2
  kinc_g4_index_buffer_unlock(indices.addr)

  kinc_start()

kickstart()