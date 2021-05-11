import utils/ptrops

import kinc/graphics4/vertexstructure
import kinc/graphics4/vertexbuffer
import kinc/graphics4/graphics
import kinc/graphics4/indexbuffer
import kinc/graphics4/shader
import kinc/graphics4/pipeline
#import g4
import kinc/system
import kinc/io/filereader


#const path = "C:/Users/Administrator/devel-nim/devel-knim/Knim/Deployment/"
const path = ""

var 
  vertex_shader: kinc_g4_shader_t
  fragment_shader: kinc_g4_shader_t
  pipe: kinc_g4_pipeline_t
  vertices: kinc_g4_vertex_buffer_t
  indices: kinc_g4_index_buffer_t

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
  # var matrix: kinc_matrix3x3_t  = kinc_matrix3x_rotation_z(kinc_time());
  # kinc_g4_set_matrix3(offset, matrix.addr)
  kinc_g4_set_vertex_buffer(vertices.addr)
  kinc_g4_set_index_buffer(indices.addr)
  # kinc_g4_set_texture(texunit, texture.addr)
  kinc_g4_draw_indexed_vertices()

  kinc_g4_end(0)
  discard kinc_g4_swap_buffers()

proc nim_start() {.exportc.} =
  discard kinc_init("Shader", 1024, 768, nil, nil)
  kinc_set_update_callback(update)
  
  # DeploymentN Sources
  load_shader(path&"shader.vert", vertex_shader.addr, KINC_G4_SHADER_TYPE_VERTEX)
  load_shader(path&"shader.frag", fragment_shader.addr, KINC_G4_SHADER_TYPE_FRAGMENT)

  var structure: kinc_g4_vertex_structure_t
  kinc_g4_vertex_structure_init(structure.addr)
  kinc_g4_vertex_structure_add(structure.addr, "pos", KINC_G4_VERTEX_DATA_FLOAT3)
  kinc_g4_pipeline_init(pipe.addr)
  pipe.vertex_shader = vertex_shader.addr
  pipe.fragment_shader = fragment_shader.addr
  pipe.input_layout[0] = structure.addr
  pipe.input_layout[1] = nil  
  kinc_g4_pipeline_compile(pipe.addr)

  kinc_g4_vertex_buffer_init(vertices.addr, 3, structure.addr, KINC_G4_USAGE_STATIC, 0)
  block:
    var
      v: ptr cfloat = kinc_g4_vertex_buffer_lock_all(vertices.addr)
      #v = cast[ptr UncheckedArray[cfloat]](kinc_g4_vertex_buffer_lock_all(vertices.addr))
      i = 0
    
    v[i] = -1
    i += 1

    v[i] = -1
    i += 1

    v[i] = 0.5
    i += 1


    v[i] = 1
    i += 1

    v[i] = -1
    i += 1

    v[i] = 0.5
    i += 1


    v[i] = -1
    i += 1

    v[i] = 1
    i += 1

    v[i] = 0.5
    i += 1
    kinc_g4_vertex_buffer_unlock_all(vertices.addr)

  kinc_g4_index_buffer_init(indices.addr, 3, KINC_G4_INDEX_BUFFER_FORMAT_32BIT)
  block:
    var
      i: ptr cint = kinc_g4_index_buffer_lock(indices.addr)
      #i = cast[ptr UncheckedArray[cint]](kinc_g4_vertex_buffer_lock_all(vertices.addr))
      #i = cast[ptr UncheckedArray[cint]](kinc_g4_vertex_buffer_lock_all(vertices.addr).addr)

      iter = 0
    
    i[0] = 0
    i[1] = 1
    i[2] = 2
    kinc_g4_index_buffer_unlock(indices.addr)

  kinc_start()

nim_start()