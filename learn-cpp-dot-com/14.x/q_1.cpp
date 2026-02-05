#include <cmath>
#include <print>
class Point2d {
  private:
    double m_first{};
    double m_second{};

  public:
    Point2d() = default;
    Point2d(double first, double second) : m_first{first}, m_second{second} {};

    void print() const { std::println("Point2d({}, {})", m_first, m_second); }

    constexpr double distanceTo(const Point2d &other) {
        return std::sqrt((m_first - other.m_first) * (m_first - other.m_first) +
                         (m_second - other.m_second) * (m_second - other.m_second));
    }
};

int main() {
    Point2d first{};
    Point2d second{3.0, 4.0};

    // Point2d third{ 4.0 }; // should error if uncommented

    first.print();
    second.print();

    std::println("Distance between two points: {}", first.distanceTo(second));

    return 0;
}
