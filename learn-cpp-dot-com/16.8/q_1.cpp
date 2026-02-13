#include <iostream>
#include <string>
#include <vector>

int main() {
    std::vector<std::string_view> names{"Alex",  "Betty", "Caroline", "Dave",
                                        "Emily", "Fred",  "Greg",     "Holly"};

    std::cout << "Enter a name: ";
    std::string input{};
    std::cin >> input;

    for (const auto name : names) {
        if (name == input) {
            std::cout << input << " was found.\n";
            return 0;
        }
    }

    std::cout << input << " was not found.\n";
}
