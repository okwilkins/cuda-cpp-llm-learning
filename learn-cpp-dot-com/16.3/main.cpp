#include <print>
#include <vector>

int main() {
    std::vector name{'h', 'e', 'l', 'l', 'o'};
    std::println("The array has {} elements.", name.size());
    std::println("{}{}", name[1], name.at(1));

    return 0;
}
