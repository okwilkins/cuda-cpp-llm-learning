#include <iostream>

void printBackwards(const char str[], const char *end) {
    while (end != str - 1) {
        std::cout << *end;
        --end;
    }
}

int main() {
    constexpr char word[]{"Hello, world!"};
    const char *begin{word};
    const char *end{begin + std::size(word)};
    printBackwards(word, end);

    std::cout << '\n';

    return 0;
}
