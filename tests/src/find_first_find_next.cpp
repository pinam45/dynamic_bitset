//
// Copyright (c) 2019 Maxime Pinard
//
// Distributed under the MIT license
// See accompanying file LICENSE or copy at
// https://opensource.org/licenses/MIT
//
#include "config.hpp"
#include "utils.hpp"
#include "RandomIntGenerator.hpp"
#include "MultiTakeGenerator.hpp"

#include <catch2/catch.hpp>
#include <sul/dynamic_bitset.hpp>

#include <cstdint>

#if DYNAMIC_BITSET_CAN_USE_STD_BITOPS
#	define FIND_FIRST_FIND_NEXT_TESTED_IMPL "C++20 binary operations"
#elif DYNAMIC_BITSET_CAN_USE_GCC_BUILTIN
#	define FIND_FIRST_FIND_NEXT_TESTED_IMPL "gcc builtins"
#elif DYNAMIC_BITSET_CAN_USE_CLANG_BUILTIN_CTZ
#	define FIND_FIRST_FIND_NEXT_TESTED_IMPL "clang builtins"
#elif DYNAMIC_BITSET_CAN_USE_MSVC_BUILTIN_BITSCANFORWARD
#	if DYNAMIC_BITSET_CAN_USE_MSVC_BUILTIN_BITSCANFORWARD64
#		define FIND_FIRST_FIND_NEXT_TESTED_IMPL "msvc builtins 32/64"
#	else
#		define FIND_FIRST_FIND_NEXT_TESTED_IMPL "msvc builtins 32"
#	endif
#else
#	define FIND_FIRST_FIND_NEXT_TESTED_IMPL "base"
#endif

TEMPLATE_TEST_CASE("find_first find_next (" FIND_FIRST_FIND_NEXT_TESTED_IMPL ")",
                   "[dynamic_bitset][builtin][c++20]",
                   uint16_t,
                   uint32_t,
                   uint64_t)
{
	CAPTURE(SEED);

	SECTION("empty-bitset")
	{
		sul::dynamic_bitset<TestType> bitset;

		REQUIRE(bitset.find_first() == bitset.npos);
		REQUIRE(bitset.find_next(0) == bitset.npos);
	}

	SECTION("non-empty bitset")
	{
		const std::tuple<size_t, size_t> values =
		  GENERATE(multitake(RANDOM_VECTORS_TO_TEST,
		                     randomInt<size_t>(0, 5 * bits_number<TestType>, SEED),
		                     randomInt<size_t>(0, 5 * bits_number<TestType>, SEED + 1)));
		const size_t first_bit_pos = std::get<0>(values);
		const size_t second_bit_pos = first_bit_pos + 1 + std::get<1>(values);
		CAPTURE(first_bit_pos, second_bit_pos);

		sul::dynamic_bitset<TestType> bitset(second_bit_pos + 12);
		REQUIRE(bitset.find_first() == bitset.npos);
		bitset.set(first_bit_pos);
		bitset.set(second_bit_pos);
		REQUIRE(bitset.find_first() == first_bit_pos);
		REQUIRE(bitset.find_next(first_bit_pos) == second_bit_pos);
		REQUIRE(bitset.find_next(second_bit_pos) == bitset.npos);
		REQUIRE(bitset.find_next(bitset.size()) == bitset.npos);
	}
}
