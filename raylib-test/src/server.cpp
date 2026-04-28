#include <asio.hpp>
#include <memory>
#include <print>
#include <system_error>

class UDPServer {
  private:
    asio::ip::udp::socket m_socket;
    asio::ip::udp::endpoint m_remote_endpoint;
    std::array<char, 1> m_recv_buffer{};

  public:
    UDPServer(asio::io_context &io)
        : m_socket{io, asio::ip::udp::endpoint{asio::ip::udp::v4(), 1337}} {
        start_recieve();
    }

  private:
    void start_recieve() {
        m_socket.async_receive_from(
            asio::buffer(m_recv_buffer), m_remote_endpoint,
            [this](const std::error_code &err, std::size_t bytes_transferred) {
                handle_receive(err, bytes_transferred);
            });
        ;
    }

    void handle_receive(const std::error_code &err, std::size_t) {
        std::println("Received request...");

        if (err) {
            return;
        }

        auto message{std::make_shared<std::string>("Test")};

        m_socket.async_send_to(
            asio::buffer(*message), m_remote_endpoint,
            [this, message](const std::error_code &err, std::size_t bytes_transferred) {
                handle_send(message, err, bytes_transferred);
            });
    }

    void handle_send(std::shared_ptr<std::string>, const std::error_code &, std::size_t) {
        std::println("Sending message...");
        start_recieve();
        std::println("Message sent!");
    }
};

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
