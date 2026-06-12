#pragma once

#include <array>
#include <cuda_runtime.h>
#include <iomanip>
#include <iostream>

#define CUDA_CHECK(call)                                                                           \
    do {                                                                                           \
        cudaError_t err = call;                                                                    \
        if (err != cudaSuccess) {                                                                  \
            fprintf(stderr, "CUDA Error [%s:%d]: %s\n", __FILE__, __LINE__,                        \
                    cudaGetErrorString(err));                                                      \
            exit(EXIT_FAILURE);                                                                    \
        }                                                                                          \
    } while (0)

template <std::size_t N> class DefaultSquareMatrix {
  public:
    DefaultSquareMatrix() {
        for (std::size_t row{0}; row < N; ++row) {
            for (std::size_t col{0}; col < N; ++col) {
                data[row * N + col] = 1.0;
            }
        }

        CUDA_CHECK(cudaMalloc((void **)&devicePtr, memSize));
        CUDA_CHECK(cudaMemcpy(devicePtr, data.data(), memSize, cudaMemcpyHostToDevice));

        std::cout << "Allocated: " << memSize << "B to the device\n";
    };
    DefaultSquareMatrix(const DefaultSquareMatrix &) = delete;
    DefaultSquareMatrix &operator=(const DefaultSquareMatrix &) = delete;
    DefaultSquareMatrix(DefaultSquareMatrix &&other) noexcept
        : data(std::move(other.data)), devicePtr(other.devicePtr) {
        other.devicePtr = nullptr;
    }
    DefaultSquareMatrix &operator=(DefaultSquareMatrix &&other) noexcept {
        if (this != &other) {
            if (devicePtr) {
                CUDA_CHECK(cudaFree(devicePtr));
                std::cout << "Freed: " << memSize << "B from the device\n";
            }
            data = std::move(other.data);
            devicePtr = other.devicePtr;
            other.devicePtr = nullptr;
        }

        return *this;
    }

    ~DefaultSquareMatrix() {
        CUDA_CHECK(cudaFree(devicePtr));
        std::cout << "Freed: " << memSize << "B from the device\n";
    }

    std::array<float, N * N> data{};
    static constexpr std::size_t size{N};
    static constexpr std::size_t memSize{N * N * sizeof(float)};
    float *devicePtr{nullptr};

    void print() const {
        for (std::size_t row{0}; row < N; ++row) {
            for (std::size_t col{0}; col < N; ++col) {
                std::cout << std::setw(2) << data[row * N + col] << " ";
            }
            std::cout << '\n';
        }
        std::cout << '\n';
    }
};

template <std::size_t N> class DefaultVector {
  public:
    DefaultVector() {
        for (std::size_t i{0}; i < N; ++i) {
            data[i] = 1.0;
        }

        CUDA_CHECK(cudaMalloc((void **)&devicePtr, memSize));
        CUDA_CHECK(cudaMemcpy(devicePtr, data.data(), memSize, cudaMemcpyHostToDevice));

        std::cout << "Allocated: " << memSize << "B to the device\n";
    };
    DefaultVector(const DefaultVector &) = delete;
    DefaultVector &operator=(const DefaultVector &) = delete;
    DefaultVector(DefaultVector &&other) noexcept
        : data(std::move(other.data)), devicePtr(other.devicePtr) {
        other.devicePtr = nullptr;
    }
    DefaultVector &operator=(DefaultVector &&other) noexcept {
        if (this != &other) {
            if (devicePtr) {
                CUDA_CHECK(cudaFree(devicePtr));
                std::cout << "Freed: " << memSize << "B from the device\n";
            }
            data = std::move(other.data);
            devicePtr = other.devicePtr;
            other.devicePtr = nullptr;
        }

        return *this;
    }

    ~DefaultVector() {
        CUDA_CHECK(cudaFree(devicePtr));
        std::cout << "Freed: " << memSize << "B from the device\n";
    }

    std::array<float, N> data{};
    static constexpr std::size_t size{N};
    static constexpr std::size_t memSize{N * sizeof(float)};
    float *devicePtr{nullptr};

    void print() const {
        std::cout << "{";

        for (std::size_t i{0}; i < N; ++i) {
            std::cout << std::setw(2) << data[i] << " ";
        }

        std::cout << "}\n";
    }
};
