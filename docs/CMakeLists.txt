# Check dynamic_bitset
if(NOT TARGET dynamic_bitset)
	message(FATAL_ERROR "dynamic_bitset target required for the docs")
endif()

# doxygen-awesome-css
get_filename_component(DOXYGEN_AWESOME_CSS_PATH "${CMAKE_CURRENT_SOURCE_DIR}/doxygen-awesome-css" ABSOLUTE)
if(NOT EXISTS "${DOXYGEN_AWESOME_CSS_PATH}/README.md")
	message(FATAL_ERROR "doxygen-awesome-css dependency is missing, maybe you didn't pull the git submodules")
endif()

# Find Doxygen
find_package(Doxygen QUIET)
if(DOXYGEN_FOUND)
	message(STATUS "Doxygen ${DOXYGEN_VERSION} found")
else()
	message(WARNING "Doxygen not found, dynamic_bitset_docs target not generated")
	return()
endif()

# Configure Doxygen
set(DOXYGEN_GENERATE_TREEVIEW YES)
#set(DOXYGEN_DISABLE_INDEX YES)
set(DOXYGEN_GENERATE_HTML YES)
set(DOXYGEN_GENERATE_LATEX NO)
set(DOXYGEN_GENERATE_XML NO)
set(DOXYGEN_FULL_PATH_NAMES YES)
set(DOXYGEN_STRIP_FROM_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../include")
set(DOXYGEN_STRIP_FROM_INC_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../include")
set(DOXYGEN_EXCLUDE_SYMBOLS "DYNAMIC_BITSET_CAN_USE_*")
set(DOXYGEN_ALIASES "\"complexity=@par Complexity^^\"")
set(DOXYGEN_OUTPUT_LANGUAGE "English")
set(DOXYGEN_MARKDOWN_SUPPORT YES)
set(
  DOXYGEN_HTML_EXTRA_STYLESHEET
  "${DOXYGEN_AWESOME_CSS_PATH}/doxygen-awesome.css"
  "${DOXYGEN_AWESOME_CSS_PATH}/doxygen-awesome-sidebar-only.css"
  "${DOXYGEN_AWESOME_CSS_PATH}/doxygen-awesome-sidebar-only-darkmode-toggle.css"
  "${CMAKE_CURRENT_SOURCE_DIR}/custom.css"
)

# Set files and generate target
set(DOXYGEN_USE_MDFILE_AS_MAINPAGE README.md)
doxygen_add_docs(dynamic_bitset_docs
	"${CMAKE_CURRENT_SOURCE_DIR}/../include/sul/dynamic_bitset.hpp"
	"${CMAKE_CURRENT_SOURCE_DIR}/../README.md"
	COMMENT "Generate dynamic_bitset docs"
)

# Set target IDE folder
set_target_properties(dynamic_bitset_docs PROPERTIES FOLDER "dynamic_bitset")
