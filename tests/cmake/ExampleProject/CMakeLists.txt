cmake_minimum_required(VERSION 3.20)
find_package(chpl REQUIRED)

project(ExampleProject LANGUAGES CHPL)
add_executable(ExampleProject main.chpl)
install(TARGETS ExampleProject DESTINATION bin)

set(CVI_SOURCE_DIR "" CACHE PATH "Path to the CVI source directory")
if (NOT CVI_SOURCE_DIR STREQUAL "")
  message(STATUS "Using CVI from: ${CVI_SOURCE_DIR}")
  include("${CVI_SOURCE_DIR}/cmake/CVIConfig.cmake")
endif()

find_package(CVI CONFIG)

if(NOT CVI_FOUND)
  message("CVI not found, cloning it...")
  include(FetchContent)
  FetchContent_Declare(
    CVI
    GIT_REPOSITORY https://github.com/jabraham17/cvi.git
    GIT_BRANCH main
    GIT_TAG main
    GIT_SHALLOW TRUE
  )
  FetchContent_MakeAvailable(CVI)
  # After FetchContent, the CVI source is available
  # Include the CVIConfig.cmake manually from the fetched content
  FetchContent_GetProperties(CVI SOURCE_DIR CVI_SOURCE_DIR_FETCHED)
  include("${CVI_SOURCE_DIR_FETCHED}/cmake/CVIConfig.cmake")
  find_package(CVI REQUIRED CONFIG)
endif()

target_link_options(ExampleProject PRIVATE ${CVI_COMPOPTS})
