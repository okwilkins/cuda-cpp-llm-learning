#include <stdio.h>
#include <stdlib.h>

__global__ void genMatRow(unsigned int *out, unsigned int size) {
    unsigned int row = blockIdx.y * blockDim.y + threadIdx.y;

    if (row >= size) {
        return;
    }

    for (unsigned int i = 0; i < size; ++i) {
        out[row * size + i] = i;
    }

    return;
}

int main() {
    // Setup matrix specs
    const int size = 4;
    const unsigned int n = size * size;

    // Setup grid and block dimensions
    const dim3 dimGrid(1, size, 1);
    const dim3 dimBlock(1, 1, 1);

    const unsigned int memSize = n * sizeof(int);

    // Setup host memory
    unsigned int *M_h = (unsigned int *)malloc(memSize);
    if (M_h == NULL) {
        printf("Host memory allocation failed!\n");
        return -1;
    }

    // Setup device memory
    unsigned int *M_d;
    cudaError_t err = cudaMalloc((void **)&M_d, memSize);
    if (err != cudaSuccess) {
        printf("CUDA error [%s:%d]: %s\n", __FILE__, __LINE__, cudaGetErrorString(err));
        return 1;
    }

    genMatRow<<<dimGrid, dimBlock>>>(M_d, size);
    err = cudaDeviceSynchronize();
    if (err != cudaSuccess) {
        printf("CUDA error [%s:%d]: %s\n", __FILE__, __LINE__, cudaGetErrorString(err));
        return 1;
    }

    // Copy data from device back to host
    err = cudaMemcpy(M_h, M_d, memSize, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) {
        printf("CUDA error [%s:%d]: %s\n", __FILE__, __LINE__, cudaGetErrorString(err));
        return 1;
    }

    printf("Generated output:\n");
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j) {
            printf("%d ", M_h[i * size + j]);
        }
        printf("\n");
    }

    // Free the memory on the device and host
    free(M_h);
    cudaFree(M_d);

    return 0;
}
