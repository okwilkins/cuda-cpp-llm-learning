#include <cstddef>
#include <optional>
#include <print>
#include <utility>
#include <vector>

template <typename T> std::optional<std::pair<T, std::size_t>> maxPair(const std::vector<T> &arr) {
    if (arr.size() == 0) {
        return std::nullopt;
    };

    T max{arr[0]};
    std::size_t maxIdx{0};

    for (std::size_t i{}; i < arr.size(); ++i) {
        if (arr[i] > max) {
            max = arr[i];
            maxIdx = i;
        }
    }

    return std::pair{max, maxIdx};
}

template <typename T> std::optional<std::pair<T, std::size_t>> minPair(const std::vector<T> &arr) {
    if (arr.size() == 0) {
        return std::nullopt;
    };

    T min{arr[0]};
    std::size_t minIdx{0};

    for (std::size_t i{}; i < arr.size(); ++i) {
        if (arr[i] < min) {
            min = arr[i];
            minIdx = i;
        }
    }

    return std::pair{min, minIdx};
}

template <typename T> void printArray(const std::vector<T> &arr) {
    std::optional<std::pair<T, std::size_t>> min{minPair(arr)};
    std::optional<std::pair<T, std::size_t>> max{maxPair(arr)};

    std::print("With array ( ");

    for (std::size_t i{}; i < arr.size(); ++i) {
        if (i == arr.size() - 1) {
            std::print("{} ", arr[i]);
        } else {
            std::print("{}, ", arr[i]);
        }
    }

    std::println("):");

    if (min.has_value()) {
        std::println("The min element has index {} and value {}", min.value().second,
                     min.value().first);
    }

    if (max != std::nullopt) {
        std::println("The max element has index {} and value {}", max.value().second,
                     max.value().first);
    }
}

int main() {
    std::vector v1{3, 8, 2, 5, 7, 8, 3};
    std::vector v2{5.5, 2.7, 3.3, 7.6, 1.2, 8.8, 6.6};

    printArray(v1);
    printArray(v2);
}
