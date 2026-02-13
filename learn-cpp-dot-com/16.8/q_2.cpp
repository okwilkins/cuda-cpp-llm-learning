#include <iostream>
#include <string>
#include <vector>

template <typename T> bool isValueInArray(const std::vector<T> &names, const T &name) {
    for (const auto &iName : names) {
        if (iName == name) {
            return true;
        }
    }

    return false;
}

int main() {
    std::vector<std::string_view> names{"Alex",  "Betty", "Caroline", "Dave",
                                        "Emily", "Fred",  "Greg",     "Holly"};

    std::cout << "Enter a name: ";
    std::string input{};
    std::cin >> input;

    bool isFound{isValueInArray<std::string_view>(names, static_cast<std::string_view>(input))};

    if (isFound) {
        std::cout << input << " was found.\n";
    } else {
        std::cout << input << " was not found.\n";
    }

    return 0;
}
