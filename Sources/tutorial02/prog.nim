#[
  build commands:
    dynamic:
      nim -d:dynamic -d:direct3d11 Sources/build.nims Sources/tutorial02/prog.nim
    codegen:
      nim -d:codegen -d:direct3d11 Sources/build.nims Sources/tutorial02/prog.nim
]#

#import utils/ptrops
import kinc/graphics4/graphics
import kinc/graphics4/pipeline
import kinc/graphics4/vertexstructure
import kinc/graphics4/vertexbuffer
import kinc/graphics4/indexbuffer
import kinc/graphics4/shader
import kinc/io/filereader
import kinc/image
import kinc/system
import kinc/color

var 
  vertices: seq[float32] = @[
    -1.0'f32, -1.0, 0.0,
     1.0, -1.0, 0.0,
     0.0,  1.0, 0.0
  ]
  indices: seq[int] = @[
    0,
    1,
    2
  ]
  vertexBuff: kinc_g4_vertex_buffer_t
  indexBuff: kinc_g4_index_buffer_t
  pipe: kinc_g4_pipeline_t
  vertex_shader: kinc_g4_shader_t
  fragment_shader: kinc_g4_shader_t

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
  kinc_g4_clear(kinc_g4_clear_color.cuint, KINC_COLOR_BLACK.cuint, 0.0f, 0)

  kinc_g4_set_pipeline(pipe.addr)
  kinc_g4_set_vertex_buffer(vertexBuff.addr)
  kinc_g4_set_index_buffer(indexBuff.addr)
  kinc_g4_draw_indexed_vertices()

  kinc_g4_end(0)
  discard kinc_g4_swap_buffers()

proc nim_start() {.exportc.} =
  discard kinc_init("Shader", 1024, 768, nil, nil)
  kinc_set_update_callback(update)

  load_shader("shader.vert", vertex_shader.addr, KINC_G4_SHADER_TYPE_VERTEX)
  load_shader("shader.frag", fragment_shader.addr, KINC_G4_SHADER_TYPE_FRAGMENT)

  var 
    structure: kinc_g4_vertex_structure_t
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
  #pipe.depth_
  kinc_g4_pipeline_compile(pipe.addr)

  kinc_g4_vertex_buffer_init(vertexBuff.addr, (vertices.len/3).cint, structure.addr, KINC_G4_USAGE_STATIC, 0)
  block:
    var
      #vtx: ptr cfloat = kinc_g4_vertex_buffer_lock_all(vertexBuff.addr)
      #i = 0
      vtx = cast[ptr UncheckedArray[cfloat]](kinc_g4_vertex_buffer_lock_all(vertexBuff.addr))
    for i in 0 ..< vertices.len:
      vtx[i] = vertices[i]

    kinc_g4_vertex_buffer_unlock_all(vertexBuff.addr)

  kinc_g4_index_buffer_init(indexBuff.addr, 3, KINC_G4_INDEX_BUFFER_FORMAT_32BIT)
  block:
    var
      #idx: ptr cint = kinc_g4_index_buffer_lock(indexBuff.addr)
      idx = cast[ptr UncheckedArray[cint]](kinc_g4_index_buffer_lock(indexBuff.addr))
    for i in 0 ..< indices.len:
      idx[i] = indices[i].cint

    kinc_g4_index_buffer_unlock(indexBuff.addr)

  kinc_start()

when defined(dynamic):
  nim_start()
elif defined(codegen):
  echo "nim_start procedure called from C..."