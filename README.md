# dynamic_bitset

[![Ubuntu](https://github.com/pinam45/dynamic_bitset/actions/workflows/ubuntu.yml/badge.svg?branch=master)](https://github.com/pinam45/dynamic_bitset/actions/workflows/ubuntu.yml)
[![Windows MinGW](https://github.com/pinam45/dynamic_bitset/actions/workflows/windows-mingw.yml/badge.svg?branch=master)](https://github.com/pinam45/dynamic_bitset/actions/workflows/windows-mingw.yml)
[![Windows Visual Studio](https://github.com/pinam45/dynamic_bitset/actions/workflows/windows-msvc.yml/badge.svg?branch=master)](https://github.com/pinam45/dynamic_bitset/actions/workflows/windows-msvc.yml)
[![macOS](https://github.com/pinam45/dynamic_bitset/actions/workflows/macos.yml/badge.svg?branch=master)](https://github.com/pinam45/dynamic_bitset/actions/workflows/macos.yml)
[![documentation](https://github.com/pinam45/dynamic_bitset/actions/workflows/documentation.yml/badge.svg?branch=master)](https://pinam45.github.io/dynamic_bitset)
[![codecov](https://codecov.io/gh/pinam45/dynamic_bitset/branch/master/graph/badge.svg)](https://codecov.io/gh/pinam45/dynamic_bitset)
[![license](https://img.shields.io/github/license/pinam45/dynamic_bitset.svg)](http://opensource.org/licenses/MIT)

Simple Useful Libraries: C++17/20 header-only dynamic bitset

## Requirements

To use this *dynamic bitset*, you will need a **C++17 (or later) compliant compiler**. If you use CMake and want to use the *dynamic bitset* as a subproject, you will need **CMake 3.10 or later**.

## Usage sample

```cpp
#include <sul/dynamic_bitset.hpp>
#include <iostream>
#include <random>

int main()
{
	// predefined bitset
	sul::dynamic_bitset<> bitset1(12, 0b0100010110111);
	std::cout << "bitset1     = " << bitset1 << std::endl;

	// random bitset
	std::minstd_rand rand(std::random_device{}());
	std::bernoulli_distribution dist;
	sul::dynamic_bitset<> bitset2;
	for(size_t i = 0; i < 12; ++i)
	{
		bitset2.push_back(dist(rand));
	}
	std::cout << "bitset2     = " << bitset2 << std::endl;

	std::cout << "common bits = " << (bitset1 & bitset2) << std::endl;
	return 0;
}
```

Possible output:

    bitset1     = 100010110111
    bitset2     = 001011011011
    common bits = 000010010011

Test it on [godbolt.org](https://godbolt.org/z/1veE71rYT).

## Optional dependency

Optionally, [libpopcnt](https://github.com/kimwalisch/libpopcnt) will be used to optimize the bits counting operations, if the header is available (``__has_include(<libpopcnt.h>)``) and ``DYNAMIC_BITSET_NO_LIBPOPCNT`` is not defined.

## Integration

As it is a header-only library, the easiest way to integrate the *sul::dynamic_bitset* class in your project is to just copy the [sul](include/sul) folder in your project sources. Optionally, if you also copy *libpopcnt.h* from [libpopcnt](https://github.com/kimwalisch/libpopcnt), it will be used by default if it is available.

## CMake integration

If you use CMake and want to use the *dynamic bitset* as a subproject, clone the repository (or add it as a git submodule) in a sub-folder of your project. Then, in your *CMakeLists.txt* add:
```CMake
add_subdirectory(<path_to_dynamic_bitset_folder>)
```
It will define the *dynamic_bitset* target and the alias target *sul::dynamic_bitset* that you can use to add the folder containing *dynamic_bitset.hpp* to your project header folders. To do so, in your *CMakeLists.txt* add:
```CMake
target_link_libraries(<your_project_target> PRIVATE sul::dynamic_bitset)
```

For example, a simple project with the repository as a git submodule in the *extlibs* folder, could have a *CMakeLists.txt* similar to this:
```CMake
cmake_minimum_required(VERSION 3.10)
project(CoolProject LANGUAGES CXX)

add_executable(CoolProject main.cpp)
target_compile_features(CoolProject PRIVATE cxx_std_20)

add_subdirectory(extlibs/dynamic_bitset)
target_link_libraries(CoolProject PRIVATE sul::dynamic_bitset)
```

If you pulled the git submodule libpopcnt (in [extlibs](extlibs)) and set the *dynamic bitset* CMake options ``DYNAMICBITSET_USE_LIBPOPCNT`` and ``DYNAMICBITSET_USE_LIBPOPCNT_SUBMODULE`` to ``ON``(default values), the folder containing *libpopcnt.h* will also be added to the headers paths and libpopcnt will be used.

## CMake options

### Descriptions

- ``DYNAMICBITSET_NO_NAMESPACE``: Put the dynamic_bitset class in the global namespace instead of the sul namespace (not recommended)
- ``DYNAMICBITSET_USE_LIBPOPCNT``: Enable using libpopcnt for bits counting operations
- ``DYNAMICBITSET_USE_LIBPOPCNT_SUBMODULE``: Enable adding libpopcnt submodule to include paths (disable if your project already include libpopcnt)
- ``DYNAMICBITSET_USE_STD_BITOPS``: Enable using (if available) C++20 binary operations from the bit header
- ``DYNAMICBITSET_USE_COMPILER_BUILTIN``: Enable using (if available) compiler builtins (if using C++20 binary operations is disabled or not possible)
- ``DYNAMICBITSET_BUILD_EXAMPLE``: Enable building example for dynamic_bitset
- ``DYNAMICBITSET_BUILD_TESTS``: Enable building tests for dynamic_bitset
- ``DYNAMICBITSET_BUILD_DOCS``: Enable building documentation for dynamic_bitset
- ``DYNAMICBITSET_FORMAT_TARGET``: Enable generating a code formating target for dynamic_bitset
- ``DYNAMICBITSET_HEADERS_TARGET_IDE``: Enable generating a target with headers for ide for dynamic_bitset

### Default values

| Option                                | Default value as top level project | Default value as subdirectory |
| ------------------------------------- | :--------------------------------: | :---------------------------: |
| DYNAMICBITSET_NO_NAMESPACE            | OFF                                | OFF                           |
| DYNAMICBITSET_USE_LIBPOPCNT           | ON                                 | ON                            |
| DYNAMICBITSET_USE_LIBPOPCNT_SUBMODULE | ON                                 | ON                            |
| DYNAMICBITSET_USE_STD_BITOPS          | ON                                 | ON                            |
| DYNAMICBITSET_USE_COMPILER_BUILTIN    | ON                                 | ON                            |
| DYNAMICBITSET_BUILD_EXAMPLE           | ON                                 | OFF                           |
| DYNAMICBITSET_BUILD_TESTS             | ON                                 | OFF                           |
| DYNAMICBITSET_BUILD_DOCS              | ON                                 | OFF                           |
| DYNAMICBITSET_FORMAT_TARGET           | ON                                 | OFF                           |
| DYNAMICBITSET_HEADERS_TARGET_IDE      | ON                                 | OFF                           |

## Build tests, example, and documentation

The latest version of the documentation is available online [here](https://pinam45.github.io/dynamic_bitset).

To build the tests, the example, and the documentation, git submodules are required, so don't forget to pull the submodules with the repository using ``--recursive``:

    $ git clone --recursive https://github.com/pinam45/dynamic_bitset.git

or if you have already cloned the repository:

    $ git submodule update --init --recursive

The project uses CMake to build and define the options ``DYNAMICBITSET_BUILD_TESTS``, ``DYNAMICBITSET_BUILD_EXAMPLE``, and ``DYNAMICBITSET_BUILD_DOCS`` to enable the generation of the tests, example, and documentation targets, these option are enabled by default if the project is the master project (not included from another *CMakeLists.txt* with *add_subdirectory*).

Generating the documentation requires **[Doxygen](http://www.doxygen.nl/) 1.8.16 or later** and is done by building the target *dynamic_bitset_docs*. For running the tests, build the *dynamic_bitset_tests* target and launch the tests using ctest.

See [Running CMake](https://cmake.org/runningcmake/) and [the ctest documentation](https://cmake.org/cmake/help/latest/manual/ctest.1.html) for more information. On linux, a common way of doing this is:

	$ mkdir cmake-build
	$ cd cmake-build
	$ cmake ..
	$ cmake --build .
	$ ctest --output-on-failure

On Windows, there is batch files available to configure a Visual Studio project in the [ide](ide) folder.

## License

<img align="right" src="http://opensource.org/trademarks/opensource/OSI-Approved-License-100x137.png">

dynamic_bitset is licensed under the [MIT License](http://opensource.org/licenses/MIT):

Copyright &copy; 2019 [Maxime Pinard](https://github.com/pinam45)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
