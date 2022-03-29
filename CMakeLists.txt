cmake_minimum_required(VERSION 3.20)

# Determine if wigxjpf is built as a subproject (using add_subdirectory) or if
# it is the master project.
if(NOT DEFINED WIGXJPF_MASTER_PROJECT)
  set(WIGXJPF_MASTER_PROJECT OFF)
  if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(WIGXJPF_MASTER_PROJECT ON)
    message(STATUS "CMake version: ${CMAKE_VERSION}")
  endif()
endif()

project(wigxjpf LANGUAGES C CXX Fortran VERSION 1.11)

if(WIGXJPF_MASTER_PROJECT AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# ##############################################################################
# feature test functions
# ##############################################################################

function(wigxjpf_test_quadmath)
  list(APPEND definitions "-DTEST_FLOAT128=1")
  list(APPEND libraries "quadmath" ${CMAKE_REQUIRED_LIBRARIES})
  list(APPEND libraries "quadmath" ${CMAKE_REQUIRED_LIBRARIES}
       ${WIGXJPF_QUADMATH_LIBRARIES}
  )
  if(NOT DEFINED WIGXJPF_HAS_QUADMATH)
    message(CHECK_START "Checking if quadmath support exists")
    try_compile(
      WIGXJPF_HAS_QUADMATH ${PROJECT_BINARY_DIR}
      SOURCES ${PROJECT_SOURCE_DIR}/src/test_cc_dbl.c
      COMPILE_DEFINITIONS ${definitions}
      LINK_LIBRARIES ${libraries}
      OUTPUT_VARIABLE OUTPUT
    )
    if(WIGXJPF_HAS_QUADMATH)
      message(CHECK_PASS "found")
    else()
      message(CHECK_FAIL "not found")
    endif()
  endif()
  set(WIGXJPF_QUADMATH_LIBRARIES
      "quadmath"
      CACHE INTERNAL ""
  )
endfunction()

function(wigxjpf_test_feature feature)
  if(NOT DEFINED WIGXJPF_HAS_QUADMATH)
    wigxjpf_test_quadmath()
  endif()
  list(APPEND definitions "-DTEST_${feature}=1" ${CMAKE_REQUIRED_DEFINITIONS})
  if(NOT DEFINED WIGXJPF_HAS_${feature})
    message(CHECK_START "Checking if ${feature} support exists")
    try_compile(
      WIGXJPF_HAS_${feature} ${PROJECT_BINARY_DIR}
      SOURCES ${PROJECT_SOURCE_DIR}/src/test_cc_dbl.c
      COMPILE_DEFINITIONS ${definitions}
      LINK_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} ${WIGXJPF_QUADMATH_LIBRARIES}
      OUTPUT_VARIABLE OUTPUT
    )
    if(WIGXJPF_HAS_${feature})
      message(CHECK_PASS "found")
    else()
      message(CHECK_FAIL "not found")
    endif()
  endif()
endfunction()

# ##############################################################################
# perform tests and configuration
# ##############################################################################

function(configure_wigxjpf)
  # perform checks
  wigxjpf_test_quadmath()

  wigxjpf_test_feature(LONG_DOUBLE)
  if(WIGXJPF_HAS_LONG_DOUBLE)
    set(WIGXJPF_IMPL_LONG_DOUBLE 1)
  endif()

  wigxjpf_test_feature(FLOAT128)
  if(WIGXJPF_HAS_FLOAT128)
    set(WIGXJPF_IMPL_FLOAT128 1)
  endif()

  wigxjpf_test_feature(THREAD)
  if(WIGXJPF_HAS_THREAD)
    set(WIGXJPF_HAVE_THREAD 1)
  endif()

  wigxjpf_test_feature(UINT128)
  if(WIGXJPF_HAS_UINT128)
    set(MULTI_WORD_INT_SIZEOF_ITEM 8)
  endif()

  # configure header file
  configure_file(cfg/wigxjpf_auto_config.h.in gen/wigxjpf_auto_config.h)

endfunction()

configure_wigxjpf()

# ##############################################################################
# define wigxjpf headers and sources
# ##############################################################################

set(wigxjpf_PRIVATE_HEADERS
    src/multi_word_int.h
    src/multi_word_int_dbl.h
    src/prime_factor.h
    src/calc.h
    src/calc_minmax.h
    src/calc_dbl.h
    src/wigxjpf_error.h
    gen/wigxjpf_auto_config.h
    cfg/wigxjpf_config.h
)
set(wigxjpf_PUBLIC_HEADERS inc/wigxjpf.h inc/wigxjpf_quadmath.h)
set(wigxjpf_SOURCES
    src/prime_factor.c
    src/calc.c
    src/trivial_zero.c
    src/c_wrap.c
    src/fortran_wrap.c
    src/wigxjpf_error.c
)

# define wigxjpf library and add source files
add_library(wigxjpf STATIC ${wigxjpf_SOURCES})
add_library(wigxjpf::wigxjpf ALIAS wigxjpf)
foreach(header IN LISTS wigxjpf_PUBLIC_HEADERS)
  target_sources(
    wigxjpf INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${header}>
  )
endforeach()

set(CMAKE_Fortran_MODULE_DIRECTORY ${PROJECT_BINARY_DIR}/mod)
add_library(fwigxjpf OBJECT src/fwigxjpf.f)
add_dependencies(wigxjpf fwigxjpf)

# ##############################################################################
# define wigxjpf quadmath headers and sources
# ##############################################################################

if(WIGXJPF_HAS_QUADMATH)
  set(wigxjpf_quadmath_PRIVATE_HEADERS src/multi_word_int_float128.h)
  set(wigxjpf_quadmath_PUBLIC_HEADERS "")
  set(wigxjpf_quadmath_SOURCES src/calc_float128.c src/c_wrap_float128.c)

  # define wigxjpf_quadmath library and add source files
  add_library(wigxjpf_quadmath STATIC ${wigxjpf_quadmath_SOURCES})
  add_library(wigxjpf::wigxjpf_quadmath ALIAS wigxjpf_quadmath)
  foreach(header IN LISTS wigxjpf_quadmath_PUBLIC_HEADERS)
    target_sources(
      wigxjpf_quadmath
      INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${header}>
    )
  endforeach()
endif()

# ##############################################################################
# define fpsimplexj headers and sources
# ##############################################################################

set(fpsimplexj_PRIVATE_HEADERS src/multi_word_int_float128.h)
set(fpsimplexj_PUBLIC_HEADERS "")
set(fpsimplexj_SOURCES src/calc_float128.c src/c_wrap_float128.c)

# define fpsimplexj library and add source files
add_library(fpsimplexj STATIC ${fpsimplexj_SOURCES})
add_library(wigxjpf::fpsimplexj ALIAS fpsimplexj)
foreach(header IN LISTS fpsimplexj_PUBLIC_HEADERS)
  target_sources(
    fpsimplexj INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${header}>
  )
endforeach()

# ##############################################################################
# link dependencies
# ##############################################################################

target_link_libraries(wigxjpf PUBLIC m)
set_target_properties(wigxjpf PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
if(WIGXJPF_HAS_QUADMATH)
  target_link_libraries(
    wigxjpf_quadmath PUBLIC wigxjpf::wigxjpf ${WIGXJPF_QUADMATH_LIBRARIES}
  )
  set_target_properties(
    wigxjpf_quadmath PROPERTIES POSITION_INDEPENDENT_CODE TRUE
  )
endif()
target_link_libraries(fpsimplexj PUBLIC wigxjpf::wigxjpf)
set_target_properties(fpsimplexj PROPERTIES POSITION_INDEPENDENT_CODE TRUE)

# ##############################################################################
# define include directory
# ##############################################################################
target_include_directories(
  wigxjpf
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/inc>
         $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/mod>
         $<INSTALL_INTERFACE:include/wigxjpf>
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/cfg ${PROJECT_BINARY_DIR}/gen
)

if(WIGXJPF_HAS_QUADMATH)
  target_include_directories(
    wigxjpf_quadmath
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/inc>
           $<INSTALL_INTERFACE:include/wigxjpf>
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/cfg ${PROJECT_BINARY_DIR}/gen
  )
endif()

target_include_directories(
  fpsimplexj
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/inc>
         $<INSTALL_INTERFACE:include/wigxjpf>
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/cfg ${PROJECT_BINARY_DIR}/gen
)

# ##############################################################################
# define installation rules
# ##############################################################################
install(
  TARGETS wigxjpf
  DESTINATION lib
  EXPORT wigxjpfTargets
)
install(FILES ${wigxjpf_PUBLIC_HEADERS} DESTINATION include/wigxjpf)
install(FILES ${CMAKE_Fortran_MODULE_DIRECTORY}/fwigxjpf.mod DESTINATION include/wigxjpf)

if(WIGXJPF_HAS_QUADMATH)
  install(
    TARGETS wigxjpf_quadmath
    DESTINATION lib
    EXPORT wigxjpfTargets
  )
  install(FILES ${wigxjpf_quadmath_PUBLIC_HEADERS} DESTINATION include/wigxjpf)
endif()

install(
  TARGETS fpsimplexj
  DESTINATION lib
  EXPORT wigxjpfTargets
)
install(FILES ${fpsimplexj_PUBLIC_HEADERS} DESTINATION include/wigxjpf)

install(
  EXPORT wigxjpfTargets
  NAMESPACE wigxjpf::
  FILE wigxjpfTargets.cmake
  DESTINATION lib/cmake/wigxjpf
)

include(CMakePackageConfigHelpers)
# generate the config file that is includes the exports
configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/wigxjpfConfig.cmake"
  INSTALL_DESTINATION "lib/cmake/wigxjpf"
  NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO
)
# generate the version file for the config file
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/wigxjpfConfigVersion.cmake"
  VERSION "${wigxjpf_VERSION_MAJOR}.${wigxjpf_VERSION_MINOR}"
  COMPATIBILITY AnyNewerVersion
)

# install the configuration file
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/wigxjpfConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/wigxjpfConfigVersion.cmake
        DESTINATION lib/cmake/wigxjpf
)

export(
  EXPORT wigxjpfTargets
  NAMESPACE wigxjpf::
  FILE "${CMAKE_CURRENT_BINARY_DIR}/wigxjpfTargets.cmake"
)

# ##############################################################################
# define tests
# ##############################################################################

# set(wigxjpf_UNITS_TEST)

# add_custom_target(wigxjpf_tests)
# foreach(test_name IN LISTS wigxjpf_UNITS_TEST)
#   add_executable(${test_name} EXCLUDE_FROM_ALL ${test_name}.cpp)
#   target_link_libraries(${test_name} wigxjpf::wigxjpf)
#   add_dependencies(wigxjpf_tests ${test_name})
# endforeach()

# if(WIGXJPF_MASTER_PROJECT)
#   add_custom_target(tests)
#   add_dependencies(tests wigxjpf_tests)
# endif()
