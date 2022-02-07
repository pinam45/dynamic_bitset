# Check dynamic_bitset
if(NOT TARGET dynamic_bitset)
	message(FATAL_ERROR "dynamic_bitset target required for the example")
endif()

# Declare dynamic_bitset_example
add_executable(dynamic_bitset_example)
set_target_properties(dynamic_bitset_example PROPERTIES FOLDER "dynamic_bitset")

# Add sources
target_sources(dynamic_bitset_example PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp")

# Link dynamic_bitset
target_link_libraries(dynamic_bitset_example PRIVATE dynamic_bitset)

# Require C++17/20
if(cxx_std_20 IN_LIST CMAKE_CXX_COMPILE_FEATURES)
	target_compile_features(dynamic_bitset_example PRIVATE cxx_std_20)
else()
	target_compile_features(dynamic_bitset_example PRIVATE cxx_std_17)
endif()

# Generate format target?
if(DYNAMICBITSET_FORMAT_TARGET)
	add_custom_target(
	  format-dynamic_bitset_example
	  COMMAND "${CLANG_FORMAT}" -style=file -i "${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp"
	  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
	  VERBATIM
	)
	set_target_properties(format-dynamic_bitset_example PROPERTIES FOLDER "dynamic_bitset/format")
endif()
