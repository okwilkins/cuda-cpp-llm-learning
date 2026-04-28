#pragma once

#include <mutex>
#include <optional>
#include <queue>

template <typename T> class ThreadSafeQueue {
  private:
    std::queue<T> queue{};
    std::mutex mutex{};

  public:
    void push(T &item) {
        const std::lock_guard<std::mutex> lock(mutex);
        queue.push(item);
    }

    std::optional<T> pop() {
        const std::lock_guard<std::mutex> lock(mutex);

        if (queue.empty()) {
            return std::nullopt;
        }

        const T item{queue.front()};
        queue.pop();

        return item;
    }
};
