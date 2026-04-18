#include "utils.hpp"
#include <array>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>

template <typename T> __global__ void matVecMul(T *a, const T *B, const T *c, unsigned int size) {
    const unsigned int row{blockDim.x * blockIdx.x + threadIdx.x};

    if (row >= size) {
        return;
    }

    T sum{};

    for (unsigned int i{0}; i < size; ++i) {
        sum += B[row * size + i] * c[i];
    }

    a[row] = sum;
}

template <typename T> void matVecMul_stub(T *a, const T *B, const T *c, unsigned int size) {
    constexpr unsigned int blockSize{256};

    matVecMul<<<(size + blockSize - 1) / blockSize, blockSize>>>(a, B, c, size);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
}

int main() {
    constexpr unsigned int dims{3};
    constexpr std::array<const float, dims> c_h{1, 2, 3};
    constexpr std::array<const float, dims * dims> B_h{1, 1, 1, 2, 2, 2, 3, 3, 3};
    std::array<float, dims> a_h{};
    constexpr unsigned int vecSize{sizeof(float) * dims};
    constexpr unsigned int matSize{sizeof(float) * dims * dims};

    std::cout << "Input matrix:\n";
    for (size_t i{0}; i < dims; ++i) {
        std::cout << "| ";
        for (size_t j{0}; j < dims; ++j) {
            std::cout << B_h[j + i * dims] << " ";
        }
        std::cout << "|\n";
    }
    std::cout << '\n';

    std::cout << "Input vector:\n";
    std::cout << "{ ";
    for (size_t i{0}; i < dims; ++i) {
        std::cout << c_h[i] << " ";
    }
    std::cout << "}\n\n";

    // Setup device memory
    float *c_d{};
    float *B_d{};
    float *a_d{};

    CUDA_CHECK(cudaMalloc((void **)&c_d, vecSize));
    CUDA_CHECK(cudaMalloc((void **)&B_d, matSize));
    CUDA_CHECK(cudaMalloc((void **)&a_d, vecSize));

    CUDA_CHECK(cudaMemcpy(c_d, c_h.data(), vecSize, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(B_d, B_h.data(), matSize, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(a_d, a_h.data(), vecSize, cudaMemcpyHostToDevice));

    // Compute
    static_assert(dims < 2048);
    matVecMul_stub(a_d, B_d, c_d, dims);

    // Copy data from device back to host
    CUDA_CHECK(cudaMemcpy(a_h.data(), a_d, vecSize, cudaMemcpyDeviceToHost));

    std::cout << "Generated output:\n{ ";
    for (size_t i{0}; i < dims; ++i) {
        std::cout << a_h[i] << ' ';
    }

    std::cout << "}\n";

    return EXIT_SUCCESS;
}
