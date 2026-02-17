#include <cassert>
#include <iterator>
#include <print>
#include <string_view>
#include <vector>

namespace Item {
enum Type {
    health_potion,
    torch,
    arrow,
};
}

namespace {
struct Player {
  private:
    std::vector<Item::Type> m_items;

  public:
    explicit Player(const std::vector<Item::Type> &items) : m_items{items} {
        assert(std::ssize(m_items) == 16);
    }

    const std::vector<Item::Type> &items() const { return m_items; }
};

void printItemCount(const std::vector<Item::Type> &items, Item::Type item) {
    int count{};

    for (auto i_item : items) {
        if (i_item == item) {
            ++count;
        }
    }

    if (count == 1) {
        switch (item) {
        case Item::health_potion:
            std::println("You have {} health potion", count);
            break;
        case Item::torch:
            std::println("You have {} torch", count);
            break;
        case Item::arrow:
            std::println("You have {} arrow", count);
            break;
        default:
            std::println("You have {} of an unknown item!", count);
        }
    } else {
        switch (item) {
        case Item::health_potion:
            std::println("You have {} health potions", count);
            break;
        case Item::torch:
            std::println("You have {} torches", count);
            break;
        case Item::arrow:
            std::println("You have {} arrows", count);
            break;
        default:
            std::println("You have {} of an unknown item!", count);
        }
    }
}

void printPlayerItems(const Player &player) {
    printItemCount(player.items(), Item::health_potion);
    printItemCount(player.items(), Item::torch);
    printItemCount(player.items(), Item::arrow);
    std::println("You have {} total items", player.items().size());
}

} // namespace

int main() {
    const std::vector<Item::Type> startingItems{
        Item::health_potion, Item::torch, Item::torch, Item::torch, Item::torch, Item::torch,
        Item::arrow,         Item::arrow, Item::arrow, Item::arrow, Item::arrow, Item::arrow,
        Item::arrow,         Item::arrow, Item::arrow, Item::arrow,
    };

    Player mainPlayer{startingItems};
    printPlayerItems(mainPlayer);
}
