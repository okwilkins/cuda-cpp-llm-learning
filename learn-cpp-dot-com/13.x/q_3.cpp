#include <print>

template <typename T> struct Triad {
    T x{};
    T y{};
    T z{};
};

// Not needed as std::print is used and this is only needed in C++17
template <typename T> Triad(T, T, T) -> Triad<T>;

template <typename T> void print(const Triad<T> &t) {
    std::print("[{0}, {1}, {2}]", t.x, t.y, t.z);
}

int main() {
    Triad t1{1, 2, 3};
    print(t1);

    Triad t2{1.2, 3.4, 5.6};
    print(t2);

    return 0;
}
