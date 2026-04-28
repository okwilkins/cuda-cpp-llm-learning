#include "networking.hpp"
#include "queue.hpp"
#include "raylib.h"

#include <thread>

void game_loop(ThreadSafeQueue<NetworkMessage> &in_queue,
               ThreadSafeQueue<NetworkMessage> &out_queue) {

    while (true) {
        auto tick_start{std::chrono::steady_clock::now()};
        NetworkMessage in_msg{};

        std::optional<NetworkMessage> out_msg{in_queue.pop()};
        if (out_msg != std::nullopt) {
            // Do stuff
        }

        auto elapsed{std::chrono::steady_clock::now() - tick_start};
        if (elapsed < TICK_RATE) {
            std::this_thread::sleep_for(TICK_RATE - elapsed);
        }
    }
}

int main() {
    constexpr int screenWidth = 800;
    constexpr int screenHeight = 450;

    SetConfigFlags(FLAG_WINDOW_HIGHDPI | FLAG_WINDOW_RESIZABLE);

    InitWindow(screenWidth, screenHeight, "Raylib Test");
    SetTargetFPS(144);

    Vector2 ballPosition = {-100.0f, -100.0f};

    while (!WindowShouldClose()) {
        ballPosition = GetMousePosition();

        if (IsMouseButtonDown(MOUSE_BUTTON_LEFT)) {
            DrawText("Nix build systems are cooler than your build systems B)",
                     static_cast<int>(ballPosition.x), static_cast<int>(ballPosition.y), 20,
                     DARKGRAY);
        }

        BeginDrawing();

        ClearBackground(RAYWHITE);

        EndDrawing();
    }

    CloseWindow();
    return 0;
}
