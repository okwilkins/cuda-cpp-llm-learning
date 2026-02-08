#include "Random.hpp"
#include <print>
#include <string>
#include <string_view>

namespace {
class Monster {
  public:
    enum Type {
        dragon,
        goblin,
        ogre,
        skeleton,
        troll,
        vampire,
        zombie,
        maxMonsterTypes,
    };

  private:
    Type m_type{};
    std::string m_name{};
    std::string m_roar{};
    int m_hitPoints{};

    constexpr std::string_view getTypeString() const {
        switch (m_type) {
        case dragon:
            return "dragon";
        case goblin:
            return "goblin";
        case ogre:
            return "ogre";
        case skeleton:
            return "skeleton";
        case troll:
            return "troll";
        case vampire:
            return "vampire";
        case zombie:
            return "zombie";
        default:
            return "???";
        }
    }

  public:
    Monster(Type monsterType, std::string name, std::string roar, int hitPoints)
        : m_type{monsterType}, m_name{name}, m_roar{roar}, m_hitPoints{hitPoints} {}

    void print() const {
        const std::string_view type{getTypeString()};

        if (m_hitPoints <= 0) {
            std::println("{} the {} is dead.", m_name, type);
            return;
        }

        std::println("{} the {} has {} hit pointer and says {}.", m_name, type, m_hitPoints,
                     m_roar);
    }
};
} // namespace

namespace MonsterGenerator {
constexpr std::string_view getName() {
    switch (Random::get(0, Monster::maxMonsterTypes - 1)) {
    case 0:
        return "Blarg";
    case 1:
        return "Bazza";
    case 2:
        return "Gazza";
    case 3:
        return "Jezza";
    case 4:
        return "Mortimer";
    case 5:
        return "Drathnor, Destroyer of Worlds";
    default:
        return "Missinno";
    }
}

constexpr std::string_view getRoar() {
    switch (Random::get(0, Monster::maxMonsterTypes - 1)) {
    case 0:
        return "*ROAR*";
    case 1:
        return "*ALRIGHT M8?!*";
    case 2:
        return "*OI!*";
    case 3:
        return "*NOICE*";
    case 4:
        return "*Squeek*";
    case 5:
        return "*TIME IS BUT A MEANINGLESS CONSTRUCT*";
    default:
        return "**";
    }
}

constexpr Monster generate() {
    return Monster{Monster::skeleton, static_cast<std::string>(getName()),
                   static_cast<std::string>(getRoar()), 4};
}
} // namespace MonsterGenerator

int main() {
    Monster skeleton{Monster::skeleton, "Bones", "*rattle*", 4};
    skeleton.print();

    Monster vampire{Monster::vampire, "Nibblez", "*hiss*", 0};
    vampire.print();

    Monster m{MonsterGenerator::generate()};
    m.print();

    return 0;
}
