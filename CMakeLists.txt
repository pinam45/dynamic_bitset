cmake_minimum_required(VERSION 3.10) # For CXX_STANDARD 17 property on Visual Studio

# Project declaration
project(
  dynamic_bitset
  VERSION 1.2.0
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

# Add definitions
if(DYNAMICBITSET_NO_NAMESPACE)
	target_compile_definitions(dynamic_bitset INTERFACE DYNAMIC_BITSET_NO_NAMESPACE)
endif()

# Set minimum required standard
target_compile_features(dynamic_bitset INTERFACE cxx_std_17)

# Configure libpopcnt
if(DYNAMICBITSET_USE_LIBPOPCNT)
	message(STATUS "dynamic_bitset: libpopcnt usage enabled")
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

if(DYNAMICBITSET_USE_STD_BITOPS)
	message(STATUS "dynamic_bitset: C++20 binary operations usage enabled")
else()
	target_compile_definitions(dynamic_bitset INTERFACE DYNAMIC_BITSET_NO_STD_BITOPS)
	message(STATUS "dynamic_bitset: C++20 binary operations usage disabled")
endif()

if(DYNAMICBITSET_USE_COMPILER_BUILTIN)
	message(STATUS "dynamic_bitset: compiler builtins usage enabled")
else()
	target_compile_definitions(dynamic_bitset INTERFACE DYNAMIC_BITSET_NO_COMPILER_BUILTIN)
	message(STATUS "dynamic_bitset: compiler builtins usage disabled")
endif()

# CMake utilities
if(DYNAMICBITSET_TOPLEVEL_PROJECT
	OR DYNAMICBITSET_BUILD_EXAMPLE
	OR DYNAMICBITSET_BUILD_TESTS
	OR DYNAMICBITSET_FORMAT_TARGET
	OR DYNAMICBITSET_HEADERS_TARGET_IDE
  )
	get_filename_component(CMUTILS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CMutils/cmutils.cmake" ABSOLUTE)
	if(EXISTS "${CMUTILS_PATH}")
		include(${CMUTILS_PATH})
	else()
		message(FATAL_ERROR "CMutils is missing, maybe you didn't pull the git submodules")
	endif()
endif()

# Global config
if(DYNAMICBITSET_TOPLEVEL_PROJECT)
	cmutils_disable_in_sources_build()
	cmutils_enable_ide_folders()
	cmutils_set_classic_output_folders()
endif()

# Headers target for ide
if(DYNAMICBITSET_HEADERS_TARGET_IDE)
	cmutils_interface_target_generate_headers_target(dynamic_bitset dynamic_bitset_headers_for_ide)
	cmutils_target_source_group(dynamic_bitset_headers_for_ide "${CMAKE_CURRENT_SOURCE_DIR}")
	cmutils_target_set_ide_folder(dynamic_bitset_headers_for_ide "dynamic_bitset")
endif()

# Example
if(DYNAMICBITSET_BUILD_EXAMPLE)
	add_subdirectory(example)
endif()

# Tests
if(DYNAMICBITSET_BUILD_TESTS)
	enable_testing()

	# Catch2
	get_filename_component(CATCH2_DIR ${CMAKE_CURRENT_SOURCE_DIR}/extlibs/Catch2 ABSOLUTE)
	cmutils_directory_is_empty(is_empty "${CATCH2_DIR}")
	if(is_empty)
		message(FATAL_ERROR "Catch2 dependency is missing, maybe you didn't pull the git submodules")
	endif()
	add_subdirectory(extlibs/Catch2)
	include(${CATCH2_DIR}/contrib/Catch.cmake)

	# Tests
	add_subdirectory(tests)
endif()

# Docs
if(DYNAMICBITSET_BUILD_DOCS)
	add_subdirectory(docs)
endif()

# Generate format target
if(DYNAMICBITSET_FORMAT_TARGET)
	cmutils_generate_clang_format(format-dynamic_bitset RECURSE "${CMAKE_CURRENT_SOURCE_DIR}/include")
	cmutils_target_set_ide_folder(format-dynamic_bitset "dynamic_bitset/format")
endif()
