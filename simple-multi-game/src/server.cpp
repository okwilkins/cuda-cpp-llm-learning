#include <asio.hpp>
#include <print>

#include "networking.hpp"

int main() {
    try {
        asio::io_context io_context{};
        UDPServer server{io_context};
        io_context.run();
    } catch (std::exception &err) {
        std::println("Error: {}", err.what());
    }

    return 0;
}
