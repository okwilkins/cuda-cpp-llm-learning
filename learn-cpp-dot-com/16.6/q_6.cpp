#include <cstddef>
#include <print>

int main() {
    for (std::size_t i{1}; i <= 150; ++i) {
        bool divisible{false};

        if (i % 3 == 0) {
            std::print("fizz");
            divisible = true;
        }

        if (i % 5 == 0) {
            std::print("buzz");
            divisible = true;
        }

        if (i % 7 == 0) {
            std::print("pop");
            divisible = true;
        }

        if (i % 11 == 0) {
            std::print("bang");
            divisible = true;
        }

        if (i % 13 == 0) {
            std::print("jazz");
            divisible = true;
        }

        if (i % 17 == 0) {
            std::print("pow");
            divisible = true;
        }

        if (i % 19 == 0) {
            std::print("boom");
            divisible = true;
        }

        if (!divisible) {
            std::print("{}", i);
        }

        std::println();
    }
}
