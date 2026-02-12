#include <cstddef>
#include <iostream>
#include <print>
#include <vector>

namespace {
void ignoreLine() { std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); }

bool clearFailedExtraction() {
    if (!std::cin) {
        if (std::cin.eof()) {
            std::exit(0);
        }

        std::cin.clear();
        ignoreLine();

        return true;
    }

    return false;
}

template <typename T> void printArray(const std::vector<T> &arr) {
    for (std::size_t i{0}; i < arr.size(); ++i) {
        std::print("{} ", arr[i]);
    }

    std::println();
}

int getNum() {
    int num{};

    while (num < 1 || num > 9) {
        std::print("Enter a number between 1 and 9: ");
        std::cin >> num;

        if (!clearFailedExtraction()) {
            ignoreLine();
        }
    }

    return num;
}

template <typename T> void printElement(const std::vector<T> &arr, int num) {
    for (std::size_t i{}; i < arr.size(); ++i) {
        if (arr[i] == num) {
            std::println("The number {} has index {}", num, i);
            return;
        }
    }

    std::println("The number {} was not found", num);
}
} // namespace

int main() {
    std::vector arr{4, 6, 7, 3, 8, 2, 1, 9};
    printArray(arr);

    std::vector arr2{4.4, 6.6, 7.7, 3.3, 8.8, 2.2, 1.1, 9.9};
    printArray(arr2);

    int num{getNum()};
    printElement(arr, num);

    return 0;
}
