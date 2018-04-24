# MIT License

# Copyright (c) 2017-2018 Cristian Adam

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

include_guard(GLOBAL)

cmake_minimum_required(VERSION 3.11)

include(DumpCMakeVariables)
include(${CMAKE_ROOT}/Modules/CheckTypeSize.cmake)

macro(check_type_size type variable)
    _check_type_size(${type} ${variable})
    file(APPEND ${CMAKE_BINARY_DIR}/cmake_checks_cache.txt "set(HAVE_${variable} \"${HAVE_${variable}}\" CACHE INTERNAL \"Result of TRY_COMPILE\")\n")
    if(HAVE_${variable})
      file(APPEND ${CMAKE_BINARY_DIR}/cmake_checks_cache.txt "set(${variable} \"${${variable}}\" CACHE INTERNAL \"CHECK_TYPE_SIZE: sizeof(${type})\")\n")
    else()
      file(APPEND ${CMAKE_BINARY_DIR}/cmake_checks_cache.txt "set(${variable} \"\" CACHE INTERNAL \"CHECK_TYPE_SIZE: ${type} unknown\")\n")
    endif()
endmacro()
