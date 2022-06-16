if (pytorch_included)
    MESSAGE("pytorch already included")
    return()
endif(pytorch_included)
#Adding this variable to prevent the duplicate includes.
set(pytorch_included true)

set(CMAKE_CXX_STANDARD 14)

include(ExternalProject)
#set(PYTORCH_ROOT "${TORCH_MLIR_ROOT}/thirdparty/pytorch")
set(PYTORCH_ROOT "https://github.com/pytorch/pytorch")

set(TORCH_LIBRARIES torch_cpu cpuinfo clog)

execute_process(COMMAND which python3 OUTPUT_VARIABLE PYTHON_BIN)
file(REAL_PATH /usr/bin/python3 PYTHON_BINARY)

find_package (Python3 COMPONENTS Interpreter)
message("Python binary being used is: ${Python3_EXECUTABLE}")

#set(PYTORCH_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -fvisibility-inlines-hidden -Werror=date-time -Werror=unguarded-availability-new -Wall -Wextra -Wno-unused-parameter -Wwrite-strings -Wcast-qual -Wmissing-field-initializers -pedantic -Wno-long-long -Wc++98-compat-extra-semi -Wimplicit-fallthrough -Wcovered-switch-default -Wno-noexcept-type -Wnon-virtual-dtor -Wdelete-non-virtual-dtor -Wsuggest-override -Wstring-conversion -Wmisleading-indentation -fdiagnostics-color -Wno-deprecated -Wno-deprecated-declarations -Wno-narrowing -Wall -Wextra -Werror=return-type -Wno-missing-field-initializers -Wno-type-limits -Wno-array-bounds -Wno-unknown-pragmas -Wno-unused-function -Wno-unused-result -Wno-strict-overflow -Wno-strict-aliasing -Wno-range-loop-analysis -Wno-pass-failed -Wno-error=pedantic -Wno-error=redundant-decls -Wno-error=old-style-cast -Wno-invalid-partial-specialization -Wno-typedef-redefinition -Wno-unknown-warning-option -Wno-unused-private-field -Wno-inconsistent-missing-override -Wno-aligned-allocation-unavailable -Wno-c++14-extensions -Wno-constexpr-not-const -Wno-missing-braces -Qunused-arguments -fcolor-diagnostics -fno-math-errno -fno-trapping-math -Werror=format -Werror=cast-function-type -Wno-unused-private-field -Wno-missing-braces -Wno-c++14-extensions -Wno-constexpr-not-const -std=gnu++14")

#set(PYTORCH_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated -fvisibility-inlines-hidden -O2 -fPIC -Wno-narrowing -Wall -Wextra -Werror=return-type -Wno-missing-field-initializers -Wno-type-limits -Wno-array-bounds -Wno-unknown-pragmas -Wno-unused-parameter -Wno-unused-function -Wno-unused-result -Wno-strict-overflow -Wno-strict-aliasing -Wno-error=deprecated-declarations -Wno-range-loop-analysis -Wno-pass-failed -Wno-error=pedantic -Wno-error=redundant-decls -Wno-error=old-style-cast -Wno-invalid-partial-specialization -Wno-typedef-redefinition -Wno-unknown-warning-option -Wno-unused-private-field -Wno-inconsistent-missing-override -Wno-aligned-allocation-unavailable -Wno-c++14-extensions -Wno-constexpr-not-const -Wno-missing-braces -Qunused-arguments -fcolor-diagnostics -Wno-unused-but-set-variable -Wno-maybe-uninitialized -fno-math-errno -fno-trapping-math -Werror=format -Werror=cast-function-type")

set(PYTORCH_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-error,-Wc++98-compat-extra-semi -Wno-error,-Wgnu-zero-variadic-macro-arguments")

list(APPEND PYTORCH_FLAGS
	-DPYTHON_EXECUTABLE=${Python3_EXECUTABLE}
	-DBUILD_PYTHON=OFF
        -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
        -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_FLAGS=${PYTORCH_CXX_FLAGS}
	-DCMAKE_CXX_STANDARD=14
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/pytorch-install
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TEST=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_PYTHON=ON
        -DUSE_MKLDNN=OFF
        -DUSE_CUDA=OFF
        -DBUILD_LAZY_TS_BACKEND=OFF
        -DUSE_GLOO=OFF
        -DUSE_DISTRIBUTED=OFF
        -DUSE_XNNPACK=OFF
        -DUSE_QNNPACK=OFF
        -DUSE_PYTORCH_QNNPACK=OFF
        -DUSE_NNPACK=OFF
        -DUSE_NUMPY=OFF
        -DUSE_OBSERVERS=OFF
        -DUSE_KINETO=OFF
        -DUSE_EIGEN_FOR_BLAS=OFF
        -DUSE_FBGEMM=OFF
        -D_GLIBCXX_USE_CXX11_ABI=1
        -DUSE_NCCL=OFF
        -DUSE_MPS=OFF
        -DONNX_ML=OFF
        -DBUILD_CAFFE2=OFF
        -DUSE_NUMA=OFF
        -DUSE_FAKELOWP=OFF
        -DUSE_BREAKPAD=OFF
        -DUSE_PYTORCH_QNNPACK=OFF
        -DUSE_KINETO=OFF
	-DINTERN_DISABLE_ONNX=OFF
	-DUSE_SLEEF_FOR_ARM_VEC256:BOOL=OFF
	-DCAFFE2_USE_MSVC_STATIC_RUNTIME=OFF
        -S ${CMAKE_CURRENT_BINARY_DIR}/ext/src/pytorch
        )

execute_process(COMMAND git rev-parse HEAD
        WORKING_DIRECTORY ${PYTORCH_ROOT}
        OUTPUT_VARIABLE PY_GIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE)

add_library(libtorch SHARED IMPORTED GLOBAL)
set_target_properties(libtorch PROPERTIES
        IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/pytorch-install/lib/libtorch.a
        )

if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/pytorch-install/lib/libtorch.a)
        message(STATUS "Pytorch Built, skipping Step, delete pytorch-install to rebuild Pytorch")
else()
        ExternalProject_Add(pytorch
                PREFIX ext
                SOURCE_DIR ext/src/pytorch
                GIT_REPOSITORY ${PYTORCH_ROOT}
                GIT_TAG main
                BUILD_BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/pytorch-install/lib/libtorch.a
                INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/pytorch-install
                CMAKE_ARGS ${PYTORCH_FLAGS}
                )
        add_dependencies(libtorch pytorch)
endif()

set(TORCH_LIB_DIR ${CMAKE_CURRENT_BINARY_DIR}/pytorch-install/lib)
set(TORCH_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/pytorch-install/include)
set(TORCH_HEADERS_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/pytorch-install/include/torch/csrc/api/include
    ${CMAKE_CURRENT_BINARY_DIR}/pytorch-install/include)
message("TORCH LIBS: ${TORCH_LIBRARIES}")
link_directories(${TORCH_LIB_DIR})
include_directories(${TORCH_INCLUDE_DIR} ${TORCH_HEADERS_INCLUDE_DIR})
