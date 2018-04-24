# cmake-checks-cache

Cross platform CMake projects do platform introspection by the means of "Check" macros. Have a look at CMake's [How To Write Platform Checks](https://cmake.org/Wiki/CMake:How_To_Write_Platform_Checks) wiki page for a detailed explanation.

There are quite a few of them:
  * [CheckIncludeFile](https://cmake.org/cmake/help/latest/module/CheckIncludeFile.html) Provides a macro to check if a header file can be included in C.
  * [CheckIncludeFileCXX](https://cmake.org/cmake/help/latest/module/CheckIncludeFileCXX.html) Provides a macro to check if a header file can be included in CXX.
  * [CheckIncludeFiles](https://cmake.org/cmake/help/latest/module/CheckIncludeFiles.html) Provides a macro to check if a list of one or more header files can be included together.
  * [CheckFunctionExists](https://cmake.org/cmake/help/latest/module/CheckFunctionExists.html) Check if a C function can be linked.
  * [CheckLibraryExists](https://cmake.org/cmake/help/latest/module/CheckLibraryExists.html) Check if the function exists.
  * [CheckSymbolExists](https://cmake.org/cmake/help/latest/module/CheckSymbolExists.html) Provides a macro to check if a symbol exists as a function, variable, or macro in C.
  * [CheckCCompilerFlag](https://cmake.org/cmake/help/latest/module/CheckCCompilerFlag.html) Check whether the C compiler supports a given flag.
  * [CheckCXXCompilerFlag](https://cmake.org/cmake/help/latest/module/CheckCXXCompilerFlag.html) Check whether the CXX compiler supports a given flag.
  * [CheckCSourceCompiles](https://cmake.org/cmake/help/latest/module/CheckCSourceCompiles.html) Check if given C source compiles and links into an executable.
  * [CheckCXXSourceCompiles](https://cmake.org/cmake/help/latest/module/CheckCXXSourceCompiles.html) Check if given C++ source compiles and links into an executable.
  * [CheckTypeSize](https://cmake.org/cmake/help/latest/module/CheckTypeSize.html) Check sizeof a type.
  
All these checks will create small CMake project which will try to compile a C or C++ program, and based on the success of the compilation will set a CMake cache variable.

Usually in a Continuous Integration (CI) Build the compilation starts from scratch with a an empty build folder. Also the CI-Build is also set up using a compilation cache for the C / C++ code e.g. [ccache](https://ccache.samba.org/), [clcache](https://github.com/frerich/clcache) etc.

Depending how the compilation cache is set up they might also speed up the CMake Check macros.

But what if we can cache CMake Check results? This is where [cmake-checks-cache](https://github.com/cristianadam/cmake-checks-cache/) comes into action!

# Creating the cmake_checks_cache.txt file

One needs to run `CMake` with `-DCMAKE_MODULE_PATH` pointing out to the `CMakeChecksCache` checkout! That was it!

In the build folder you will get a file named `cmake_checks_cache.txt` which contains all the trapped Check macro calls and all the `CMAKE_*` cache variables. 

The part with the `CMAKE_*` cache variables is needed for skipping the initial CMake platform compiler / linker / assembler introspection. Please note that you need to copy also the `CMakeFiles/<CMake Version>/CMake*.cmake` files.

On Windows make sure that you use absolute paths with slashes for `-DCMAKE_MODULE_PATH` argument. Otherwise you will get some nasty CMake errors.

## LLVM + clang example

The usual CMake command line looks like this (in a Visual C++ 2017 command prompt):

```
$ cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ../llvm-6.0.0.src
```

For caching the CMake checks you should run CMake like this:

```
$ cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ../llvm-6.0.0.src -DCMAKE_MODULE_PATH=c:/Projects/CMakeChecksCache
```

The files that you need to keep would be:

```
.
├── cmake_checks_cache.txt
└── CMakeFiles
    └── 3.11.0
        ├── CMakeASMCompiler.cmake
        ├── CMakeCCompiler.cmake
        ├── CMakeCXXCompiler.cmake
        ├── CMakeRCCompiler.cmake
        └── CMakeSystem.cmake
```

For using the CMake checks in a an empty folder (with the above files copied) you should run CMake like this:

```
$ cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -C cmake_checks_cache.txt ../llvm-6.0.0.src
```

CMake documentation describes `-C` command line parameter like this:

> `-C <initial-cache>`
>
> Pre-load a script to populate the cache.
> 
> When cmake is first run in an empty build tree, it creates a CMakeCache.txt file and populates it with customizable settings for the project. This option may be used to specify a file from which to load cache entries before the first pass through the project’s cmake listfiles. The loaded entries take priority over the project’s default values. The given file should be a CMake script containing SET commands that use the CACHE option, not a cache-format file.


## Benchmark 

I have ran the benchmarks on Windows 10 in a Visual C++ 2017 x64 command prompt.

| LLVM + Clang 6.0.0                        | Ninja     | MSBuild    |
|-------------------------------------------|-----------|------------|
| CMake first run (empty folder)            |  74.085 s | 158.683 s  |
| CMake second run (already configured)     |  26.196 s | 45.564 s   |
| CMake generating cmake_checks_cache.txt   |  71.098 s | 149.46 s   |
| CMake using cmake_check_cache.txt         |  26.792 s | 45.01 s    |

For the Ninja benchmarks I have used the above given CMake calls. For MSBuild I simply omitted `-G "Ninja"` from the command lines, letting CMake use the default introspection for the Visual C++ 2017 x64 command prompt.

The reason that MSBuild is slower is that for every Check there is a small Visual Studio (MSBuild) solution created and then msbuild is ran for it. msbuild is written in C# and it has to use the .NET platform.

MSBuild generation is slower because it generates multiple variants x86, x64, Debug, and Release. See the CMake's [Visual Studio 15 2017](https://cmake.org/cmake/help/latest/generator/Visual%20Studio%2015%202017.html) documentation for additional tweaks. I just wanted to keep things simple and use the defaults.

The generation of the cmake_checks_cache.txt is faster than the first CMake run because the operating system has done some resource caching of itself.

## Blog entry 
For more rationale and benchmarks have a look at my [Speeding up CMake](https://cristianadam.eu/20170709/speeding-up-cmake/) blog article.

Since I wrote the blog article I have comitted a few bugfixes to CMake, hence the need of CMake version 3.11.
