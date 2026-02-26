#include <iostream>

void print(const char str[]) {
    while (*str != '\0') {
        std::cout << *str;
        ++str;
    }
}

int main() {
    const char word[]{"Hello, world!"};
    print(word);

    std::cout << '\n';

    return 0;
}
