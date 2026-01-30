#include <print>
#include <string>
#include <string_view>

struct Monster {
    enum class Type {
        orgre,
        dragon,
        orc,
        giant_spider,
        slime,
    };

    std::string name{};
    int health{};
    Type type{};
};

constexpr std::string_view monsterTypeToString(Monster::Type type) {
    using namespace std::string_view_literals;
    using enum Monster::Type;

    switch (type) {
    case orgre:
        return "Ogre"sv;
    case dragon:
        return "Dragon"sv;
    case orc:
        return "Orc"sv;
    case giant_spider:
        return "Giant Spider"sv;
    case slime:
        return "Slime"sv;
    default:
        return "???"sv;
    }
}

void printMonster(const Monster &monster) {
    const std::string_view monsterType{monsterTypeToString(monster.type)};

    std::print("This {0} is named {1} and has {2} health.\n", monsterType, monster.name,
               monster.health);
}

int main() {
    Monster monster1{
        .name = std::string("Torg"),
        .health = 145,
        .type = Monster::Type::orgre,

    };

    Monster monster2{
        .name = std::string("Blurp"),
        .health = 23,
        .type = Monster::Type::slime,
    };

    printMonster(monster1);
    printMonster(monster2);

    return 0;
}
