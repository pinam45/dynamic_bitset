//
// Copyright (c) 2019 Maxime Pinard
//
// Distributed under the MIT license
// See accompanying file LICENSE or copy at
// https://opensource.org/licenses/MIT
//
#include "config.hpp"
#include "utils.hpp"
#include "RandomDynamicBitsetGenerator.hpp"

#include <catch2/catch.hpp>
#include <sul/dynamic_bitset.hpp>

#include <cstdint>

#if DYNAMIC_BITSET_CAN_USE_LIBPOPCNT
#	define COUNT_TESTED_IMPL "libpopcnt"
#elif DYNAMIC_BITSET_CAN_USE_STD_BITOPS
#	define COUNT_TESTED_IMPL "C++20 binary operations"
#elif DYNAMIC_BITSET_CAN_USE_GCC_BUILTIN
#	define COUNT_TESTED_IMPL "gcc builtins"
#elif DYNAMIC_BITSET_CAN_USE_CLANG_BUILTIN_POPCOUNT
#	define COUNT_TESTED_IMPL "clang builtins"
#else
#	define COUNT_TESTED_IMPL "base"
#endif

TEMPLATE_TEST_CASE("count (" COUNT_TESTED_IMPL ")",
                   "[dynamic_bitset][libpopcnt][builtin][c++20]",
                   uint16_t,
                   uint32_t,
                   uint64_t)
{
	CAPTURE(SEED);

	SECTION("empty bitset")
	{
		sul::dynamic_bitset<TestType> bitset;

		REQUIRE(bitset.count() == 0);
	}

	SECTION("non-empty bitset")
	{
		sul::dynamic_bitset<TestType> bitset =
		  GENERATE(take(RANDOM_VECTORS_TO_TEST, randomDynamicBitset<TestType>(SEED)));
		CAPTURE(bitset);

		size_t count = 0;
		for(size_t i = 0; i < bitset.size(); ++i)
		{
			count += static_cast<size_t>(bitset[i]);
		}

		SECTION("general")
		{
			REQUIRE(bitset.count() == count);
		}

		SECTION("first block empty")
		{
			bitset.append(0);
			bitset <<= bits_number<TestType>;
			REQUIRE(bitset.count() == count);
		}

		SECTION("last block empty")
		{
			bitset.append(0);
			REQUIRE(bitset.count() == count);
		}
	}
}
