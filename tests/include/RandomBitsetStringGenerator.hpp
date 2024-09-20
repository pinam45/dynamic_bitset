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
#include <catch2/generators/catch_generators_random.hpp>
#include <catch2/internal/catch_uniform_integer_distribution.hpp>

#include <string>

Catch::Generators::GeneratorWrapper<std::string>
randomBitsetString(uint32_t seed = Catch::Generators::Detail::getSeed());

Catch::Generators::GeneratorWrapper<std::string>
randomBitsetString(std::string::size_type min_size,
                   std::string::size_type max_size,
                   uint32_t seed = Catch::Generators::Detail::getSeed());

class RandomBitsetStringGenerator : public Catch::Generators::IGenerator<std::string>
{
public:
    typedef std::string::size_type size_type;
    static constexpr size_type default_min_size = 1;
    static constexpr size_type default_max_size = 256;

    explicit RandomBitsetStringGenerator(uint32_t seed = Catch::Generators::Detail::getSeed());
    RandomBitsetStringGenerator(size_type min_size,
                                size_type max_size,
                                uint32_t seed = Catch::Generators::Detail::getSeed());

    const std::string& get() const override;
    bool next() override;

private:
    Catch::SimplePcg32 m_rand;
    Catch::uniform_integer_distribution<size_type> m_size_dist;
    Catch::uniform_integer_distribution<char> m_bit_dist;
    std::string m_current_bitset;
};

inline RandomBitsetStringGenerator::RandomBitsetStringGenerator(uint32_t seed)
    : m_rand(seed)
    , m_size_dist(default_min_size, default_max_size)
    , m_bit_dist('0', '1')
    , m_current_bitset()
{
    next();
}

inline RandomBitsetStringGenerator::RandomBitsetStringGenerator(size_type min_size, size_type max_size, uint32_t seed)
    : m_rand(seed)
    , m_size_dist(min_size, max_size)
    , m_bit_dist('0', '1')
    , m_current_bitset()
{
    next();
}

inline const std::string& RandomBitsetStringGenerator::get() const
{
    return m_current_bitset;
}

inline bool RandomBitsetStringGenerator::next()
{
    const size_type bitset_size = m_size_dist(m_rand);
    m_current_bitset.clear();
    m_current_bitset.reserve(bitset_size);
    for(size_t i = 0; i < bitset_size; ++i)
    {
        m_current_bitset.push_back(m_bit_dist(m_rand));
    }
    return true;
}

inline Catch::Generators::GeneratorWrapper<std::string> randomBitsetString(uint32_t seed)
{
    return Catch::Generators::GeneratorWrapper<std::string>(
      Catch::Detail::make_unique<RandomBitsetStringGenerator>(seed));
}

inline Catch::Generators::GeneratorWrapper<std::string>
randomBitsetString(std::string::size_type min_size, std::string::size_type max_size, uint32_t seed)
{
    return Catch::Generators::GeneratorWrapper<std::string>(
      Catch::Detail::make_unique<RandomBitsetStringGenerator>(min_size, max_size, seed));
}

#endif // DYNAMIC_BITSET_RANDOMBITSETSTRINGGENERATOR_HPP
