#
# Copyright (c) 2022 Maxime Pinard
#
# Distributed under the MIT license
# See accompanying file LICENSE or copy at
# https://opensource.org/licenses/MIT
#
cmake_minimum_required(VERSION 3.18) # For check_linker_flag

message(CHECK_START "Compiler flags configuration")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# MSVC debug flags
set(MSVC_DEBUG_FLAGS
  /utf-8 # Set source and execution character sets to UTF-8.
  /validate-charset # Validate UTF-8 files for only compatible characters.
  # /analyse # Enables code analysis.
  /diagnostics:caret # Diagnostics format: prints column and the indicated line of source.
  /W4 # Warning level
  /sdl # Enable Additional Security Checks
  # https://docs.microsoft.com/en-us/cpp/preprocessor/compiler-warnings-that-are-off-by-default
  # /w44061 # enumerator 'identifier' in a switch of enum 'enumeration' is not explicitly handled by a case label
  # /w44062 # enumerator 'identifier' in a switch of enum 'enumeration' is not handled
  # /w14165 # 'HRESULT' is being converted to 'bool'; are you sure this is what you want?
  # /w34191 # 'operator': unsafe conversion from 'type_of_expression' to 'type_required'
  # /w44242 # 'identifier': conversion from 'type1' to 'type2', possible loss of data
  # /w44254 # 'operator': conversion from 'type1' to 'type2', possible loss of data
  # /w44255 # 'function': no function prototype given: converting '()' to '(void)'
  /w44263 # 'function': member function does not override any base class virtual member function
  /w14264 # 'virtual_function': no override available for virtual member function from base 'class'; function is hidden
  /w34265 # 'class': class has virtual functions, but destructor is not virtual
  # /w44266 # 'function': no override available for virtual member function from base 'type'; function is hidden
  /w34287 # 'operator': unsigned/negative constant mismatch
  /w44289 # nonstandard extension used : 'var' : loop control variable declared in the for-loop is used outside the for-loop scope
  /w44296 # 'operator': expression is always false
  # /w44339 # 'type' : use of undefined type detected in CLR meta-data - use of this type may lead to a runtime exception
  # /w14342 # behavior change: 'function' called, but a member operator was called in previous versions
  # /w14350 # behavior change: 'member1' called instead of 'member2'
  /w44355 # 'this' : used in base member initializer list
  /w44365 # 'action': conversion from 'type_1' to 'type_2', signed/unsigned mismatch
  # /w34370 # layout of class has changed from a previous version of the compiler due to better packing
  # /w34371 # 'classname': layout of class may have changed from a previous version of the compiler due to better packing of member 'member'
  # /w44388 # signed/unsigned mismatch
  /w24412 # 'function': function signature contains type 'type'; C++ objects are unsafe to pass between pure code and mixed or native
  # /w14426 # optimization flags changed after including header, may be due to #pragma optimize() 14.1
  # /w44435 # 'class1' : Object layout under /vd2 will change due to virtual base 'class2'
  # /w44437 # dynamic_cast from virtual base 'class1' to 'class2' could fail in some contexts
  # /w34444 # top level '__unaligned' is not implemented in this context
  /w44464 # relative include path contains '..'
  # /w44471 # a forward declaration of an unscoped enumeration must have an underlying type (int assumed) Perm
  # /w14472 # 'identifier' is a native enum: add an access specifier (private/public) to declare a managed enum
  # /w44514 # 'function': unreferenced inline function has been removed
  # /w44536 # 'type name': type-name exceeds meta-data limit of 'limit' characters
  /w14545 # expression before comma evaluates to a function which is missing an argument list
  /w14546 # function call before comma missing argument list
  /w14547 # 'operator': operator before comma has no effect; expected operator with side-effect
  /w14548 # expression before comma has no effect; expected expression with side-effect
  /w14549 # 'operator1': operator before comma has no effect; did you intend 'operator2'?
  /w14555 # expression has no effect; expected expression with side-effect
  /w34557 # '__assume' contains effect 'effect'
  # /w44571 # informational: catch(...) semantics changed since Visual C++ 7.1; structured exceptions (SEH) are no longer caught
  # /w44574 # 'identifier' is defined to be '0': did you mean to use '#if identifier'?
  # /w14577 # 'noexcept' used with no exception handling mode specified; termination on exception is not guaranteed. Specify /EHsc
  # /w44582 # 'type': constructor is not implicitly called
  # /w44583 # 'type': destructor is not implicitly called
  # /w14587 # 'anonymous_structure': behavior change: constructor is no longer implicitly called
  # /w14588 # 'anonymous_structure': behavior change: destructor is no longer implicitly called
  /w44596 # 'identifier': illegal qualified name in member declaration 14.3 Perm
  # /w33598 # '#include "header"': header number header-number in the precompiled header does not match current compilation at that position 14.3
  # /w34599 # 'option path': command-line argument number number does not match pre-compiled header 14.3
  # /w14605 # '/Dmacro' specified on current command line, but was not specified when precompiled header was built
  /w34608 # 'union_member' has already been initialized by another union member in the initializer list, 'union_member' Perm
  # /w34619 # #pragma warning: there is no warning number 'number'
  # /w44623 # 'derived class': default constructor could not be generated because a base class default constructor is inaccessible
  # /w44625 # 'derived class': copy constructor could not be generated because a base class copy constructor is inaccessible
  # /w44626 # 'derived class': assignment operator could not be generated because a base class assignment operator is inaccessible
  /w14628 # digraphs not supported with -Ze. Character sequence 'digraph' not interpreted as alternate token for 'char'
  # /w34640 # 'instance': construction of local static object is not thread-safe
  /w44643 # Forward declaring 'identifier' in namespace std is not permitted by the C++ Standard. 15.8
  # /w34647 # behavior change: __is_pod(type) has different value in previous versions
  /w44654 # Code placed before include of precompiled header line will be ignored. Add code to precompiled header. 14.1
  /w44668 # 'symbol' is not defined as a preprocessor macro, replacing with '0' for 'directives'
  # /w44682 # 'symbol' : no directional parameter attribute specified, defaulting to [in]
  # /w34686 # 'user-defined type': possible change in behavior, change in UDT return calling convention
  # /w14692 # 'function': signature of non-private member contains assembly private native type 'native_type'
  # /w44710 # 'function': function not inlined
  # /w34738 # storing 32-bit float result in memory, possible loss of performance
  # /w44746 # volatile access of 'expression' is subject to /volatile:<iso|ms> setting; consider using __iso_volatile_load/store intrinsic functions
  # /w44749 # conditionally supported: offsetof applied to non-standard-layout type 'type'
  # /w44767 # section name 'symbol' is longer than 8 characters and will be truncated by the linker
  # /w44774 # 'string' : format string expected in argument number is not a string literal
  /w44777 # 'function' : format string 'string' requires an argument of type 'type1', but variadic argument number has type 'type2'
  # /w34786 # 'symbol' : object name was truncated to 'number' characters in the debug information
  # /w44800 # Implicit conversion from 'type' to bool. Possible information loss 16.0
  # /w44820 # 'bytes' bytes padding added after construct 'member_name'
  /w14822 # 'member': local class member function does not have a body
  # /w24826 # Conversion from 'type1' to 'type2' is sign-extended. This may cause unexpected runtime behavior.
  /w44837 # trigraph detected: '??character' replaced by 'character'
  /w44841 # non-standard extension used: compound member designator used in offsetof
  # /w44842 # the result of 'offsetof' applied to a type using multiple inheritance is not guaranteed to be consistent between compiler releases
  # /w44866 # 'file(line-number)' compiler may not enforce left-to-right evaluation order for call to operator
  # /w44868 # 'file(line_number)' compiler may not enforce left-to-right evaluation order in braced initialization list
  # /w14905 # wide string literal cast to 'LPSTR'
  # /w14906 # string literal cast to 'LPWSTR'
  /w14917 # 'declarator': a GUID can only be associated with a class, interface, or namespace
  /w14928 # illegal copy-initialization; more than one user-defined conversion has been implicitly applied
  # /w44931 # we are assuming the type library was built for number-bit pointers
  /w14946 # reinterpret_cast used between related classes: 'class1' and 'class2'
  # /w44962 # 'function': profile-guided optimizations disabled because optimizations caused profile data to become inconsistent
  /w44986 # 'symbol': exception specification does not match previous declaration
  /w44987 # nonstandard extension used: 'throw (...)'
  # /w44988 # 'symbol': variable declared outside class/function scope
  # /w45022 # 'type': multiple move constructors specified
  # /w45023 # 'type': multiple move assignment operators specified
  # /w45024 # 'type': move constructor was implicitly defined as deleted
  # /w45025 # 'type': move assignment operator was implicitly defined as deleted
  # /w45026 # 'type': move constructor was implicitly defined as deleted
  # /w45027 # 'type': move assignment operator was implicitly defined as deleted
  /w45029 # nonstandard extension used: alignment attributes in C++ apply to variables, data members and tag types only
  /w45031 # #pragma warning(pop): likely mismatch, popping warning state pushed in different file 14.1
  /w45032 # detected #pragma warning(push) with no corresponding #pragma warning(pop) 14.1
  # /w45034 # use of intrinsic 'intrinsic' causes function function-name to be compiled as guest code 15.3
  # /w45035 # use of feature 'feature' causes function function-name to be compiled as guest code 15.3
  # /w15036 # varargs function pointer conversion when compiling with /hybrid:x86arm64 'type1' to 'type2' 15.3
  /w45038 # data member 'member1' will be initialized after data member 'member2' 15.3
  # /w45039 # 'function': pointer or reference to potentially throwing function passed to extern C function under -EHc. Undefined behavior may occur if this function throws an exception. 15.5
  /w45041 # 'member-name': out-of-line definition for constexpr static data member is not needed and is deprecated in C++17. 15.2
  /w35042 # 'function': function declarations at block scope cannot be specified 'inline' in standard C++; remove 'inline' specifier 15.5
  # /w45045 # Compiler will insert Spectre mitigation for memory load if /Qspectre switch specified 15.7
  # /w35052 # Keyword 'keyword-name' was introduced in C++version and requires use of the 'option' command-line option` 16.1
  /w35204 # A class with virtual functions has non-virtual trivial destructor. 16.5
  /w45214 # applying 'keyword' to an operand with a volatile qualified type is deprecated in C++20 16.7
  /w45215 # 'function-parameter' a function parameter with a volatile qualified type is deprecated in C++20 16.7
  /w45216 # 'return-type' a volatile qualified return type is deprecated in C++20 16.7
  /w45217 # a structured binding declaration that includes volatile is deprecated in C++20 16.7
  # /w25219 # implicit conversion from 'type-1' to 'type-2', possible loss of data 16.7
  # /w45220 # 'member': a non-static data member with a volatile qualified type no longer implies that compiler generated copy/move constructors and copy/move assignment operators are not trivial 16.7
  /w45233 # explicit lambda capture 'identifier' is not used 16.10
  /w45240 # 'attribute-name': attribute is ignored in this syntactic position 16.10
  /w15243 # 'type-name': using incomplete class 'class-name' can cause potential one definition rule violation due to ABI limitation 16.10
  # /w45245 # 'function': unreferenced function with internal linkage has been removed
  /w15246 # 'member': the initialization of a subobject should be wrapped in braces 16.10
  /w15247 # Section 'section-name' is reserved for C++ dynamic initialization. Manually creating the section will interfere with C++ dynamic initialization and may lead to undefined behavior 16.11
  /w15248 # Section 'section-name' is reserved for C++ dynamic initialization. Variable manually put into the section may be optimized out and its order relative to compiler generated dynamic initializers is unspecified 16.11
  /w15249 # 'bitfield' of type 'enumeration_name' has named enumerators with values that cannot be represented in the given bit field width of 'bitfield_width'. 17.0
  /w35250 # 'function_name': intrinsic function not declared. 17.0
  # /w45251 # segment-name changed after including header 17.1
  # /w45254 # language feature 'terse static assert' requires compiler flag '/std:c++17' 17.1

  ## Explicitly disabled warnings
  /wd4702 # unreachable code
)

# GCC debug flags
set(GCC_DEBUG_FLAGS
  # General: https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
  -Wfatal-errors
  # -fanalyzer
  -Wlifetime
  -pedantic
  -pedantic-errors
  -Wall
  -Wextra
  -Wdouble-promotion
  -Wformat=2
  -Wformat-signedness
  -Wnull-dereference
  -Wimplicit-fallthrough
  -Wif-not-aligned
  -Wmissing-include-dirs
  # -Wswitch-default
  # -Wswitch-enum
  -Wswitch-bool
  -Wswitch-unreachable
  # -Wunused-parameter
  -Wuninitialized
  -Wstrict-overflow=5
  -Walloc-zero
  -Wduplicated-branches
  -Wduplicated-cond
  -Wfloat-equal
  -Wshadow
  -Wundef
  -Wcast-qual
  -Wcast-align
  -Wconversion
  -Wsign-conversion
  -Wdate-time
  -Wlogical-op
  -Wmissing-declarations
  -Wredundant-decls
  -Wrestrict
  -Winterference-size
  -Winvalid-pch
  -Wvla
  -Woverlength-strings
  # C++ specific: https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Dialect-Options.html
  -Wcomma-subscript
  -Wctad-maybe-unsupported
  -Wctor-dtor-privacy
  -Wnoexcept
  -Wnon-virtual-dtor
  -Wregister
  -Wredundant-tags
  -Wstrict-null-sentinel
  -Wold-style-cast
  # -Woverloaded-virtual
  -Wmismatched-tags
  -Wvolatile
  -Wzero-as-null-pointer-constant
  -Wextra-semi
  # -Wuseless-cast
  -Wsubobject-linkage
  -Wdelete-incomplete
  # Suggest
  -Weffc++
  -Wsuggest-override
  #-Wsuggest-final-types
  #-Wsuggest-final-methods
  #-Wsuggest-attribute=pure
  #-Wsuggest-attribute=const
  #-Wsuggest-attribute=noreturn
  #-Wsuggest-attribute=format
)

# CLANG debug flags
set(CLANG_DEBUG_FLAGS
  # https://clang.llvm.org/docs/DiagnosticsReference.html
  -Wfatal-errors
  -Wlifetime
  -pedantic
  -pedantic-errors
  -Wall
  -Wextra
  -Wbad-function-cast
  -Wcomma
  -Wcomment
  -Wcomplex-component-init
  -Wconditional-uninitialized
  -Wcovered-switch-default
  -Wcstring-format-directive
  -Wdelete-non-virtual-dtor
  -Wdeprecated
  -Wdollar-in-identifier-extension
  -Wdouble-promotion
  -Wduplicate-enum
  -Wduplicate-method-arg
  -Wembedded-directive
  -Wexpansion-to-defined
  -Wfloat-conversion
  -Wfloat-equal
  -Wfor-loop-analysis
  -Wformat-pedantic
  -Wgnu
  -Wimplicit-fallthrough
  -Winfinite-recursion
  -Winvalid-or-nonexistent-directory
  -Wkeyword-macro
  -Wmain
  -Wmethod-signatures
  -Wmicrosoft
  -Wmismatched-tags
  -Wmissing-field-initializers
  -Wmissing-method-return-type
  -Wmissing-prototypes
  -Wmissing-variable-declarations
  -Wnested-anon-types
  -Wnon-virtual-dtor
  -Wnonportable-system-include-path
  -Wnull-pointer-arithmetic
  -Wnullability-extension
  -Wold-style-cast
  -Woverriding-method-mismatch
  -Wpacked
  -Wpedantic
  -Wpessimizing-move
  -Wredundant-move
  -Wreserved-id-macro
  -Wself-assign
  -Wself-move
  -Wsemicolon-before-method-body
  -Wshadow
  -Wshadow-field
  -Wshadow-field-in-constructor
  -Wshadow-uncaptured-local
  -Wshift-sign-overflow
  -Wshorten-64-to-32
  -Wconversion
  -Wsigned-enum-bitfield
  -Wstatic-in-inline
  -Wtautological-compare
  -Wtautological-overlap-compare
  -Wthread-safety
  -Wundefined-reinterpret-cast
  -Wuninitialized
  -Wunreachable-code
  -Wunreachable-code-aggressive
  -Wunused-const-variable
  -Wunused-lambda-capture
  -Wunused-local-typedef
  -Wunused-parameter
  -Wunused-private-field
  -Wunused-template
  -Wunused-variable
  -Wused-but-marked-unused
  -Wzero-as-null-pointer-constant
  -Wzero-length-array
)

# Asan flags
set(GCC_GLANG_ASAN_FLAGS
  -fsanitize=address
  -fno-omit-frame-pointer
  -fno-optimize-sibling-calls
)
set(MSVC_ASAN_FLAGS /fsanitize=address)

# UBsan flags
set(GCC_GLANG_UBSAN_FLAGS
  -fsanitize=undefined
  -fsanitize=shift
  -fsanitize=shift-exponent
  -fsanitize=shift-base
  -fsanitize=integer-divide-by-zero
  -fsanitize=unreachable
  -fsanitize=vla-bound
  -fsanitize=null
  -fsanitize=return
  -fsanitize=bounds
  -fsanitize=bounds-strict
  -fsanitize=alignment
  -fsanitize=object-size
  -fsanitize=float-divide-by-zero
  -fsanitize=float-cast-overflow # detect floating-point division by zero which can be legitimate to get infinity and NaN
  -fsanitize=nonnull-attribute
  -fsanitize=returns-nonnull-attribute
  -fsanitize=bool
  -fsanitize=enum
  -fsanitize=pointer-overflow
  -fsanitize=builtin
  # -fno-sanitize=vptr # linking problems on buster
)
set(MSVC_UBSAN_FLAGS)

# Tsan flags
set(GCC_GLANG_TSAN_FLAGS
  -fsanitize=thread
)
set(MSVC_TSAN_FLAGS)

# Identify compiler
set(DEGUG_FLAGS)
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
	message(STATUS "C++ compiler is MSVC-like Clang")
	set(DEGUG_FLAGS ${MSVC_DEBUG_FLAGS})
	set(ASAN_FLAGS ${MSVC_ASAN_FLAGS})
	set(UBSAN_FLAGS ${MSVC_UBSAN_FLAGS})
	set(TSAN_FLAGS ${MSVC_TSAN_FLAGS})
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
	message(STATUS "C++ compiler is Microsoft Visual Studio")
	set(DEGUG_FLAGS ${MSVC_DEBUG_FLAGS})
	set(ASAN_FLAGS ${MSVC_ASAN_FLAGS})
	set(UBSAN_FLAGS ${MSVC_UBSAN_FLAGS})
	set(TSAN_FLAGS ${MSVC_TSAN_FLAGS})
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	message(STATUS "C++ compiler is LLVM Clang")
	set(DEGUG_FLAGS ${CLANG_DEBUG_FLAGS})
	set(ASAN_FLAGS ${GCC_GLANG_ASAN_FLAGS})
	set(UBSAN_FLAGS ${GCC_GLANG_UBSAN_FLAGS})
	set(TSAN_FLAGS ${GCC_GLANG_TSAN_FLAGS})
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
	message(STATUS "C++ compiler is Apple Clang")
	set(DEGUG_FLAGS ${CLANG_DEBUG_FLAGS})
	set(ASAN_FLAGS ${GCC_GLANG_ASAN_FLAGS})
	set(UBSAN_FLAGS ${GCC_GLANG_UBSAN_FLAGS})
	set(TSAN_FLAGS ${GCC_GLANG_TSAN_FLAGS})
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	message(STATUS "C++ compiler is GNU Compiler Collection")
	set(DEGUG_FLAGS ${GCC_DEBUG_FLAGS})
	set(ASAN_FLAGS ${GCC_GLANG_ASAN_FLAGS})
	set(UBSAN_FLAGS ${GCC_GLANG_UBSAN_FLAGS})
	set(TSAN_FLAGS ${GCC_GLANG_TSAN_FLAGS})
else()
	message(STATUS "Unknown compiler ID: ${CMAKE_CXX_COMPILER_ID}")
endif()

# Initialize sanitizers build type flags from debug
foreach(build_type ASAN UBSAN TSAN SANITIZE)
	#set(CMAKE_C_FLAGS_${build_type} "${CMAKE_C_FLAGS_DEBUG}")
	set(CMAKE_CXX_FLAGS_${build_type} "${CMAKE_CXX_FLAGS_DEBUG}")
	set(CMAKE_EXE_LINKER_FLAGS_${build_type} "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
	set(CMAKE_SHARED_LINKER_FLAGS_${build_type} "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
endforeach()

# Set sanitizers flags
include(CheckLinkerFlag)
message(CHECK_START "Adding Asan flags reported as supported by the C++ compiler")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
foreach(flag ${ASAN_FLAGS})
	string(REGEX REPLACE "[-+*/=_]" "_" flag_supported "${flag}")
	check_linker_flag(CXX "${flag}" ${flag_supported})
	if(${flag_supported})
		foreach(build_type ASAN SANITIZE)
			#set(CMAKE_C_FLAGS_${build_type} "${CMAKE_C_FLAGS_${build_type}} ${flag}")
			set(CMAKE_CXX_FLAGS_${build_type} "${CMAKE_CXX_FLAGS_${build_type}} ${flag}")
			set(CMAKE_EXE_LINKER_FLAGS_${build_type} "${CMAKE_EXE_LINKER_FLAGS_${build_type}} ${flag}")
			set(CMAKE_SHARED_LINKER_FLAGS_${build_type} "${CMAKE_SHARED_LINKER_FLAGS_${build_type}} ${flag}")
		endforeach()
		message(STATUS "[O] ${flag}")
	else()
		message(STATUS "[X] ${flag}")
	endif()
endforeach()
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

message(CHECK_START "Adding UBsan flags reported as supported by the C++ compiler")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
foreach(flag ${UBSAN_FLAGS})
	string(REGEX REPLACE "[-+*/=_]" "_" flag_supported "${flag}")
	check_linker_flag(CXX "${flag}" ${flag_supported})
	if(${flag_supported})
		foreach(build_type UBSAN SANITIZE)
			#set(CMAKE_C_FLAGS_${build_type} "${CMAKE_C_FLAGS_${build_type}} ${flag}")
			set(CMAKE_CXX_FLAGS_${build_type} "${CMAKE_CXX_FLAGS_${build_type}} ${flag}")
			set(CMAKE_EXE_LINKER_FLAGS_${build_type} "${CMAKE_EXE_LINKER_FLAGS_${build_type}} ${flag}")
			set(CMAKE_SHARED_LINKER_FLAGS_${build_type} "${CMAKE_SHARED_LINKER_FLAGS_${build_type}} ${flag}")
		endforeach()
		message(STATUS "[O] ${flag}")
	else()
		message(STATUS "[X] ${flag}")
	endif()
endforeach()
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

message(CHECK_START "Adding Tsan flags reported as supported by the C++ compiler")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
foreach(flag ${TSAN_FLAGS})
	string(REGEX REPLACE "[-+*/=_]" "_" flag_supported "${flag}")
	check_linker_flag(CXX "${flag}" ${flag_supported})
	if(${flag_supported})
		#set(CMAKE_C_FLAGS_TSAN "${CMAKE_C_FLAGS_TSAN} ${flag}")
		set(CMAKE_CXX_FLAGS_TSAN "${CMAKE_CXX_FLAGS_TSAN} ${flag}")
		set(CMAKE_EXE_LINKER_FLAGS_TSAN "${CMAKE_EXE_LINKER_FLAGS_TSAN} ${flag}")
		set(CMAKE_SHARED_LINKER_FLAGS_TSAN "${CMAKE_SHARED_LINKER_FLAGS_TSAN} ${flag}")
		message(STATUS "[O] ${flag}")
	else()
		message(STATUS "[X] ${flag}")
	endif()
endforeach()
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

# Put sanitizers build type base flags in cache, thus used by projects added by add_subdirectory(...)
foreach(build_type ASAN UBSAN TSAN SANITIZE)
	#set(CMAKE_C_FLAGS_${build_type}
	#  "${CMAKE_C_FLAGS_${build_type}}"
	#  CACHE STRING "Flags used by the C compiler during ${build_type} builds."
	#  FORCE
	#)
	set(CMAKE_CXX_FLAGS_${build_type}
	  "${CMAKE_CXX_FLAGS_${build_type}}"
	  CACHE STRING "Flags used by the CXX compiler during ${build_type} builds."
	  FORCE
	)
	set(CMAKE_EXE_LINKER_FLAGS_${build_type}
	  "${CMAKE_EXE_LINKER_FLAGS_${build_type}}"
	  CACHE STRING "Flags used by the linker during ${build_type} builds."
	  FORCE
	)
	set(CMAKE_SHARED_LINKER_FLAGS_${build_type}
	  "${CMAKE_SHARED_LINKER_FLAGS_${build_type}}"
	  CACHE STRING "Flags used by the linker during the creation of shared libraries during ${build_type} builds."
	  FORCE
	)
	mark_as_advanced(
	  #CMAKE_C_FLAGS_${build_type}
	  CMAKE_CXX_FLAGS_${build_type}
	  CMAKE_EXE_LINKER_FLAGS_${build_type}
	  CMAKE_SHARED_LINKER_FLAGS_${build_type}
	)
endforeach()

# Set debug flags
include(CheckCXXCompilerFlag)
message(CHECK_START "Adding debug flags reported as supported by the C++ compiler")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
foreach(flag ${DEGUG_FLAGS})
	string(REGEX REPLACE "[-+*/=_]" "_" flag_supported "${flag}")
	check_cxx_compiler_flag("${flag}" ${flag_supported})
	if(${flag_supported})
		foreach(build_type DEBUG RELWITHDEBINFO ASAN UBSAN TSAN SANITIZE)
			set(CMAKE_CXX_FLAGS_${build_type} "${CMAKE_CXX_FLAGS_${build_type}} ${flag}")
		endforeach()
		message(STATUS "[O] ${flag}")
	else()
		message(STATUS "[X] ${flag}")
	endif()
endforeach()
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")
