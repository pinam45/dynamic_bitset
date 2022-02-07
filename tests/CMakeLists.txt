cmake_minimum_required(VERSION 3.18) # For target_link_options

# Options
option(DYNAMICBITSET_ENABLE_COVERAGE "Enable coverage information generation" OFF)

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
file(GLOB_RECURSE sources "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
file(GLOB_RECURSE includes "${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp")
target_sources(
  dynamic_bitset_tests_base PRIVATE
  ${includes}
  ${sources}
)
target_sources(
  dynamic_bitset_tests_libpopcnt PRIVATE
  ${includes}
  "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/count.cpp"
)
target_sources(
  dynamic_bitset_tests_std_bitops PRIVATE
  ${includes}
  "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/count.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/find_first_find_next.cpp"
)
target_sources(
  dynamic_bitset_tests_builtins PRIVATE
  ${includes}
  "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/count.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/find_first_find_next.cpp"
)
target_sources(
  dynamic_bitset_tests_builtins_msvc_32 PRIVATE
  ${includes}
  "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/find_first_find_next.cpp"
)
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${includes} ${sources})

foreach(
  target
  dynamic_bitset_tests_base
  dynamic_bitset_tests_libpopcnt
  dynamic_bitset_tests_std_bitops
  dynamic_bitset_tests_builtins
  dynamic_bitset_tests_builtins_msvc_32
)
	# Set target IDE folder
	set_target_properties(${target} PROPERTIES FOLDER "dynamic_bitset/tests")

	# Add includes
	target_include_directories(
	  ${target} PRIVATE
	  "${CMAKE_CURRENT_SOURCE_DIR}/include"
	)

	# Link dynamic_bitset
	target_link_libraries(${target} PRIVATE dynamic_bitset)

	# Link Catch2
	target_link_libraries(${target} PRIVATE Catch2::Catch2)

	# Enable coverage information generation?
	if(DYNAMICBITSET_ENABLE_COVERAGE)
		target_compile_options(${target} PRIVATE "--coverage")
		target_link_options(${target} PRIVATE "--coverage")
		message(STATUS "${target}: enabled coverage")
	endif()
	# Some MinGW workaround for:
	# "Fatal error: can't write 233 bytes to section .text of tests/CMakeFiles/dynamic_bitset_tests_base.dir/src/main.cpp.obj: 'File too big'"
	if(MINGW)
		target_compile_options(${target} PRIVATE "-Wa,-mbig-obj")
	endif()

	# Require C++17/20
	if(cxx_std_20 IN_LIST CMAKE_CXX_COMPILE_FEATURES)
		target_compile_features(${target} PRIVATE cxx_std_20)
	else()
		target_compile_features(${target} PRIVATE cxx_std_17)
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

# Generate format target?
if(DYNAMICBITSET_FORMAT_TARGET)
	add_custom_target(
	  format-dynamic_bitset_tests
	  COMMAND "${CLANG_FORMAT}" -style=file -i ${includes} ${sources}
	  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	  VERBATIM
	)
	set_target_properties(format-dynamic_bitset_tests PROPERTIES FOLDER "dynamic_bitset/format")
endif()
