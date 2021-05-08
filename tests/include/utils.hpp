//
// Copyright (c) 2019 Maxime Pinard
//
// Distributed under the MIT license
// See accompanying file LICENSE or copy at
// https://opensource.org/licenses/MIT
//
#ifndef DYNAMIC_BITSET_UTILS_HPP
#define DYNAMIC_BITSET_UTILS_HPP

#include <sul/dynamic_bitset.hpp>

#include <type_traits>

template<typename T>
constexpr size_t bits_number = std::numeric_limits<T>::digits;

template<typename T>
static constexpr T zero_block = T(0);

template<typename T>
static constexpr T one_block = T(~zero_block<T>);

template<typename T>
constexpr bool bit_value(T value, size_t bit_pos) noexcept
{
	static_assert(std::is_unsigned<T>::value, "T is not an unsigned integral type");
	assert(bit_pos < bits_number<T>);
	return (value & (T(1) << bit_pos)) != T(0);
}

template<typename T>
constexpr bool check_unused_bits(const sul::dynamic_bitset<T>& bitset) noexcept
{
	const size_t extra_bits = bitset.size() % sul::dynamic_bitset<T>::bits_per_block;
	if(extra_bits > 0)
	{
		assert(bitset.data() != nullptr);
		assert(bitset.num_blocks() > 0);
		return (*(bitset.data() + bitset.num_blocks() - 1) & (one_block<T> << extra_bits))
		       == zero_block<T>;
	}
	return true;
}

template<typename T>
constexpr bool check_size(const sul::dynamic_bitset<T>& bitset) noexcept
{
	const size_t blocks_required =
	  bitset.size() / sul::dynamic_bitset<T>::bits_per_block
	  + static_cast<size_t>(bitset.size() % sul::dynamic_bitset<T>::bits_per_block > 0);
	return blocks_required == bitset.num_blocks();
}

template<typename T>
constexpr bool check_consistency(const sul::dynamic_bitset<T>& bitset) noexcept
{
	return check_unused_bits(bitset) && check_size(bitset);
}

#endif //DYNAMIC_BITSET_UTILS_HPP
