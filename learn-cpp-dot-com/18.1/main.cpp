#include <array>
#include <cstddef>
#include <print>
#include <utility>

template <typename T, std::size_t N> void printArray(const std::array<T, N> &array) {
    std::print("{{ ");

    for (std::size_t i{}; i < array.size(); ++i) {
        std::print("{} ", array[i]);
    }

    std::print("}}");
    std::println();
}

template <typename T, std::size_t N> std::array<T, N> selectionSort(std::array<T, N> array) {
    for (std::size_t i{}; i < array.size(); ++i) {
        T smallest{array[i]};
        std::size_t smallestIdx{i};

        for (std::size_t j{i + 1}; j < array.size(); ++j) {
            if (array[j] < smallest) {
                smallest = array[j];
                smallestIdx = j;
            }
        }

        std::swap(array[i], array[smallestIdx]);
    }

    return array;
}

template <typename T, std::size_t N>
std::array<T, N> backwardsSelectionSort(std::array<T, N> array) {
    for (std::size_t i{}; i < array.size(); ++i) {
        T biggest{array[i]};
        std::size_t biggestIdx{i};

        for (std::size_t j{i + 1}; j < array.size(); ++j) {
            if (array[j] > biggest) {
                biggest = array[j];
                biggestIdx = j;
            }
        }

        std::swap(array[i], array[biggestIdx]);
    }

    return array;
}

template <typename T, std::size_t N> std::array<T, N> bubbleSort(std::array<T, N> array) {
    for (std::size_t i{}; i < array.size(); ++i) {
        for (std::size_t j{}; j + i + 1 < array.size(); ++j) {
            if (array[j] > array[j + 1]) {
                std::swap(array[j], array[j + 1]);
            }
        }
    }

    return array;
}

int main() {
    std::array array{30, 50, 20, 10, 40};

    printArray(array);
    printArray(selectionSort(array));
    printArray(backwardsSelectionSort(array));
    printArray(bubbleSort(array));
}
