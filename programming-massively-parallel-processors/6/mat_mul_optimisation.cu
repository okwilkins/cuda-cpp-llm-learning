#include "utils.cuh"

__global__ void naiveMatMul(float *const __restrict__ A, float *const __restrict__ B,
                            float *const __restrict__ out, unsigned int size) {
    const unsigned int row{blockDim.y * blockIdx.y + threadIdx.y};
    const unsigned int col{blockDim.x * blockIdx.x + threadIdx.x};

    if (row >= size || col >= size) {
        return;
    }

    float sum{};

    for (unsigned int i{0}; i < size; ++i) {
        sum += A[row * size + i] * B[col + i * size];
    }

    out[row * size + col] = sum;
}

template <int TILE>
__global__ void tiledMatMul(float *const __restrict__ A, float *const __restrict__ B,
                            float *const __restrict__ out, int size) {
    __shared__ float s_A[TILE][TILE];
    __shared__ float s_B[TILE][TILE];

    const unsigned int bx{blockIdx.x};
    const unsigned int by{blockIdx.y};
    const unsigned int tx{threadIdx.x};
    const unsigned int ty{threadIdx.y};

    // Identify the row and col of the output matrix element to work on
    const unsigned int row{TILE * by + ty};
    const unsigned int col{TILE * bx + tx};

    float product{0.0f};

    for (int phase{0}; phase < (size + TILE - 1) / TILE; ++phase) {
        const unsigned int aCol(phase * TILE + tx);
        const unsigned int bRow(phase * TILE + ty);

        const unsigned int globalAIdx{(row * size) + aCol};
        const unsigned int globalBIdx{(bRow * size) + col};

        (row < size && aCol < size) ? s_A[ty][tx] = A[globalAIdx] : s_A[ty][tx] = 0.0f;
        (col < size && bRow < size) ? s_B[ty][tx] = B[globalBIdx] : s_B[ty][tx] = 0.0f;
        __syncthreads();

        for (int i{0}; i < TILE; ++i) {
            product += s_A[ty][i] * s_B[i][tx];
        }
        __syncthreads();
    }

    if (row < size && col < size) {
        out[row * size + col] = product;
    }
}

template <int TILE, int COARSENING>
__global__ void rowCoarsenedTiledMatMul(float *const __restrict__ A, float *const __restrict__ B,
                                        float *const __restrict__ out, int size) {
    __shared__ float s_A[TILE * COARSENING][TILE];
    __shared__ float s_B[TILE][TILE];

    const unsigned int bx{blockIdx.x};
    const unsigned int by{blockIdx.y};
    const unsigned int tx{threadIdx.x};
    const unsigned int ty{threadIdx.y};

    // Identify the row and col of the output matrix element to work on
    const unsigned int rowBase{TILE * COARSENING * by + ty};
    const unsigned int col{TILE * bx + tx};

    float products[COARSENING]{0.0f};

    for (int phase{0}; phase < (size + TILE - 1) / TILE; ++phase) {
        const unsigned int aCol(phase * TILE + tx);
        const unsigned int bRow(phase * TILE + ty);

        // Load A rows for all coarsened outputs and one B tile into SMEM
        // The number of A rows depends on COARSENING
        for (int c{0}; c < COARSENING; ++c) {
            const unsigned int row{rowBase + c * TILE};

            // Load A tile
            (row < size && aCol < size) ? s_A[ty + c * TILE][tx] = A[row * size + aCol]
                                        : s_A[ty + c * TILE][tx] = 0.0f;
        }

        // Load B tile
        (col < size && bRow < size) ? s_B[ty][tx] = B[bRow * size + col] : s_B[ty][tx] = 0.0f;
        __syncthreads();

        // Calculate products
        for (int i{0}; i < TILE; ++i) {
            for (int c{0}; c < COARSENING; ++c) {
                products[c] += s_A[ty + c * TILE][i] * s_B[i][tx];
            }
        }
        __syncthreads();
    }

    for (int c{0}; c < COARSENING; ++c) {
        const unsigned int row{rowBase + c * TILE};

        if (row < size && col < size) {
            out[row * size + col] = products[c];
        }
    }
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
    constexpr int TILE{32};
    constexpr int COARSENING{4};

    constexpr int BLOCK{(matSize + TILE - 1) / TILE};
    constexpr int COARSENED_BLOCK_Y{(matSize + TILE * COARSENING - 1) / (TILE * COARSENING)};

    const dim3 dimGrid(BLOCK, BLOCK);
    const dim3 coarsenedDimGrid(BLOCK, COARSENED_BLOCK_Y);
    const dim3 dimBlock(TILE, TILE);

    // Naive matmul
    naiveMatMul<<<dimGrid, dimBlock>>>(A.devicePtr, B.devicePtr, out.devicePtr, A.size);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    out = DefaultSquareMatrix<matSize>{};

    // Basic tiled matmul
    std::cout << "\n\n========================\n";
    std::cout << "Launching tiled matmul kernel with:\n";
    std::cout << "\tNum blocks: " << BLOCK * BLOCK << '\n';
    std::cout << "\tTile Size: " << TILE << '\n';
    std::cout << "========================\n\n";

    // This will contain many bank conflicts
    tiledMatMul<TILE><<<dimGrid, dimBlock>>>(A.devicePtr, B.devicePtr, out.devicePtr, A.size);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    out = DefaultSquareMatrix<matSize>{};

    rowCoarsenedTiledMatMul<TILE, COARSENING>
        <<<coarsenedDimGrid, dimBlock>>>(A.devicePtr, B.devicePtr, out.devicePtr, A.size);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    out = DefaultSquareMatrix<matSize>{};
    return 0;
}
