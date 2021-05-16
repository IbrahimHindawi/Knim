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
  g4Begin(0)
  g4Clear(ClearColor.cuint, ColorBlack.cuint, 0.0f, 0)
  g4End(0)
  discard g4SwapBuffers()

proc nim_start() {.exportc.} =
  discard init("Shader", 1024, 768, nil, nil)
  setUpdateCallback(update)
  kincStart()

when defined(dynamic):
  nim_start()
elif defined(codegen):
  echo "nim_start procedure called from C..."