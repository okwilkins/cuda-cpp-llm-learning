#include <string_view>
#include <vector>

int main() {
    // Part a
    std::vector evenArr{2, 4, 6, 8, 10, 12};

    // Part b
    const std::vector constArr{1.2, 3.4, 5.6, 7.8};

    // Part c
    using namespace std::literals;
    const std::vector namesArr{"Alex"sv, "Brad"sv, "Charles"sv, "Dave"sv};

    // Part d
    std::vector singleArr{12};

    // Part e
    std::vector<int> intArry(12);
}
