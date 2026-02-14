#include <array>

namespace Animals {
enum Names {
    chicken,
    dog,
    cat,
    elephant,
    duck,
    snake,
    name_count,
};
}

int main() {
    constexpr std::array<int, Animals::name_count> legs{2, 4, 4, 4, 2, 1};
    static_assert(legs.size() == Animals::name_count);
}
