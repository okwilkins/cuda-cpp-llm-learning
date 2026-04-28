#pragma once

#include <chrono>
#include <string>

struct NetworkMessage {
    int client_id{};
    std::string payload{};
};

constexpr int TICKS_PER_SEC{20};
constexpr std::chrono::milliseconds TICK_RATE{1000 / TICKS_PER_SEC};
