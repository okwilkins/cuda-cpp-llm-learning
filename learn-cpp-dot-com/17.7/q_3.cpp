#include <iostream>

namespace {
constexpr int squares[]{0, 1, 4, 9, 16, 25, 36, 49, 64, 81};
}

int main() {
    int input{};
    bool numFound{};

    while (true) {
        numFound = false;

        std::cout << "Enter a single digit integer or -1 to quit: ";
        std::cin >> input;

        if (input == -1) {
            std::cout << "Bye\n";
            break;
        }

        for (auto n : squares) {
            if (input == n) {
                std::cout << input << " is a perfect square\n";
                numFound = true;
                break;
            }
        }

        if (!numFound) {
            std::cout << input << " is not a perfect square\n";
        }

        std::cout << '\n';
    }

    return 0;
}
