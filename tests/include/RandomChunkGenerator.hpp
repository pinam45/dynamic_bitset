//
// Copyright (c) 2019 Maxime Pinard
//
// Distributed under the MIT license
// See accompanying file LICENSE or copy at
// https://opensource.org/licenses/MIT
//
#ifndef DYNAMIC_BITSET_RANDOMCHUNKGENERATOR_HPP
#define DYNAMIC_BITSET_RANDOMCHUNKGENERATOR_HPP

#include <catch2/generators/catch_generators.hpp>
#include <catch2/generators/catch_generators_random.hpp>

#include <algorithm>
#include <cassert>

template<typename T>
constexpr Catch::Generators::GeneratorWrapper<std::vector<T>> randomChunk(
  typename std::vector<T>::size_type min_chunk_size,
  typename std::vector<T>::size_type max_chunk_size,
  Catch::Generators::GeneratorWrapper<T>&& generator,
  uint32_t seed = Catch::Generators::Detail::getSeed());

template<typename T>
class RandomChunkGenerator final : public Catch::Generators::IGenerator<std::vector<T>>
{
public:
	using size_type = typename std::vector<T>::size_type;

	constexpr RandomChunkGenerator(size_type min_chunk_size,
	                               size_type max_chunk_size,
	                               Catch::Generators::GeneratorWrapper<T>&& generator,
	                               uint32_t seed = Catch::Generators::Detail::getSeed());

	constexpr std::vector<T> const& get() const override;

	constexpr bool next() override;

private:
	Catch::SimplePcg32 m_rand;
	Catch::uniform_integer_distribution<size_type> m_size_dist;
	std::vector<T> m_chunk;
	Catch::Generators::GeneratorWrapper<T> m_generator;
};

template<typename T>
constexpr RandomChunkGenerator<T>::RandomChunkGenerator(
  size_type min_chunk_size,
  size_type max_chunk_size,
  Catch::Generators::GeneratorWrapper<T>&& generator,
  uint32_t seed)
  : m_rand(seed)
  , m_size_dist(min_chunk_size, max_chunk_size)
  , m_chunk()
  , m_generator(std::move(generator))
{
	const size_type size = m_size_dist(m_rand);
	m_chunk.reserve(size);
	if(size == 0)
	{
		return;
	}

	m_chunk.push_back(m_generator.get());
	for(size_type i = 1; i < min_chunk_size; ++i)
	{
		assert(m_generator.next() && "Not enough values to initialize the first chunk");
		m_chunk.push_back(m_generator.get());
	}
	for(size_type i = min_chunk_size; i < size; ++i)
	{
		if(m_generator.next())
		{
			m_chunk.push_back(m_generator.get());
		}
	}
}

template<typename T>
constexpr const std::vector<T>& RandomChunkGenerator<T>::get() const
{
	return m_chunk;
}

template<typename T>
constexpr bool RandomChunkGenerator<T>::next()
{
	const size_type size = m_size_dist(m_rand);
	m_chunk.clear();
	m_chunk.reserve(size);
	for(size_type i = 0; i < size; ++i)
	{
		if(!m_generator.next())
		{
			return false;
		}
		m_chunk.push_back(m_generator.get());
	}
	return true;
}

template<typename T>
constexpr Catch::Generators::GeneratorWrapper<std::vector<T>> randomChunk(
  typename std::vector<T>::size_type min_chunk_size,
  typename std::vector<T>::size_type max_chunk_size,
  Catch::Generators::GeneratorWrapper<T>&& generator,
  uint32_t seed)
{
	return Catch::Generators::GeneratorWrapper<std::vector<T>>(
	  Catch::Detail::make_unique<RandomChunkGenerator<T>>(
	    min_chunk_size, max_chunk_size, std::move(generator), seed));
}

#endif //DYNAMIC_BITSET_RANDOMCHUNKGENERATOR_HPP
