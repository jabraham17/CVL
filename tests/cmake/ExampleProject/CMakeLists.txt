cmake_minimum_required(VERSION 3.20)
find_package(chpl REQUIRED)

project(ExampleProject LANGUAGES CHPL)
add_executable(ExampleProject main.chpl)
install(TARGETS ExampleProject DESTINATION bin)

set(CVI_SOURCE_DIR "" CACHE PATH "Path to the CVI source directory")


find_package(CVI CONFIG HINTS ${CVI_SOURCE_DIR})
if (NOT CVI_FOUND)
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
  FetchContent_GetProperties(CVI SOURCE_DIR CVI_SOURCE_DIR_FETCHED)
  find_package(CVI REQUIRED CONFIG HINTS ${CVI_SOURCE_DIR_FETCHED})
endif()
target_link_libraries(ExampleProject PRIVATE cvi)
