#include <stdio.h>
#include <stdlib.h>

#define CUDA_CHECK(call)                                                                           \
    do {                                                                                           \
        cudaError_t err = call;                                                                    \
        if (err != cudaSuccess) {                                                                  \
            fprintf(stderr, "CUDA Error [%s:%d]: %s\n", __FILE__, __LINE__,                        \
                    cudaGetErrorString(err));                                                      \
            exit(EXIT_FAILURE);                                                                    \
        }                                                                                          \
    } while (0)

// Assumes that A, B and out are all the same size
__global__ void matMulRowiseKernel(unsigned int *const A, unsigned int *const B,
                                   unsigned int *const out, const unsigned int size) {
    // Row within A and col within B
    const unsigned int idx = blockDim.x * blockIdx.x + threadIdx.x;

    if (idx >= size) {
        return;
    }

    for (unsigned int i = 0; i < size; ++i) {
        unsigned int sum = 0;

        for (unsigned int j = 0; j < size; ++j) {
            sum += A[j + idx * size] * B[i + j * size];
        }

        out[i + idx * size] = sum;
    }
}

// Assumes that A, B and out are all the same size
__global__ void matMulColwiseKernel(unsigned int *const A, unsigned int *const B,
                                    unsigned int *const out, const unsigned int size) {
    // Row within A and col within B
    const unsigned int idx = blockDim.x * blockIdx.x + threadIdx.x;

    if (idx >= size) {
        return;
    }

    for (unsigned int i = 0; i < size; ++i) {
        unsigned int sum = 0;

        for (unsigned int j = 0; j < size; ++j) {
            sum += A[j + i * size] * B[j * size + idx];
        }

        out[i + idx * size] = sum;
    }
}

int main() {
    // Setup matrix specs
    const unsigned int size = 4;
    const unsigned int n = size * size;
    const unsigned int memSize = n * sizeof(unsigned int);

    // Setup host memory
    unsigned int *const A_h = (unsigned int *)malloc(memSize);
    unsigned int *const B_h = (unsigned int *)malloc(memSize);
    unsigned int *const out_h = (unsigned int *)malloc(memSize);

    if (A_h == NULL || B_h == NULL || out_h == NULL) {
        printf("Host memory allocation failed!\n");
        return -1;
    }

    // Allocate values for matrix A and B
    for (unsigned int i = 0; i < size; ++i) {
        for (unsigned int j = 0; j < size; ++j) {
            A_h[j + i * size] = j + i * size;
            B_h[j + i * size] = j + i * size;
        }
    }

    // Setup grid and block dimensions
    const dim3 dimGrid(size, 1, 1);
    const dim3 dimBlock(1, 1, 1);

    // Setup device memory
    unsigned int *A_d;
    unsigned int *B_d;
    unsigned int *out_d;

    CUDA_CHECK(cudaMalloc((void **)&A_d, memSize));
    CUDA_CHECK(cudaMalloc((void **)&B_d, memSize));
    CUDA_CHECK(cudaMalloc((void **)&out_d, memSize));

    CUDA_CHECK(cudaMemcpy(A_d, A_h, memSize, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(B_d, B_h, memSize, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(out_d, out_h, memSize, cudaMemcpyHostToDevice));

    // Compute
    matMulColwiseKernel<<<dimGrid, dimBlock>>>(A_d, B_d, out_d, size);
    CUDA_CHECK(cudaDeviceSynchronize());

    // Copy data from device back to host
    CUDA_CHECK(cudaMemcpy(out_h, out_d, memSize, cudaMemcpyDeviceToHost));

    printf("Generated output:\n");
    for (unsigned int i = 0; i < size; ++i) {
        for (unsigned int j = 0; j < size; ++j) {
            printf("%d ", out_h[i * size + j]);
        }
        printf("\n");
    }

    // Free the memory on the device and host
    free(A_h);
    free(B_h);
    free(out_h);

    cudaFree(A_d);
    cudaFree(B_d);
    cudaFree(out_d);

    return 0;
}
