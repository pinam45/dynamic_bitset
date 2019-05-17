# dynamic_bitset

[![Build Status](https://travis-ci.org/pinam45/dynamic_bitset.svg?branch=master)](https://travis-ci.org/pinam45/dynamic_bitset)
[![Build status](https://ci.appveyor.com/api/projects/status/h0vnyjlaunqgbrp4/branch/master?svg=true)](https://ci.appveyor.com/project/pinam45/dynamic-bitset/branch/master)
[![codecov](https://codecov.io/gh/pinam45/dynamic_bitset/branch/master/graph/badge.svg)](https://codecov.io/gh/pinam45/dynamic_bitset)
[![license](https://img.shields.io/github/license/pinam45/dynamic_bitset.svg)](LICENSE)

A C++ header-only dynamic bitset

## Requirements

To use this *dynamic_bitset*, you will need a **C++17 compliant compiler**. If you use CMake and want to use the *dynamic_bitset* as a subproject, you will need **CMake 3.10 or later**.

## Usage sample

```c++
#include <dynamic_bitset.hpp>
#include <iostream>
#include <random>

int main()
{
	// predefined bitset
	dynamic_bitset<> bitset1(12, 0b0100010110111);
	std::cout << "bitset1     = " << bitset1 << std::endl;

	// random bitset
	std::minstd_rand rand(std::random_device{}());
	std::bernoulli_distribution dist;
	dynamic_bitset<> bitset2;
	for(size_t i = 0; i < 12; ++i)
	{
		bitset2.push_back(dist(rand));
	}
	std::cout << "bitset2     = " << bitset2 << std::endl;

	std::cout << "common bits = " << (bitset1 & bitset2) << std::endl;
	return 0;
}
```

## Integration

As it is a header-only library, the easiest way to integrate the *dynamic_bitset* class in your project is to just copy *dynamic_bitset.hpp* in your project sources.

## CMake integration

If you use CMake and want to use the *dynamic_bitset* as a subproject, clone the repository (or add it as a git submodule) in a sub-folder of your project. Then, in your *CMakeLists.txt* add:
```CMake
add_subdirectory(<path_to_dynamic_bitset_folder>)
```
It will define the *dynamic_bitset* target and the alias target *dynamic_bitset::dynamic_bitset* that you can use to add the folder containing *dynamic_bitset.hpp* to your project header folders. To do so, in your *CMakeLists.txt* add:
```CMake
target_link_libraries(<your_project_target> PRIVATE dynamic_bitset)
```

For example, a simple project with the repository as a git submodule in the *extlibs* folder, could have a *CMakeLists.txt* similar to this:
```CMake
cmake_minimum_required(VERSION 3.10)
project(CoolProject LANGUAGES CXX)

add_executable(CoolProject main.cpp)

add_subdirectory(extlibs/dynamic_bitset)
target_link_libraries(CoolProject PRIVATE dynamic_bitset)
```

## Build tests and example

To build the tests and the example, git submodules are required, so don't forget to pull the submodules with the repository using ``--recursive``:

    git clone --recursive https://github.com/pinam45/dynamic_bitset.git

or if you have already cloned the repository:

    git submodule init
    git submodule update

The project uses CMake to build and define the options *DYNAMICBITSET_BUILD_TESTS* and *DYNAMICBITSET_BUILD_EXAMPLE* to enable the generation of the tests and example targets, these option are enabled by default if the project is the master project (not included from another *CMakeLists.txt* with *add_subdirectory*).

For running the tests, just build the *dynamic_bitset_tests* target and launch the tests using ctest. See [Running CMake](https://cmake.org/runningcmake/) and [the ctest documentation](https://cmake.org/cmake/help/latest/manual/ctest.1.html) for more information.

On linux, a common way of doing this is:

	$ mkdir cmake-build
	$ cd cmake-build
	$ cmake ..
	$ cmake --build .
	$ ctest

On Windows, there is batch files available to configure a Visual Studio project in the ``ide`` folder.

## License

<img align="right" src="http://opensource.org/trademarks/opensource/OSI-Approved-License-100x137.png">

dynamic_bitset is licensed under the [MIT License](http://opensource.org/licenses/MIT):

Copyright &copy; 2019 [Maxime Pinard](https://github.com/pinam45)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
