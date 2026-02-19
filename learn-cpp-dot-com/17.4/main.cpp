#include <array>
#include <print>
#include <string_view>

struct Item {
    std::string_view name{};
    int gold{};
};

int main() {
    std::array<Item, 4> items{{
        {"sword", 5},
        {"dagger", 3},
        {"club", 2},
        {"spear", 7},
    }};

    for (auto &item : items) {
        std::println("A {} costs {} gold.", item.name, item.gold);
    }
}
