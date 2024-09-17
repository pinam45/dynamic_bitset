//
// Copyright (c) 2019 Maxime Pinard
//
// Distributed under the MIT license
// See accompanying file LICENSE or copy at
// https://opensource.org/licenses/MIT
//
#ifndef DYNAMIC_BITSET_RANDOMBITSETSTRINGGENERATOR_HPP
#define DYNAMIC_BITSET_RANDOMBITSETSTRINGGENERATOR_HPP

#include <catch2/generators/catch_generators.hpp>
#include <catch2/catch_get_random_seed.hpp>

#include <random>
#include <string>

Catch::Generators::GeneratorWrapper<std::string> randomBitsetString(
  uint32_t seed = Catch::getSeed());

Catch::Generators::GeneratorWrapper<std::string> randomBitsetString(
  std::string::size_type min_size,
  std::string::size_type max_size,
  uint32_t seed = Catch::getSeed());

class RandomBitsetStringGenerator : public Catch::Generators::IGenerator<std::string>
{
public:
	typedef std::string::size_type size_type;
	static constexpr size_type default_min_size = 1;
	static constexpr size_type default_max_size = 8 * 32;

	explicit RandomBitsetStringGenerator(uint32_t seed = Catch::getSeed());
	RandomBitsetStringGenerator(size_type min_size,
	                            size_type max_size,
	                            uint32_t seed = Catch::getSeed());

	const std::string& get() const override;
	bool next() override;

private:
	std::minstd_rand m_rand;
	std::uniform_int_distribution<size_type> m_size_dist;
	std::bernoulli_distribution m_bit_dist;
	std::string m_current_bitset;
};

RandomBitsetStringGenerator::RandomBitsetStringGenerator(uint32_t seed)
  : m_rand(seed), m_size_dist(default_min_size, default_max_size), m_bit_dist(), m_current_bitset()
{
	next();
}

RandomBitsetStringGenerator::RandomBitsetStringGenerator(
  RandomBitsetStringGenerator::size_type min_size,
  RandomBitsetStringGenerator::size_type max_size,
  uint32_t seed)
  : m_rand(seed), m_size_dist(min_size, max_size), m_bit_dist(), m_current_bitset()
{
	next();
}

const std::string& RandomBitsetStringGenerator::get() const
{
	return m_current_bitset;
}

bool RandomBitsetStringGenerator::next()
{
	const size_type bitset_size = m_size_dist(m_rand);
	m_current_bitset.clear();
	m_current_bitset.reserve(bitset_size);
	for(size_t i = 0; i < bitset_size; ++i)
	{
		m_current_bitset.push_back(m_bit_dist(m_rand) ? '1' : '0');
	}
	return true;
}

Catch::Generators::GeneratorWrapper<std::string> randomBitsetString(uint32_t seed)
{
	return Catch::Generators::GeneratorWrapper<std::string>(
	  Catch::Detail::make_unique<RandomBitsetStringGenerator>(seed));
}

Catch::Generators::GeneratorWrapper<std::string> randomBitsetString(
  typename std::string::size_type min_size,
  typename std::string::size_type max_size,
  uint32_t seed)
{
	return Catch::Generators::GeneratorWrapper<std::string>(
	  Catch::Detail::make_unique<RandomBitsetStringGenerator>(min_size, max_size, seed));
}

#endif //DYNAMIC_BITSET_RANDOMBITSETSTRINGGENERATOR_HPP
