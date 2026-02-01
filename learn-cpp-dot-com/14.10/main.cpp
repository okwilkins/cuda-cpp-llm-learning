#include <print>
#include <string>

class Ball {
  private:
    std::string m_colour{};
    double m_radius{};

  public:
    Ball(std::string_view colour, double radius) : m_colour{colour}, m_radius{radius} {}
    constexpr std::string colour() const { return m_colour; }
    constexpr double radius() const { return m_radius; }
};

void print(const Ball &b) { std::println("Ball({}, {})", b.colour(), b.radius()); }

int main() {
    Ball blue{"blue", 10.0};
    print(blue);

    Ball red{"red", 12.0};
    print(red);

    return 0;
}
