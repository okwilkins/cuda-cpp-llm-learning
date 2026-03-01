#include "random.hpp"
#include <array>
#include <cstddef>
#include <iostream>
#include <print>
#include <string>
#include <string_view>
#include <vector>

namespace Potion {
using namespace std::string_view_literals;

enum class Type {
    healing,
    mana,
    speed,
    invisibility,
    count,
};

constexpr std::array types{
    Type::healing,
    Type::mana,
    Type::speed,
    Type::invisibility,
};
static_assert(types.size() == static_cast<int>(Type::count));

constexpr std::array<int, static_cast<int>(Type::count)> costs{20, 30, 12, 50};
static_assert(costs.size() == static_cast<int>(Type::count));

constexpr std::array names{"healing"sv, "mana"sv, "speed"sv, "invisibility"sv};
static_assert(names.size() == static_cast<int>(Type::count));
} // namespace Potion

class Player {
  private:
    std::string_view m_name{};
    int m_gold{};
    std::vector<Potion::Type> m_potions{};

  public:
    Player(std::string_view name, int gold, const std::vector<Potion::Type> &potions)
        : m_name{name}, m_gold{gold}, m_potions{potions} {}

    int gold() { return m_gold; }
    std::string_view name() { return m_name; }
};

void shop() {
    std::println("Here is our selection for today:");

    for (std::size_t i{0}; i < static_cast<std::size_t>(Potion::Type::count); ++i) {
        std::println("{}) {} costs {}", i, Potion::names[i], Potion::costs[i]);
    }
}

int main() {
    std::println("Welcome to Roscoe's potion emporium!");
    std::print("Enter your name: ");

    std::string name{};
    std::cin >> name;

    Player player{name, Random::get(0, 100), std::vector<Potion::Type>{}};
    std::println("Hello, {}, you have {} gold.", player.name(), player.gold());
    std::println();

    shop();
    std::println();

    std::println("Thanks for shopping at Roscoe's potion emporium!");

    return 0;
}
