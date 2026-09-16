include_guard()
cmake_minimum_required(VERSION 3.18.4...4.3.4)

set(SUL_TIDY_TARGET_RUN_PARALLEL 4 CACHE STRING "How many parallel clang-tidy to run by *-tidy target when using run-clang-tidy (warning: the targets can be themselves run in parallel)")

function(sul_generate_tidy_target_from_files target_name)
    # Parse arguments
    cmake_parse_arguments(
      sul_generate_tidy_target_from_files
      ""
      ""
      "FILES"
      ${ARGN}
    )
    if(sul_generate_tidy_target_from_files_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unexpected arguments: ${sul_generate_tidy_target_from_files_UNPARSED_ARGUMENTS}")
    endif()

    # Checks
    if(TARGET ${target_name})
        message(FATAL_ERROR "${target_name} already exists")
    endif()

    # Find run-clang-tidy or clang-tidy
    set(SELECTED_CLANG_TIDY)
    set(CLANG_TIDY_PARALLEL_PARAM "")
    find_program(RUN_CLANG_TIDY run-clang-tidy)
    if(${RUN_CLANG_TIDY} STREQUAL RUN_CLANG_TIDY-NOTFOUND)
        message(WARNING "run-clang-tidy not found, using normal clang-tidy")
        find_program(CLANG_TIDY clang-tidy)
        if(${CLANG_TIDY} STREQUAL CLANG_TIDY-NOTFOUND)
            message(WARNING "clang-tidy not found, ${target_name} target not generated")
            return()
        endif()
        set(SELECTED_CLANG_TIDY "${CLANG_TIDY}")
    else()
        set(SELECTED_CLANG_TIDY "${RUN_CLANG_TIDY}" "-j" ${SUL_TIDY_TARGET_RUN_PARALLEL})
    endif()

    # Generate target
    add_custom_target(
      ${target_name}
      COMMAND ${SELECTED_CLANG_TIDY} -quiet -p ${CMAKE_BINARY_DIR} ${sul_generate_tidy_target_from_files_FILES}
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      VERBATIM
    )
    message(STATUS "Generated tidy target ${tidy-target}")

    # Add dependency to tidy-all
    if(NOT TARGET tidy-all)
        add_custom_target(tidy-all)
    endif()
    add_dependencies(tidy-all ${tidy-target})
endfunction()

function(sul_generate_tidy_target_from_target target)
    # Checks
    if(NOT TARGET ${target})
        message(FATAL_ERROR "Invalid argument: ${target} is not a target")
    endif()
    set(tidy-target "tidy-${target}")
    if(TARGET ${tidy-target})
        message(FATAL_ERROR "${tidy-target} already exists")
    endif()

    # Get sources
    get_target_property(target_sources ${target} CUSTOM_SOURCES)
    if(NOT target_sources)
        get_target_property(target_type ${target} TYPE)
        if(target_type STREQUAL "INTERFACE_LIBRARY")
            message(WARNING "${target} has no CUSTOM_SOURCES set, ${tidy-target} target not generated")
            return()
        endif()
        get_property(target_sources TARGET ${target} PROPERTY SOURCES)
    endif()

    # Generate target from files
    sul_generate_tidy_target_from_files(
      ${tidy-target}
      FILES ${target_sources}
    )
endfunction()
