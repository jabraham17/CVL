cmake_minimum_required(VERSION 3.20)
find_package(chpl REQUIRED)
project(cvl LANGUAGES CHPL)

set(CVL_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")
set(CVL_COMPILE_PY "${CVL_ROOT}/compile.py")

message(STATUS "CVL: Determining compile options...")
message(STATUS "CVL: Using ${CVL_COMPILE_PY} to generate compile options")
execute_process(
  COMMAND "${CVL_COMPILE_PY}"
  OUTPUT_VARIABLE CVL_COMPOPTS_STR
  RESULT_VARIABLE CVL_COMPOPTS_CODE
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT CVL_COMPOPTS_CODE EQUAL 0)
  message(FATAL_ERROR "CVL: Failed to determine proper compile options: ${CVL_COMPOPTS_CODE}")
endif()
message(STATUS "CVL: Compile options: ${CVL_COMPOPTS_STR}")
separate_arguments(CVL_COMPOPTS UNIX_COMMAND "${CVL_COMPOPTS_STR}")

add_library(cvl INTERFACE)
target_link_options(cvl INTERFACE ${CVL_COMPOPTS})
