cmake_minimum_required(VERSION 3.10) # For CXX_STANDARD 17 property on Visual Studio

# Options
option(DYNAMICBITSET_ENABLE_COVERAGE "Enable coverage informations generation" OFF)

# Check dynamic_bitset
if(NOT TARGET dynamic_bitset)
	message(FATAL_ERROR "dynamic_bitset target required for the tests")
endif()

# Project declaration
project(
  dynamic_bitset_tests
  DESCRIPTION "C++ dynamic bitset tests"
  LANGUAGES CXX
)

# Declare tests targets
add_executable(dynamic_bitset_tests_base)
add_executable(dynamic_bitset_tests_libpopcnt)
add_executable(dynamic_bitset_tests_std_bitops)
add_executable(dynamic_bitset_tests_builtins)
add_executable(dynamic_bitset_tests_builtins_msvc_32)

# Add sources
cmutils_target_sources_folders(
  dynamic_bitset_tests_base PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/src"
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
cmutils_target_sources_folders(
  dynamic_bitset_tests_libpopcnt PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/count.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
cmutils_target_sources_folders(
  dynamic_bitset_tests_std_bitops PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/count.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/find_first_find_next.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
cmutils_target_sources_folders(
  dynamic_bitset_tests_builtins PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/count.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/find_first_find_next.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
cmutils_target_sources_folders(
  dynamic_bitset_tests_builtins_msvc_32 PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/find_first_find_next.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

foreach(
  target
  dynamic_bitset_tests_base
  dynamic_bitset_tests_libpopcnt
  dynamic_bitset_tests_std_bitops
  dynamic_bitset_tests_builtins
  dynamic_bitset_tests_builtins_msvc_32
)
	# Add includes
	target_include_directories(
	  ${target} PRIVATE
	  "${CMAKE_CURRENT_SOURCE_DIR}/include"
	)

	# Link dynamic_bitset
	target_link_libraries(${target} PRIVATE dynamic_bitset)

	# Link Catch2
	target_link_libraries(${target} PRIVATE Catch2::Catch2)

	# Configure compile options
	cmutils_target_configure_compile_options(${target})
	if(DYNAMICBITSET_ENABLE_COVERAGE)
		target_compile_options(${target} PRIVATE "--coverage")
		if(COMMAND target_link_options)
			target_link_options(${target} PRIVATE "--coverage")
		else()
			# old CMake version: use ugly workaround
			__cmutils_target_link_flag_property(${target} "--coverage")
		endif()
		message(STATUS "${target}: enabled coverage")
	endif()
	# Some MinGW workaround for:
	# "Fatal error: can't write 233 bytes to section .text of tests/CMakeFiles/dynamic_bitset_tests_base.dir/src/main.cpp.obj: 'File too big'"
	if(MINGW)
		target_compile_options(${target} PRIVATE "-Wa,-mbig-obj")
	endif()

	# Enable cmutils default warnings
	cmutils_target_enable_warnings(${target})

	# Require C++17/20
	if(cxx_std_20 IN_LIST CMAKE_CXX_COMPILE_FEATURES)
		target_compile_features(${target} PRIVATE cxx_std_20)
	else()
		target_compile_features(${target} PRIVATE cxx_std_17)
	endif()

	# Enable sanitizers in debug
	#cmutils_target_enable_sanitizers(
	#  ${target}
	#  ADDRESS LEAK MEMORY #UNDEFINED
	#  DEBUG
	#)

	# Set target IDE folder
	cmutils_target_set_ide_folder(${target} "dynamic_bitset")

	# Group sources for IDEs
	cmutils_target_source_group(${target} "${CMAKE_CURRENT_SOURCE_DIR}")

	# Use ccache
	cmutils_target_use_ccache(${target})

	# Generate format target
	cmutils_target_generate_clang_format(${target})
	if(TARGET format-${target})
		cmutils_target_set_ide_folder(format-${target} "dynamic_bitset/format")
	endif()

	# Discover tests
	catch_discover_tests(${target})
endforeach()

# Add compile definitions
target_compile_definitions(
  dynamic_bitset_tests_base PRIVATE
  DYNAMIC_BITSET_NO_LIBPOPCNT
  DYNAMIC_BITSET_NO_STD_BITOPS
  DYNAMIC_BITSET_NO_COMPILER_BUILTIN
)
target_compile_definitions(
  dynamic_bitset_tests_libpopcnt PRIVATE
  DYNAMIC_BITSET_NO_STD_BITOPS
  DYNAMIC_BITSET_NO_COMPILER_BUILTIN
)
target_compile_definitions(
  dynamic_bitset_tests_std_bitops PRIVATE
  DYNAMIC_BITSET_NO_LIBPOPCNT
  DYNAMIC_BITSET_NO_COMPILER_BUILTIN
)
target_compile_definitions(
  dynamic_bitset_tests_builtins PRIVATE
  DYNAMIC_BITSET_NO_LIBPOPCNT
  DYNAMIC_BITSET_NO_STD_BITOPS
)
target_compile_definitions(
  dynamic_bitset_tests_builtins_msvc_32 PRIVATE
  DYNAMIC_BITSET_NO_LIBPOPCNT
  DYNAMIC_BITSET_NO_STD_BITOPS
  DYNAMIC_BITSET_NO_MSVC_BUILTIN_BITSCANFORWARD64
)
