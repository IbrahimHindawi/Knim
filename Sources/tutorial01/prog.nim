#[
  build commands:
    dynamic:
      nim -d:dynamic -d:direct3d11 Sources/build.nims Sources/tutorial01/prog.nim
    codegen:
      nim -d:codegen -d:direct3d11 Sources/build.nims Sources/tutorial01/prog.nim
]#

import kinc/graphics4/graphics
import kinc/system
import kinc/color

proc update {.cdecl.} =
  kinc_g4_begin(0)
  kinc_g4_clear(kinc_g4_clear_color.cuint, KINC_COLOR_BLACK.cuint, 0.0f, 0)
  kinc_g4_end(0)
  discard kinc_g4_swap_buffers()

proc nim_start() {.exportc.} =
  discard kinc_init("Shader", 1024, 768, nil, nil)
  kinc_set_update_callback(update)
  kinc_start()

when defined(dynamic):
  nim_start()
elif defined(codegen):
  echo "nim_start procedure called from C..."