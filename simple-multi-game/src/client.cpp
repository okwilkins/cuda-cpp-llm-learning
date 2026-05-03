#include "character.hpp"
#include "networking.hpp"
#include "queue.hpp"
#include "raylib.h"
#include "raymath.h"
#include "render.hpp"

#include <algorithm>
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
    constexpr int SCREEN_WIDTH = 800;
    constexpr int SCREEN_HEIGHT = 450;

    // WARN: Temp variable
    constexpr float ACCEL_FACTOR{3000.0f};
    constexpr Vector2 MAX_VEL{1000.0f, 1000.0f};
    constexpr Vector2 MAX_ACCEL{500.0f, 500.0f};
    constexpr float DRAG_FACTOR{5000.0f};
    constexpr float ARROW_SIZE_FACTOR{100.0f};

    SetConfigFlags(FLAG_WINDOW_HIGHDPI | FLAG_WINDOW_RESIZABLE);

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Raylib Test");
    SetTargetFPS(-1);

    Character player1{
        0,
        Vector2{static_cast<float>(SCREEN_WIDTH) / 2 - static_cast<float>(SCREEN_WIDTH) / 4,
                static_cast<float>(SCREEN_WIDTH) / 2 - static_cast<float>(SCREEN_HEIGHT) / 4},
        Vector2{0.0f, 0.0f}, Vector2{0.0f, 0.0f}};
    Character player2{
        1,
        Vector2{static_cast<float>(SCREEN_WIDTH) / 2 + static_cast<float>(SCREEN_WIDTH) / 4,
                static_cast<float>(SCREEN_WIDTH) / 2 + static_cast<float>(SCREEN_HEIGHT) / 4},
        Vector2{0.0f, 0.0f}, Vector2{0.0f, 0.0f}};

    Color player1Colour{characterIdColour(player1.id)};
    Color player2Colour{characterIdColour(player2.id)};
    bool drawLine{false};

    while (!WindowShouldClose()) {
        const float deltaTime{GetFrameTime()};

        Vector2 newPos{};
        Vector2 newVel{};
        Vector2 accel{};

        if (IsMouseButtonDown(MOUSE_BUTTON_LEFT)) {
            player1.desiredPos = GetMousePosition();
            drawLine = true;
        }

        const Vector2 desiredDir{
            Vector2Normalize(Vector2Subtract(player1.desiredPos, player1.pos))};
        const Vector2 normMousePos{player1.pos + desiredDir * ARROW_SIZE_FACTOR};

        bool desiredPosClose{Vector2Distance(player1.pos, player1.desiredPos) <
                             DRAG_FACTOR * deltaTime * 5};

        if (desiredPosClose) {
            accel = {0.0f, 0.0f};
            player1.vel = {0.0f, 0.0f};
            drawLine = false;
        } else if (drawLine) {
            float accelMag = std::min(ACCEL_FACTOR, Vector2Length(MAX_ACCEL));
            accel = desiredDir * accelMag;
        } else {
            float speed = Vector2Length(player1.vel);

            if (speed > 0.1f) {
                Vector2 travelDir = Vector2Normalize(player1.vel);
                accel = travelDir * -DRAG_FACTOR;

                if (speed < (DRAG_FACTOR * deltaTime)) {
                    accel = {0.0f, 0.0f};
                    player1.vel = {0.0f, 0.0f};
                }
            } else {
                accel = {0.0f, 0.0f};
                player1.vel = {0.0f, 0.0f};
            }
        }

        Vector2 rawVel = player1.vel + (accel * deltaTime);
        float speed = Vector2Length(rawVel);
        float maxSpeed = Vector2Length(MAX_VEL);

        newVel = (speed > maxSpeed) ? Vector2Scale(Vector2Normalize(rawVel), maxSpeed) : rawVel;
        newPos = player1.pos + player1.vel * deltaTime + (accel * deltaTime * deltaTime * 0.5);

        player1.accel = accel;
        player1.vel = newVel;
        player1.pos = newPos;

        BeginDrawing();

        ClearBackground(RAYWHITE);

        // WARN: Temp render
        DrawCircleV(player1.pos, 10, player1Colour);
        DrawCircleV(player2.pos, 10, player2Colour);

        if (drawLine) {
            DrawLineV(player1.pos, normMousePos, GRAY);
        }

        EndDrawing();
    }

    CloseWindow();
    return 0;
}
