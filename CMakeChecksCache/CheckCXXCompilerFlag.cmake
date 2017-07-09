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

# Include the content of CheckCXXCompilerFlag just not to have the original
# include(CheckCXXSourceCompiles) which has precedence, and which doesn't have
# a include guard, thus overriding my overriden version

include(${CMAKE_CURRENT_LIST_DIR}/CheckCXXSourceCompiles.cmake)
include(CMakeCheckCompilerFlagCommonPatterns)

# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

macro (CHECK_CXX_COMPILER_FLAG_original _FLAG _RESULT)
   set(SAFE_CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}")
   set(CMAKE_REQUIRED_DEFINITIONS "${_FLAG}")

   # Normalize locale during test compilation.
   set(_CheckCXXCompilerFlag_LOCALE_VARS LC_ALL LC_MESSAGES LANG)
   foreach(v ${_CheckCXXCompilerFlag_LOCALE_VARS})
     set(_CheckCXXCompilerFlag_SAVED_${v} "$ENV{${v}}")
     set(ENV{${v}} C)
   endforeach()
   CHECK_COMPILER_FLAG_COMMON_PATTERNS(_CheckCXXCompilerFlag_COMMON_PATTERNS)
   _check_cxx_source_compiles("int main() { return 0; }" ${_RESULT}
     # Some compilers do not fail with a bad flag
     FAIL_REGEX "command line option .* is valid for .* but not for C\\\\+\\\\+" # GNU
     ${_CheckCXXCompilerFlag_COMMON_PATTERNS}
     )
   foreach(v ${_CheckCXXCompilerFlag_LOCALE_VARS})
     set(ENV{${v}} ${_CheckCXXCompilerFlag_SAVED_${v}})
     unset(_CheckCXXCompilerFlag_SAVED_${v})
   endforeach()
   unset(_CheckCXXCompilerFlag_LOCALE_VARS)
   unset(_CheckCXXCompilerFlag_COMMON_PATTERNS)

   set (CMAKE_REQUIRED_DEFINITIONS "${SAFE_CMAKE_REQUIRED_DEFINITIONS}")
endmacro ()

macro(check_cxx_compiler_flag flag variable)
    CHECK_CXX_COMPILER_FLAG_original("${flag}" ${variable})
    file(APPEND ${cache_file} "set(${variable} \"${${variable}}\" CACHE INTERNAL \"Test ${flag}\")\n")
endmacro()
