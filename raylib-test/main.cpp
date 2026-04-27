#include "raylib.h"

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
