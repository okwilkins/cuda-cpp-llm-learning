#pragma once

#include "raylib.h"

constexpr Color characterIdColour(int id) {
    switch (id % 4) {
    case 0:
        return RED;
    case 1:
        return BLUE;
    case 2:
        return GREEN;
    case 3:
        return YELLOW;
    default:
        return BLACK;
    }
}
