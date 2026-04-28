#include "networking.hpp"
#include "queue.hpp"

#include <thread>

constexpr std::string TEST_MSG{"TEST"};

void network_thread_loop(ThreadSafeQueue<NetworkMessage> &in_queue,
                         ThreadSafeQueue<NetworkMessage> &out_queue) {
    while (true) {
        // epoll events
    }
}

int main() {
    std::thread network_worker{};
    return 0;
}
