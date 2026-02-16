#include <cstddef>
#include <print>
#include <vector>

void printStack(const std::vector<int> &stack) {
    std::print("(Stack: ");

    if (stack.empty()) {
        std::print("empty");
    }

    for (std::size_t i{0}; i < stack.size(); ++i) {
        if (i == (stack.size() - 1)) {
            std::print("{}", stack.at(i));
            continue;
        }

        std::print("{} ", stack.at(i));
    }

    std::println(")");
}

int main() {
    std::vector<int> vec{};
    vec.reserve(3);

    std::print("Push 1\t");
    vec.push_back(1);
    printStack(vec);

    std::print("Push 2\t");
    vec.push_back(2);
    printStack(vec);

    std::print("Push 3\t");
    vec.push_back(3);
    printStack(vec);

    std::print("Pop\t");
    vec.pop_back();
    printStack(vec);

    std::print("Push 4\t");
    vec.push_back(4);
    printStack(vec);

    std::print("Pop\t");
    vec.pop_back();
    printStack(vec);

    std::print("Pop\t");
    vec.pop_back();
    printStack(vec);

    std::print("Pop\t");
    vec.pop_back();
    printStack(vec);
}
