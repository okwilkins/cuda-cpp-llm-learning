#include <print>
#include <string>

class Ball {
  private:
    std::string m_colour{"black"};
    double m_radius{10.0};

    void print() const { std::println("Ball({}, {})", m_colour, m_radius); }

  public:
    Ball(double radius = 10.0) : m_radius{radius} { print(); }
    Ball(const std::string &colour, double radius = 10.0) : m_colour{colour}, m_radius{radius} {
        print();
    }
};

int main() {
    Ball def{};
    Ball blue{"blue"};
    Ball twenty{20.0};
    Ball blueTwenty{"blue", 20.0};

    return 0;
}
