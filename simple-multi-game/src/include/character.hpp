#pragma once

#include "raylib.h"
#include "raymath.h"

enum class CharacterAction { walk, idle };

class Character {
  public:
    int id{};
    Vector2 pos{};
    Vector2 desiredPos{};
    Vector2 vel{};
    Vector2 accel{};
    CharacterAction action{};

    static constexpr float MAX_ACCEL{100.0f};

  public:
    explicit Character(int id, Vector2 pos, Vector2 vel, Vector2 accel, CharacterAction action)
        : id{id}, pos{pos}, vel{vel}, accel{accel}, action{action} {
        desiredPos = pos;
    }

    explicit Character(int id, Vector2 pos, Vector2 vel, Vector2 accel)
        : id{id}, pos{pos}, vel{vel}, accel{accel} {
        action = CharacterAction::idle;
        desiredPos = pos;
    }
};
