#include "character.hpp"
#include "networking.hpp"
#include "queue.hpp"
#include "raylib.h"
#include "render.hpp"

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

    // WARN: Temp variable
    constexpr float accelFactor{9.81f};

    SetConfigFlags(FLAG_WINDOW_HIGHDPI | FLAG_WINDOW_RESIZABLE);

    InitWindow(screenWidth, screenHeight, "Raylib Test");
    SetTargetFPS(144);

    Character player1{
        0,
        Vector2{static_cast<float>(screenWidth) / 2 - static_cast<float>(screenWidth) / 4,
                static_cast<float>(screenWidth) / 2 - static_cast<float>(screenHeight) / 4},
        Vector2{0.0f, 0.0f}, Vector2{0.0f, 0.0f}};
    Character player2{
        1,
        Vector2{static_cast<float>(screenWidth) / 2 + static_cast<float>(screenWidth) / 4,
                static_cast<float>(screenWidth) / 2 + static_cast<float>(screenHeight) / 4},
        Vector2{0.0f, 0.0f}, Vector2{0.0f, 0.0f}};

    Color player1Colour{characterIdColour(player1.id)};
    Color player2Colour{characterIdColour(player2.id)};

    while (!WindowShouldClose()) {
        // if (IsMouseButtonDown(MOUSE_BUTTON_LEFT)) {
        //     GetMousePosition();
        // }

        BeginDrawing();

        ClearBackground(RAYWHITE);

        // WARN: Temp render
        DrawCircleV(player1.pos, 10, player1Colour);
        DrawCircleV(player2.pos, 10, player2Colour);

        EndDrawing();
    }

    CloseWindow();
    return 0;
}
