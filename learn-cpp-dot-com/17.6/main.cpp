#include <array>
#include <cstddef>
#include <iostream>
#include <optional>
#include <print>
#include <string>
#include <string_view>

namespace Animal {
enum class Type {
    chicken,
    dog,
    cat,
    elephant,
    duck,
    snake,
    max_animals,
};

struct Data {
    std::string_view name{};
    int legs{};
    std::string_view sound{};
};

using namespace std::string_view_literals;
constexpr std::array<std::string_view, static_cast<std::size_t>(Type::max_animals)> types{
    "chicken"sv, "dog"sv, "cat"sv, "elephant"sv, "duck"sv, "snake"sv};

constexpr std::array<Data, static_cast<std::size_t>(Type::max_animals)> animals{{
    {std::get<0>(types), 2, "cluck"},
    {std::get<1>(types), 4, "woof"},
    {std::get<2>(types), 4, "meow"},
    {std::get<3>(types), 4, "pawoo"},
    {std::get<4>(types), 2, "quack"},
    {std::get<5>(types), 0, "hiss"},
}};

constexpr std::optional<Type> stringToType(std::string_view str) {
    std::optional<Type> type{std::nullopt};

    for (std::size_t i{}; i < types.size(); ++i) {
        if (str == types.at(i)) {
            type = static_cast<Type>(i);
            break;
        }
    }

    return type;
}

constexpr Data typeToData(Type type) { return animals.at(static_cast<std::size_t>(type)); }

void printData(const Data &data) {
    std::println("A {} has {} legs and says {}.", data.name, data.legs, data.sound);
}
} // namespace Animal

int main() {
    std::cout << "Enter an animal: ";
    std::string input{};
    std::cin >> input;

    std::optional<Animal::Type> inputAnimal{Animal::stringToType(input)};
    std::optional<Animal::Data> inputData{std::nullopt};

    if (inputAnimal.has_value()) {
        inputData = Animal::typeToData(inputAnimal.value());
    }

    if (inputData.has_value()) {
        Animal::printData(inputData.value());
    } else {
        std::cout << "That animal couldn't be found.\n";
    }

    std::cout << "\nHere is the data for the rest of the animals:\n";

    for (const auto &animal : Animal::animals) {
        Animal::printData(animal);
    }
}
