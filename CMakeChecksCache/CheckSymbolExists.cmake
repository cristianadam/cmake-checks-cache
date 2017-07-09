# MIT License

# Copyright (c) 2017 Cristian Adam

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

cmake_minimum_required(VERSION 3.4.3)

set(cache_file ${CMAKE_CHECKS_CACHE_FILE})
if(NOT cache_file)
    set(cache_file ${CMAKE_BINARY_DIR}/cmake_checks_cache.txt)
endif()

# Found a bug in cmake, they already have a _check_symbol_exists implementation macro o_O
# include(${CMAKE_ROOT}/Modules/CheckSymbolExists.cmake)

# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

macro(official_check_symbol_exists SYMBOL FILES VARIABLE)
  if(CMAKE_C_COMPILER_LOADED)
    official_check_symbol_exists_impl("${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CheckSymbolExists.c" "${SYMBOL}" "${FILES}" "${VARIABLE}" )
  elseif(CMAKE_CXX_COMPILER_LOADED)
    official_check_symbol_exists_impl("${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CheckSymbolExists.cxx" "${SYMBOL}" "${FILES}" "${VARIABLE}" )
  else()
    message(FATAL_ERROR "CHECK_SYMBOL_EXISTS needs either C or CXX language enabled")
  endif()
endmacro()

macro(official_check_symbol_exists_impl SOURCEFILE SYMBOL FILES VARIABLE)
  if(NOT DEFINED "${VARIABLE}" OR "x${${VARIABLE}}" STREQUAL "x${VARIABLE}")
    set(CMAKE_CONFIGURABLE_FILE_CONTENT "/* */\n")
    set(MACRO_CHECK_SYMBOL_EXISTS_FLAGS ${CMAKE_REQUIRED_FLAGS})
    if(CMAKE_REQUIRED_LIBRARIES)
      set(CHECK_SYMBOL_EXISTS_LIBS
        LINK_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES})
    else()
      set(CHECK_SYMBOL_EXISTS_LIBS)
    endif()
    if(CMAKE_REQUIRED_INCLUDES)
      set(CMAKE_SYMBOL_EXISTS_INCLUDES
        "-DINCLUDE_DIRECTORIES:STRING=${CMAKE_REQUIRED_INCLUDES}")
    else()
      set(CMAKE_SYMBOL_EXISTS_INCLUDES)
    endif()
    foreach(FILE ${FILES})
      string(APPEND CMAKE_CONFIGURABLE_FILE_CONTENT
        "#include <${FILE}>\n")
    endforeach()
    string(APPEND CMAKE_CONFIGURABLE_FILE_CONTENT
      "\nint main(int argc, char** argv)\n{\n  (void)argv;\n#ifndef ${SYMBOL}\n  return ((int*)(&${SYMBOL}))[argc];\n#else\n  (void)argc;\n  return 0;\n#endif\n}\n")

    configure_file("${CMAKE_ROOT}/Modules/CMakeConfigurableFile.in"
      "${SOURCEFILE}" @ONLY)

    if(NOT CMAKE_REQUIRED_QUIET)
      message(STATUS "Looking for ${SYMBOL}")
    endif()
    try_compile(${VARIABLE}
      ${CMAKE_BINARY_DIR}
      "${SOURCEFILE}"
      COMPILE_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS}
      ${CHECK_SYMBOL_EXISTS_LIBS}
      CMAKE_FLAGS
      -DCOMPILE_DEFINITIONS:STRING=${MACRO_CHECK_SYMBOL_EXISTS_FLAGS}
      "${CMAKE_SYMBOL_EXISTS_INCLUDES}"
      OUTPUT_VARIABLE OUTPUT)
    if(${VARIABLE})
      if(NOT CMAKE_REQUIRED_QUIET)
        message(STATUS "Looking for ${SYMBOL} - found")
      endif()
      set(${VARIABLE} 1 CACHE INTERNAL "Have symbol ${SYMBOL}")
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
        "Determining if the ${SYMBOL} "
        "exist passed with the following output:\n"
        "${OUTPUT}\nFile ${SOURCEFILE}:\n"
        "${CMAKE_CONFIGURABLE_FILE_CONTENT}\n")
    else()
      if(NOT CMAKE_REQUIRED_QUIET)
        message(STATUS "Looking for ${SYMBOL} - not found")
      endif()
      set(${VARIABLE} "" CACHE INTERNAL "Have symbol ${SYMBOL}")
      file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
        "Determining if the ${SYMBOL} "
        "exist failed with the following output:\n"
        "${OUTPUT}\nFile ${SOURCEFILE}:\n"
        "${CMAKE_CONFIGURABLE_FILE_CONTENT}\n")
    endif()
  endif()
endmacro()

macro(check_symbol_exists symbol header variable)
    official_check_symbol_exists(${symbol} "${header}" ${variable})
    file(APPEND ${cache_file} "set(${variable} \"${${variable}}\" CACHE INTERNAL \"Have symbol ${symbol}\")\n")
endmacro()
