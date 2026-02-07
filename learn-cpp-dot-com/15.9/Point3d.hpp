#pragma once

class Vector3d;

class Point3d {
  private:
    double m_x{};
    double m_y{};
    double m_z{};

  public:
    Point3d(double x, double y, double z) : m_x{x}, m_y{y}, m_z{z} {}

    void print() const;
    void moveByVector(const Vector3d &v);
};
