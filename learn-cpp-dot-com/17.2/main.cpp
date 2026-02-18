#include <array>
#include <print>

int main() {
    std::array word{'h', 'e', 'l', 'l', 'o'};

    std::println("The length is {}", word.size());
    std::println("{}{}{}", word[1], word.at(1), std::get<1>(word));

    return 0;
}
