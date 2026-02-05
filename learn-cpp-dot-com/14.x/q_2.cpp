#include <iostream>

class Fraction {
  private:
    int m_numerator{0};
    int m_denominator{1};

  public:
    explicit Fraction(int numerator = 0, int denominator = 1)
        : m_numerator{numerator}, m_denominator{denominator} {}

    void getFraction() {
        std::cout << "Enter a value for numerator: ";
        std::cin >> m_numerator; // this is a member function, so we can access members directly
        std::cout << "Enter a value for denominator: ";
        std::cin >> m_denominator;
        std::cout << '\n';
    }

    constexpr Fraction multiply(const Fraction &f) const {
        return Fraction{m_numerator * f.m_numerator, m_denominator * f.m_denominator};
    }

    void printFraction() const { std::cout << m_numerator << '/' << m_denominator << '\n'; }
};

int main() {
    Fraction f1{};
    f1.getFraction();

    Fraction f2{};
    f2.getFraction();

    std::cout << "Your fractions multiplied together: ";

    f1.multiply(f2).printFraction();

    return 0;
}
