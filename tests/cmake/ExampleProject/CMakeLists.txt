cmake_minimum_required(VERSION 3.20)
find_package(chpl REQUIRED)

project(ExampleProject LANGUAGES CHPL)
add_executable(ExampleProject main.chpl)
install(TARGETS ExampleProject DESTINATION bin)

set(CVL_SOURCE_DIR "" CACHE PATH "Path to the CVL source directory")


find_package(CVL CONFIG HINTS ${CVL_SOURCE_DIR})
if (NOT CVL_FOUND)
  message("CVL not found, cloning it...")
  include(FetchContent)
  FetchContent_Declare(
    CVL
    GIT_REPOSITORY https://github.com/jabraham17/cvl.git
    GIT_BRANCH main
    GIT_TAG main
    GIT_SHALLOW TRUE
  )
  FetchContent_MakeAvailable(CVL)
  FetchContent_GetProperties(CVL SOURCE_DIR CVL_SOURCE_DIR_FETCHED)
  find_package(CVL REQUIRED CONFIG HINTS ${CVL_SOURCE_DIR_FETCHED})
endif()
target_link_libraries(ExampleProject PRIVATE cvl)
