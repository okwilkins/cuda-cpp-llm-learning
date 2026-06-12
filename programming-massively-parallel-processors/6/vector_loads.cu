#include "utils.cuh"

__global__ void naiveVectorAdd(float *const A, float *const B, float *const out,
                               unsigned int size) {
    const unsigned int idx{blockDim.x * blockIdx.x + threadIdx.x};

    if (idx >= size) {
        return;
    }

    out[idx] = A[idx] + B[idx];
}

__global__ void restrictVectorAdd(float *const __restrict__ A, float *const __restrict__ B,
                                  float *const __restrict__ out, unsigned int size) {
    const unsigned int idx{blockDim.x * blockIdx.x + threadIdx.x};

    if (idx >= size) {
        return;
    }

    out[idx] = A[idx] + B[idx];
}

__global__ void vectorLoadsVectorAdd(float *const __restrict__ A, float *const __restrict__ B,
                                     float *const __restrict__ out, unsigned int vec4Count) {
    const unsigned int idx{blockDim.x * blockIdx.x + threadIdx.x};
    if (idx >= vec4Count) {
        return;
    }

    const float4 A4 = ((float4 *)A)[idx];
    const float4 B4 = ((float4 *)B)[idx];
    const float4 out4{A4.x + B4.x, A4.y + B4.y, A4.z + B4.z, A4.w + B4.w};

    ((float4 *)out)[idx] = out4;
}

__global__ void coarsenedVectorAdd(float *const __restrict__ A, float *const __restrict__ B,
                                   float *const __restrict__ out, unsigned int size,
                                   int coarseningFactor) {
    const unsigned int idx{(blockDim.x * blockIdx.x + threadIdx.x) * coarseningFactor};

    for (int i{}; i < coarseningFactor; ++i) {
        const unsigned int coarsenedIdx{idx + i};
        if (coarsenedIdx >= size) {
            return;
        }

        out[coarsenedIdx] = A[coarsenedIdx] + B[coarsenedIdx];
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

    constexpr unsigned int vecSize{2048 * 128};
    constexpr int coarseningFactor{32};

    constexpr unsigned int vec4Count{vecSize / 4};
    constexpr unsigned int coarsenedCount{vecSize / coarseningFactor};

    const int threadsPerBlock{prop.maxThreadsPerMultiProcessor / 4};

    const int blocks{(static_cast<int>(vecSize) + threadsPerBlock - 1) / threadsPerBlock};
    const int blocksVec4{(static_cast<int>(vec4Count) + threadsPerBlock - 1) / threadsPerBlock};
    const int blocksCoarsened{(static_cast<int>(coarsenedCount) + threadsPerBlock - 1) /
                              threadsPerBlock};

    DefaultVector<vecSize> A{};
    DefaultVector<vecSize> B{};
    DefaultVector<vecSize> out{};

    std::cout << "\n\n========================\n";
    std::cout << "Launching naive vector add kernel with:\n";
    std::cout << "\tNum blocks           : " << blocks << '\n';
    std::cout << "\tNum threads per block: " << threadsPerBlock << '\n';
    std::cout << "========================\n\n";

    naiveVectorAdd<<<blocks, threadsPerBlock>>>(A.devicePtr, B.devicePtr, out.devicePtr, vecSize);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    out = DefaultVector<vecSize>{};

    std::cout << "\n\n========================\n";
    std::cout << "Launching restrictive naive vector add kernel with:\n";
    std::cout << "\tNum blocks           : " << blocks << '\n';
    std::cout << "\tNum threads per block: " << threadsPerBlock << '\n';
    std::cout << "========================\n\n";

    restrictVectorAdd<<<blocks, threadsPerBlock>>>(A.devicePtr, B.devicePtr, out.devicePtr,
                                                   vecSize);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    out = DefaultVector<vecSize>{};

    std::cout << "\n\n========================\n";
    std::cout << "Launching vector loads vector add kernel with:\n";
    std::cout << "\tNum blocks           : " << blocksVec4 << '\n';
    std::cout << "\tNum threads per block: " << threadsPerBlock << '\n';
    std::cout << "========================\n\n";

    vectorLoadsVectorAdd<<<blocksVec4, threadsPerBlock>>>(A.devicePtr, B.devicePtr, out.devicePtr,
                                                          vec4Count);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    out = DefaultVector<vecSize>{};

    std::cout << "\n\n========================\n";
    std::cout << "Launching coarsened vector add kernel with:\n";
    std::cout << "\tNum blocks           : " << blocksCoarsened << '\n';
    std::cout << "\tNum threads per block: " << threadsPerBlock << '\n';
    std::cout << "========================\n\n";

    coarsenedVectorAdd<<<blocksCoarsened, threadsPerBlock>>>(
        A.devicePtr, B.devicePtr, out.devicePtr, vecSize, coarseningFactor);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    out = DefaultVector<vecSize>{};

    return 0;
}
