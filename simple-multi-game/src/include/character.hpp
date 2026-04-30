#pragma once

#include "raylib.h"
#include "raymath.h"

class Character {
  public:
    int id{};
    Vector2 pos{};
    Vector2 vel{};
    Vector2 accel{};

    static constexpr float MAX_ACCEL{100.0f};

  public:
    explicit Character(int id, Vector2 pos, Vector2 vel, Vector2 accel)
        : id{id}, pos{pos}, vel{vel}, accel{accel} {}

    void applyForce(const Vector2 f) {
        accel += f;
        Vector2Clamp(accel, Vector2{-MAX_ACCEL, MAX_ACCEL}, Vector2{MAX_ACCEL, MAX_ACCEL});
    }
};
