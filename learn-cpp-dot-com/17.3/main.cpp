#include <array>
#include <cstddef>
#include <print>

template <typename T, std::size_t N> void printArray(const std::array<T, N> &arr) {
    std::print("The array (");

    for (std::size_t i{}; i < arr.size(); ++i) {
        if (i == arr.size() - 1) {
            std::print("{}", arr[i]);
        } else {
            std::print("{}, ", arr[i]);
        }
    }

    std::print(") has length {}\n", arr.size());
}

int main() {
    constexpr std::array arr1{1, 4, 9, 16};
    printArray(arr1);

    constexpr std::array arr2{'h', 'e', 'l', 'l', 'o'};
    printArray(arr2);

    return 0;
}
