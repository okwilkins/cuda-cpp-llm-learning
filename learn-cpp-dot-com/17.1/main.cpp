#include <array>
#include <print>

int main() {
    // Q2
    std::array<double, 365> dailyHighTemps{};

    // Q3
    constexpr std::array word{'h', 'e', 'l', 'l', 'o'};
    std::println("Word at index 1: {}", word[1]);
}
