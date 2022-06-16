#-------------------------------------------------------------------------------
# Setup PyTorch
#-------------------------------------------------------------------------------

message("Setting up Eager mode Module PATH: ${CMAKE_MODULE_PATH}")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")
message("Updated Module PATH: ${CMAKE_MODULE_PATH}")
include(pytorch)

#-------------------------------------------------------------------------------
# Subdirectories
#-------------------------------------------------------------------------------

add_subdirectory(csrc)

## Declare the sources of the Python module.

declare_mlir_python_sources(TorchMLIRPythonSources.JitIRImporter
  ROOT_DIR "${TORCH_MLIR_PYTHON_ROOT_DIR}"
  ADD_TO_PARENT TorchMLIRPythonSources
  SOURCES_GLOB
    dialects/torch/importer/jit_ir/*.py
)
