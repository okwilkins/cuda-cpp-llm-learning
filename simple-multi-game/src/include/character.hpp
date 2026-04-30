#pragma once

#include "raylib.h"
#include <algorithm>
#include <limits>

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
        accel.x += f.x;
        accel.y += f.y;

        accel.x += std::clamp(accel.x, -MAX_ACCEL, MAX_ACCEL);
        accel.y += std::clamp(accel.y, -MAX_ACCEL, MAX_ACCEL);
    }
};
