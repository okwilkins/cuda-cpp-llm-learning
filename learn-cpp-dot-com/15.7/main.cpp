#include <chrono>
#include <iostream>
#include <random>

class Random {
  public:
    static inline std::mt19937 generate() {
        std::random_device rd{};

        // Create seed_seq with high-res clock and 7 random numbers from std::random_device
        std::seed_seq ss{
            static_cast<std::seed_seq::result_type>(
                std::chrono::steady_clock::now().time_since_epoch().count()),
            rd(),
            rd(),
            rd(),
            rd(),
            rd(),
            rd(),
            rd(),
        };

        return std::mt19937{ss};
    }

    // generates a seeded std::mt19937 and copies it into our global object
    static inline std::mt19937 mt{generate()};

    // Generate a random int between [min, max] (inclusive)
    static inline int get(int min, int max) { return std::uniform_int_distribution{min, max}(mt); }
};

int main() {
    // Print a bunch of random numbers
    for (int count{1}; count <= 10; ++count)
        std::cout << Random::get(1, 6) << '\t';

    std::cout << '\n';

    return 0;
}
