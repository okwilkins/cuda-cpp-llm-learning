#include "utils.cuh"

__global__ void naiveMatMul(float *const A, float *const B, float *const out, unsigned int size) {
    unsigned int row{blockDim.y * blockIdx.y + threadIdx.y};
    unsigned int col{blockDim.x * blockIdx.x + threadIdx.x};

    if (row >= size || col >= size) {
        return;
    }

    float sum{};

    for (unsigned int i{0}; i < size; ++i) {
        sum += A[row * size + i] * B[col + i * size];
    }

    out[row * size + col] = sum;
}

int main() {
    DefaultSquareMatrix<128> A{};
    DefaultSquareMatrix<128> B{};
    DefaultSquareMatrix<128> out{};

    // Setup grid and block dimensions
    const dim3 dimGrid(1, 1, 1);
    const dim3 dimBlock(A.size, A.size, 1);

    naiveMatMul<<<dimGrid, dimBlock>>>(A.devicePtr, B.devicePtr, out.devicePtr, A.size);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));

    out.print();

    return 0;
}
