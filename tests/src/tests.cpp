//
// Copyright (c) 2019 Maxime Pinard
//
// Distributed under the MIT license
// See accompanying file LICENSE or copy at
// https://opensource.org/licenses/MIT
//
#include "RandomIntGenerator.hpp"
#include "RandomDynamicBitsetGenerator.hpp"
#include "MultiTakeGenerator.hpp"

#include <catch2/catch.hpp>
#include <dynamic_bitset.hpp>

#include <algorithm>
#include <cstdint>

constexpr size_t RANDOM_VECTORS_TO_TEST = 24;
constexpr std::minstd_rand::result_type SEED = 314159;
//const std::minstd_rand::result_type SEED = std::random_device{}();

template<typename T>
constexpr size_t bits_number = sizeof(T) * CHAR_BIT;

template<typename T>
constexpr bool bit_value(T value, size_t bit_pos)
{
	static_assert(std::is_unsigned<T>::value, "T is not an unsigned integral type");
	assert(bit_pos < bits_number<T>);
	return (value & (T(1) << bit_pos)) != T(0);
}

TEMPLATE_TEST_CASE("constructors", "[dynamic_bitset]", uint16_t, uint32_t, uint64_t)
{
	CAPTURE(SEED);

	SECTION("default constructor")
	{
		dynamic_bitset<TestType> bitset;

		REQUIRE(bitset.empty());
		REQUIRE(bitset.size() == 0);
		REQUIRE(bitset.capacity() == 0);
	}

	SECTION("nbits and init_val constructor")
	{
		const unsigned long long init_value =
		  GENERATE(take(RANDOM_VECTORS_TO_TEST, randomInt<unsigned long long>(SEED)));
		const size_t bits_to_take =
		  GENERATE(take(1, randomInt<size_t>(0, bits_number<unsigned long long>, SEED)));
		CAPTURE(init_value, bits_to_take);

		// call dynamic_bitset constructor
		const dynamic_bitset<TestType> bitset(bits_to_take, init_value);
		CAPTURE(bitset);

		// check init value bits
		for(size_t i = 0; i < bits_to_take; ++i)
		{
			CAPTURE(i);
			REQUIRE(bitset[i] == bit_value(init_value, i));
		}
	}

	SECTION("initializer_list constructor")
	{
		SECTION("one value")
		{
			const TestType init_value =
			  GENERATE(take(RANDOM_VECTORS_TO_TEST, randomInt<TestType>(SEED)));
			const dynamic_bitset<TestType> bitset = {init_value};

			// check bits
			for(size_t i = 0; i < bits_number<TestType>; ++i)
			{
				CAPTURE(i);
				REQUIRE(bitset[i] == bit_value(init_value, i));
			}
		}

		SECTION("two values")
		{
			const std::tuple<TestType, TestType> init_values = GENERATE(multitake(
			  RANDOM_VECTORS_TO_TEST, randomInt<TestType>(SEED), randomInt<TestType>(SEED + 1)));
			std::initializer_list<TestType> init_values_list = {std::get<0>(init_values),
			                                                    std::get<1>(init_values)};
			const dynamic_bitset<TestType> bitset = init_values_list;
			CAPTURE(bitset, init_values_list);

			// check bits
			size_t value_i = 0;
			for(const TestType& value: init_values_list)
			{
				for(size_t bit_i = 0; bit_i < bits_number<TestType>; ++bit_i)
				{
					CAPTURE(value_i, bit_i);
					REQUIRE(bitset[value_i * bits_number<TestType> + bit_i]
					        == bit_value(value, bit_i));
				}
				++value_i;
			}
		}
	}
}

TEMPLATE_TEST_CASE("resize", "[dynamic_bitset]", uint16_t, uint32_t, uint64_t)
{
	CAPTURE(SEED);
	dynamic_bitset<TestType> bitset =
	  GENERATE(take(RANDOM_VECTORS_TO_TEST, randomDynamicBitset<TestType>(SEED)));
	CAPTURE(bitset);

	SECTION("resizing to 0")
	{
		bitset.resize(0);
		REQUIRE(bitset.empty());
		REQUIRE(bitset.size() == 0);
	}

	SECTION("resizing to the same size")
	{
		const size_t size_save = bitset.size();
		bitset.resize(bitset.size());
		REQUIRE(bitset.size() == size_save);
	}

	SECTION("changing size")
	{
		size_t size_change = GENERATE(take(3, randomInt<size_t>(0, 128, SEED)));
		const bool new_values = GENERATE(true, false);
		CAPTURE(size_change, new_values);

		SECTION("incrementing size")
		{
			const dynamic_bitset<TestType> bitset_copy = bitset;
			const size_t new_size = bitset.size() + size_change;
			bitset.resize(new_size, new_values);
			REQUIRE(bitset.size() == new_size);

			for(size_t i = 0; i < bitset_copy.size(); ++i)
			{
				CAPTURE(i);
				REQUIRE(bitset[i] == bitset_copy[i]);
			}
			for(size_t i = bitset_copy.size(); i < bitset.size(); ++i)
			{
				CAPTURE(i);
				REQUIRE(bitset[i] == new_values);
			}
		}

		SECTION("decrementing size")
		{
			const dynamic_bitset<TestType> bitset_copy = bitset;
			const size_t new_size = size_change > bitset.size() ? 0 : size_change;
			bitset.resize(new_size, new_values);
			REQUIRE(bitset.size() == new_size);

			for(size_t i = 0; i < bitset.size(); ++i)
			{
				CAPTURE(i);
				REQUIRE(bitset[i] == bitset_copy[i]);
			}
		}
	}
}

TEMPLATE_TEST_CASE("clear", "[dynamic_bitset]", uint16_t, uint32_t, uint64_t)
{
	CAPTURE(SEED);
	dynamic_bitset<TestType> bitset =
	  GENERATE(take(RANDOM_VECTORS_TO_TEST, randomDynamicBitset<TestType>(SEED)));
	CAPTURE(bitset);

	bitset.clear();
	REQUIRE(bitset.empty());
	REQUIRE(bitset.size() == 0);
}

TEMPLATE_TEST_CASE("push_back", "[dynamic_bitset]", uint16_t, uint32_t, uint64_t)
{
	CAPTURE(SEED);
	std::tuple<dynamic_bitset<TestType>, dynamic_bitset<TestType>> values =
	  GENERATE(multitake(RANDOM_VECTORS_TO_TEST,
	                     randomDynamicBitset<TestType>(SEED),
	                     randomDynamicBitset<TestType>(1, 2 * bits_number<TestType>, SEED)));
	dynamic_bitset<TestType>& bitset = std::get<0>(values);
	dynamic_bitset<TestType>& to_push = std::get<1>(values);

	const dynamic_bitset<TestType> bitset_copy = bitset;
	size_t size = bitset.size();

	// new bits added
	for(size_t i = 0; i < to_push.size(); ++i)
	{
		CAPTURE(i, size);
		bitset.push_back(to_push[i]);
		REQUIRE(bitset[size] == to_push[i]);
		++size;
		REQUIRE(bitset.size() == size);
	}

	// initial bits not changed
	for(size_t i = 0; i < bitset_copy.size(); ++i)
	{
		CAPTURE(i);
		REQUIRE(bitset[i] == bitset_copy[i]);
	}
}

TEMPLATE_TEST_CASE("pop_back", "[dynamic_bitset]", uint16_t, uint32_t, uint64_t)
{
	CAPTURE(SEED);
	std::tuple<dynamic_bitset<TestType>, size_t> values =
	  GENERATE(multitake(RANDOM_VECTORS_TO_TEST,
	                     randomDynamicBitset<TestType>(SEED),
	                     randomInt<TestType>(1, 2 * bits_number<TestType>, SEED + 1)));
	dynamic_bitset<TestType>& bitset = std::get<0>(values);
	size_t to_pop = std::min(bitset.size(), std::get<1>(values));

	const dynamic_bitset<TestType> bitset_copy = bitset;
	size_t size = bitset.size();

	// bits removed
	for(size_t i = 0; i < to_pop; ++i)
	{
		CAPTURE(i, size);
		bitset.pop_back();
		--size;
		REQUIRE(bitset.size() == size);
	}

	// initial bits not changed
	for(size_t i = 0; i < bitset.size(); ++i)
	{
		CAPTURE(i);
		REQUIRE(bitset[i] == bitset_copy[i]);
	}
}

TEMPLATE_TEST_CASE("append", "[dynamic_bitset]", uint16_t, uint32_t, uint64_t)
{
	CAPTURE(SEED);
	dynamic_bitset<TestType> bitset =
	  GENERATE(take(RANDOM_VECTORS_TO_TEST, randomDynamicBitset<TestType>(SEED)));
	CAPTURE(bitset);
	const dynamic_bitset<TestType> bitset_copy = bitset;

	SECTION("one value")
	{
		const TestType value =
		  GENERATE(take(RANDOM_VARIATIONS_TO_TEST, randomInt<TestType>(SEED + 1)));
		CAPTURE(value);

		bitset.append(value);
		REQUIRE(bitset.size() == (bitset_copy.size() + bits_number<TestType>));

		// new bits added
		for(size_t i = 0; i < bits_number<TestType>; ++i)
		{
			CAPTURE(i);
			REQUIRE(bitset[bitset_copy.size() + i] == bit_value(value, i));
		}

		// initial bits not changed
		for(size_t i = 0; i < bitset_copy.size(); ++i)
		{
			CAPTURE(i);
			REQUIRE(bitset[i] == bitset_copy[i]);
		}
	}

	SECTION("two values initializer_list")
	{
		const std::tuple<TestType, TestType> init_values = GENERATE(multitake(
		  RANDOM_VARIATIONS_TO_TEST, randomInt<TestType>(SEED + 1), randomInt<TestType>(SEED + 2)));
		std::initializer_list<TestType> init_values_list = {std::get<0>(init_values),
		                                                    std::get<1>(init_values)};
		CAPTURE(init_values_list);

		bitset.append(init_values_list);
		REQUIRE(bitset.size()
		        == (bitset_copy.size() + init_values_list.size() * bits_number<TestType>));

		// new bits added
		size_t value_i = 0;
		for(const TestType& value: init_values_list)
		{
			for(size_t bit_i = 0; bit_i < bits_number<TestType>; ++bit_i)
			{
				CAPTURE(value_i, bit_i);
				REQUIRE(bitset[bitset_copy.size() + value_i * bits_number<TestType> + bit_i]
				        == bit_value(value, bit_i));
			}
			++value_i;
		}

		// initial bits not changed
		for(size_t i = 0; i < bitset_copy.size(); ++i)
		{
			CAPTURE(i);
			REQUIRE(bitset[i] == bitset_copy[i]);
		}
	}
}
