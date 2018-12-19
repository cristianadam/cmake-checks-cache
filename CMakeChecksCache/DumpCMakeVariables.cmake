# MIT License

# Copyright (c) 2018 Cristian Adam

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

set(CMAKE_CHECKS_CACHE_FILE "${CMAKE_BINARY_DIR}/cmake_checks_cache.txt" CACHE FILEPATH "CMake checks cache file")

file(APPEND ${CMAKE_CHECKS_CACHE_FILE} "###############################################################\n")
file(APPEND ${CMAKE_CHECKS_CACHE_FILE} "# Dump of all cache variables that started with CMAKE_*\n")
file(APPEND ${CMAKE_CHECKS_CACHE_FILE} "###############################################################\n")

get_cmake_property(_cachedVariableNames CACHE_VARIABLES)
list(FILTER _cachedVariableNames INCLUDE REGEX "^CMAKE_.*$")
foreach (_cacheVariable ${_cachedVariableNames})
    get_property(_type CACHE "${_cacheVariable}" PROPERTY TYPE)
    get_property(_advanced CACHE "${_cacheVariable}" PROPERTY ADVANCED)
    get_property(_help_string CACHE "${_cacheVariable}" PROPERTY HELPSTRING)
    string(REPLACE "\"" "\\\"" ${_cacheVariable} "${${_cacheVariable}}")
    if (NOT "${_type}" STREQUAL "UNINITIALIZED" AND NOT "${_type}" STREQUAL "STATIC")
        file(APPEND ${CMAKE_CHECKS_CACHE_FILE} "set(${_cacheVariable} \"${${_cacheVariable}}\" CACHE ${_type} \"${_help_string}\")\n")
        if (${_advanced})
            file(APPEND ${CMAKE_CHECKS_CACHE_FILE} "mark_as_advanced(${_cacheVariable})\n")
        endif()
    endif()
endforeach()

file(APPEND ${CMAKE_CHECKS_CACHE_FILE} "###############################################################\n")
