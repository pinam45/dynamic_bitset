//
// Copyright (c) 2019 Maxime Pinard
//
// Distributed under the MIT license
// See accompanying file LICENSE or copy at
// https://opensource.org/licenses/MIT
//
#ifndef DYNAMIC_BITSET_CONFIG_HPP
#define DYNAMIC_BITSET_CONFIG_HPP

#include <random>

constexpr size_t RANDOM_VECTORS_TO_TEST = 100;
constexpr size_t RANDOM_VARIATIONS_TO_TEST = 10;
constexpr std::minstd_rand::result_type SEED = 314159;
//const std::minstd_rand::result_type SEED = std::random_device{}();

#endif //DYNAMIC_BITSET_CONFIG_HPP
