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

__global__ void tiledMatMul(float *const A, float *const B, float *const out, unsigned int size) {
    extern __shared__ float s_data[];

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
    cudaDeviceProp prop{};
    CUDA_CHECK(cudaGetDeviceProperties(&prop, 0));

    std::cout << std::fixed << std::setprecision(2);
    std::cout << "Device: " << prop.name << '\n';
    std::cout << "Compute capability: " << prop.major << '.' << prop.minor << '\n';
    std::cout << "SM count: " << prop.multiProcessorCount << '\n';
    std::cout << "Warp size: " << prop.warpSize << '\n';
    std::cout << "Max threads per block: " << prop.maxThreadsPerBlock << '\n';
    std::cout << "Max threads per SM: " << prop.maxThreadsPerMultiProcessor << '\n';
    std::cout << "Max block dimensions: (" << prop.maxThreadsDim[0] << ", " << prop.maxThreadsDim[1]
              << ", " << prop.maxThreadsDim[2] << ")\n";
    std::cout << "Max grid dimensions: (" << prop.maxGridSize[0] << ", " << prop.maxGridSize[1]
              << ", " << prop.maxGridSize[2] << ")\n";
    std::cout << "Registers per block: " << prop.regsPerBlock << '\n';
    std::cout << "Registers per SM: " << prop.regsPerMultiprocessor << '\n';
    std::cout << "Shared memory per block: " << prop.sharedMemPerBlock / 1024.0 << " KiB\n";
    std::cout << "Shared memory per SM: " << prop.sharedMemPerMultiprocessor / 1024.0 << " KiB\n";
    std::cout << "Constant memory: " << prop.totalConstMem / 1024.0 << " KiB\n";
    std::cout << "L2 cache size: " << prop.l2CacheSize / 1024.0 << " KiB\n";
    std::cout << "Global memory: " << prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0) << " GiB\n";
    std::cout << "Core clock: " << prop.clockRate / 1000.0 << " MHz\n";
    std::cout << "Memory clock: " << prop.memoryClockRate / 1000.0 << " MHz\n";
    std::cout << "Memory bus width: " << prop.memoryBusWidth << " bits\n";
    std::cout << "========================\n\n";

    constexpr unsigned int matSize{512};
    DefaultSquareMatrix<matSize> A{};
    DefaultSquareMatrix<matSize> B{};
    DefaultSquareMatrix<matSize> out{};

    // Setup grid and block dimensions
    unsigned int blockWidth{static_cast<unsigned int>(
        sqrtf(static_cast<float>(prop.sharedMemPerBlock) / static_cast<float>(sizeof(float))))};

    if (blockWidth * blockWidth > prop.maxThreadsPerBlock) {
        blockWidth = static_cast<unsigned int>(sqrtf(static_cast<float>(prop.maxThreadsPerBlock)));
    }
    const unsigned int numBlocks{(matSize + blockWidth - 1) / blockWidth};

    const dim3 dimGrid{numBlocks, numBlocks, 1};
    const dim3 dimBlock(blockWidth, blockWidth, 1);

    naiveMatMul<<<dimGrid, dimBlock>>>(A.devicePtr, B.devicePtr, out.devicePtr, A.size);
    tiledMatMul<<<dimGrid, dimBlock, prop.sharedMemPerBlock>>>(A.devicePtr, B.devicePtr,
                                                               out.devicePtr, A.size);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    out.print();

    return 0;
}
