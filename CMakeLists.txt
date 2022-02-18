cmake_minimum_required(VERSION 3.10) # For CXX_STANDARD 17 property on Visual Studio

# Project declaration
project(
  dynamic_bitset
  VERSION 1.2.1
  DESCRIPTION "Simple Useful Libraries: C++17/20 header-only dynamic bitset"
  HOMEPAGE_URL "https://github.com/pinam45/dynamic_bitset"
  LANGUAGES CXX
)

# Check if dynamic_bitset is being used directly or via add_subdirectory
get_directory_property(HAS_PARENT PARENT_DIRECTORY)
if(HAS_PARENT)
	set(DYNAMICBITSET_TOPLEVEL_PROJECT OFF)
else()
	set(DYNAMICBITSET_TOPLEVEL_PROJECT ON)
endif()

# Options
include(CMakeDependentOption)
option(
  DYNAMICBITSET_NO_NAMESPACE
  "Put the dynamic_bitset class in the global namespace instead of the sul namespace (not recommended)"
  OFF
)
option(
  DYNAMICBITSET_USE_LIBPOPCNT
  "Enable using (if available) libpopcnt for bits counting operations"
  ON
)
cmake_dependent_option(
  DYNAMICBITSET_USE_LIBPOPCNT_SUBMODULE
  "Enable adding libpopcnt submodule to include paths (disable if your project already include libpopcnt)"
  ON
  "DYNAMICBITSET_USE_LIBPOPCNT"
  OFF
)
option(
  DYNAMICBITSET_USE_STD_BITOPS
  "Enable using (if available) C++20 binary operations from the bit header"
  ON
)
option(
  DYNAMICBITSET_USE_COMPILER_BUILTIN
  "Enable using (if available) compiler builtins (if using C++20 binary operations is disabled or not possible)"
  ON
)
option(
  DYNAMICBITSET_BUILD_EXAMPLE
  "Enable building example for dynamic_bitset"
  ${DYNAMICBITSET_TOPLEVEL_PROJECT}
)
option(
  DYNAMICBITSET_BUILD_TESTS
  "Enable building tests for dynamic_bitset"
  ${DYNAMICBITSET_TOPLEVEL_PROJECT}
)
option(
  DYNAMICBITSET_BUILD_DOCS
  "Enable building documentation for dynamic_bitset"
  ${DYNAMICBITSET_TOPLEVEL_PROJECT}
)
option(
  DYNAMICBITSET_FORMAT_TARGET
  "Enable generating a code formating target for dynamic_bitset"
  ${DYNAMICBITSET_TOPLEVEL_PROJECT}
)
option(
  DYNAMICBITSET_HEADERS_TARGET_IDE
  "Enable generating a target with headers for ide for dynamic_bitset"
  ${DYNAMICBITSET_TOPLEVEL_PROJECT}
)

# Declare dynamic_bitset
add_library(dynamic_bitset INTERFACE)
add_library(sul::dynamic_bitset ALIAS dynamic_bitset)

# If used via add_subdirectory, disable warnings on headers
set(MAYBE_SYSTEM)
if(NOT DYNAMICBITSET_TOPLEVEL_PROJECT)
	set(MAYBE_SYSTEM SYSTEM)
endif()

# Add includes
target_include_directories(
  dynamic_bitset ${MAYBE_SYSTEM} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# Put the dynamic_bitset class in the global namespace?
if(DYNAMICBITSET_NO_NAMESPACE)
	target_compile_definitions(dynamic_bitset INTERFACE DYNAMIC_BITSET_NO_NAMESPACE)
endif()

# Set minimum required standard
target_compile_features(dynamic_bitset INTERFACE cxx_std_17)

# Use libpopcnt?
if(DYNAMICBITSET_USE_LIBPOPCNT)
	message(STATUS "dynamic_bitset: libpopcnt usage enabled")

	# Use the submodule of the git repository?
	if(DYNAMICBITSET_USE_LIBPOPCNT_SUBMODULE)
		get_filename_component(LIBPOPCNT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/extlibs/libpopcnt/libpopcnt.h" ABSOLUTE)
		if(EXISTS "${LIBPOPCNT_PATH}")
			message(STATUS "dynamic_bitset: libpopcnt submodule is present and will be used")
			target_include_directories(
			  dynamic_bitset SYSTEM INTERFACE
			  "${CMAKE_CURRENT_SOURCE_DIR}/extlibs/libpopcnt"
			)
		else()
			message(WARNING "dynamic_bitset: libpopcnt submodule is missing and won't be used, maybe you didn't pull the git submodules")
			set(DYNAMICBITSET_USE_LIBPOPCNT_SUBMODULE OFF)
		endif()
	else()
		message(STATUS "dynamic_bitset: libpopcnt submodule won't be used")
	endif()
else()
	target_compile_definitions(dynamic_bitset INTERFACE DYNAMIC_BITSET_NO_LIBPOPCNT)
	message(STATUS "dynamic_bitset: libpopcnt usage disabled")
endif()

# Use C++20 binary operations?
if(DYNAMICBITSET_USE_STD_BITOPS)
	message(STATUS "dynamic_bitset: C++20 binary operations usage enabled")
else()
	target_compile_definitions(dynamic_bitset INTERFACE DYNAMIC_BITSET_NO_STD_BITOPS)
	message(STATUS "dynamic_bitset: C++20 binary operations usage disabled")
endif()

# Use compiler builtins?
if(DYNAMICBITSET_USE_COMPILER_BUILTIN)
	message(STATUS "dynamic_bitset: compiler builtins usage enabled")
else()
	target_compile_definitions(dynamic_bitset INTERFACE DYNAMIC_BITSET_NO_COMPILER_BUILTIN)
	message(STATUS "dynamic_bitset: compiler builtins usage disabled")
endif()

# Global config if top level project
if(DYNAMICBITSET_TOPLEVEL_PROJECT)
	# Disable sources modifications
	set(CMAKE_DISABLE_SOURCE_CHANGES ON)
	set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

	# Strict C++ standard
	set(CMAKE_CXX_STANDARD_REQUIRED ON)
	set(CMAKE_CXX_EXTENSIONS OFF)

	# IDE folders
	set_property(GLOBAL PROPERTY USE_FOLDERS ON)
	set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "_CMake")

	# Flags
	include(cmake/flags.cmake)
endif()

# Create Headers target for IDE?
if(DYNAMICBITSET_HEADERS_TARGET_IDE)
	add_custom_target(dynamic_bitset_headers_for_ide SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/include/sul/dynamic_bitset.hpp")
	source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES "${CMAKE_CURRENT_SOURCE_DIR}/include/sul/dynamic_bitset.hpp")
	set_target_properties(dynamic_bitset_headers_for_ide PROPERTIES FOLDER "dynamic_bitset")
endif()

# Generate format target?
if(DYNAMICBITSET_FORMAT_TARGET)
	find_program(
	  CLANG_FORMAT clang-format
	  NAMES
	  clang-format-13
	  clang-format-12
	  clang-format-11
	  clang-format-10
	  clang-format-9
	  clang-format-8
	  clang-format-7
	  clang-format-6
	)
	if(${CLANG_FORMAT} STREQUAL CLANG_FORMAT-NOTFOUND)
		message(WARNING "clang-format not found, format targets not generated")
		set(DYNAMICBITSET_FORMAT_TARGET OFF)
	else()
		message(STATUS "clang-format found: ${CLANG_FORMAT}")
		add_custom_target(
		  format-dynamic_bitset
		  COMMAND "${CLANG_FORMAT}" -style=file -i "${CMAKE_CURRENT_SOURCE_DIR}/include/sul/dynamic_bitset.hpp"
		  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		  VERBATIM
		)
		set_target_properties(format-dynamic_bitset PROPERTIES FOLDER "dynamic_bitset/format")
	endif()
endif()

# Build example?
if(DYNAMICBITSET_BUILD_EXAMPLE)
	add_subdirectory(example)

	# Set example as startup project for Visual Studio
	set_property(
	  DIRECTORY
	  ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY
	  VS_STARTUP_PROJECT dynamic_bitset_example
	)
endif()

# Build tests?
if(DYNAMICBITSET_BUILD_TESTS)
	enable_testing()

	# Catch2
	get_filename_component(CATCH2_CMAKELISTS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/extlibs/Catch2/CMakeLists.txt" ABSOLUTE)
	if(NOT EXISTS "${CATCH2_CMAKELISTS_PATH}")
		message(FATAL_ERROR "Catch2 dependency is missing, maybe you didn't pull the git submodules")
	endif()
	add_subdirectory(extlibs/Catch2)
	include(extlibs/Catch2/contrib/Catch.cmake)

	# Disable warnings on Catch2 headers
	get_target_property(Catch2_include_directories Catch2 INTERFACE_INCLUDE_DIRECTORIES)
	set_target_properties(Catch2 PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "")
	target_include_directories(Catch2 SYSTEM INTERFACE ${Catch2_include_directories})

	# Tests
	add_subdirectory(tests)
endif()

# Build documentation?
if(DYNAMICBITSET_BUILD_DOCS)
	add_subdirectory(docs)
endif()
