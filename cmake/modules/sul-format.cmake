include_guard()
cmake_minimum_required(VERSION 3.18.4...4.3.4)

function(sul_generate_format_target_from_files target_name)
    # Parse arguments
    cmake_parse_arguments(
      sul_generate_format_target_from_files
      ""
      ""
      "FILES"
      ${ARGN}
    )
    if(sul_generate_format_target_from_files_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unexpected arguments: ${sul_generate_format_target_from_files_UNPARSED_ARGUMENTS}")
    endif()

    # Checks
    if(TARGET ${target_name})
        message(FATAL_ERROR "${target_name} already exists")
    endif()

    # Find clang-format
    find_program(CLANG_FORMAT clang-format)
    if(${CLANG_FORMAT} STREQUAL CLANG_FORMAT-NOTFOUND)
        message(WARNING "clang-format not found, ${target_name} target not generated")
        return()
    endif()

    # Generate target
    add_custom_target(
      ${target_name}
      COMMAND "${CLANG_FORMAT}" -style=file -i ${sul_generate_format_target_from_files_FILES}
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
      VERBATIM
    )
    message(STATUS "Generated format target ${target_name}")

    # Add dependency to format-all
    if(NOT TARGET format-all)
        add_custom_target(format-all)
    endif()
    add_dependencies(format-all ${target_name})
endfunction()

function(sul_generate_format_target_from_target target)
    # Checks
    if(NOT TARGET ${target})
        message(FATAL_ERROR "Invalid argument: ${target} is not a target")
    endif()
    set(format-target "format-${target}")
    if(TARGET ${format-target})
        message(FATAL_ERROR "${format-target} already exists")
    endif()

    # Get sources
    get_target_property(target_sources ${target} CUSTOM_SOURCES)
    if(NOT target_sources)
        get_target_property(target_type ${target} TYPE)
        if(target_type STREQUAL "INTERFACE_LIBRARY")
            message(WARNING "${target} has no CUSTOM_SOURCES set, ${format-target} target not generated")
            return()
        endif()
        get_property(target_sources TARGET ${target} PROPERTY SOURCES)
    endif()

    # Generate target from files
    sul_generate_format_target_from_files(
      ${format-target}
      FILES ${target_sources}
    )
endfunction()
