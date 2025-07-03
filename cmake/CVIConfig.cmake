cmake_minimum_required(VERSION 3.20)
find_package(chpl REQUIRED HINTS .)
project(cvi LANGUAGES CHPL)

set(CVI_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")
set(CVI_COMPILE_PY "${CVI_ROOT}/compile.py")

message(STATUS "CVI: Determining compile options...")
message(STATUS "CVI: Using ${CVI_COMPILE_PY} to generate compile options")
execute_process(
  COMMAND "${CVI_COMPILE_PY}"
  OUTPUT_VARIABLE CVI_COMPOPTS_STR
  RESULT_VARIABLE CVI_COMPOPTS_CODE
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT CVI_COMPOPTS_CODE EQUAL 0)
  message(FATAL_ERROR "CVI: Failed to determine proper compile options: ${CVI_COMPOPTS_CODE}")
endif()
message(STATUS "CVI: Compile options: ${CVI_COMPOPTS_STR}")
separate_arguments(CVI_COMPOPTS UNIX_COMMAND "${CVI_COMPOPTS_STR}")
