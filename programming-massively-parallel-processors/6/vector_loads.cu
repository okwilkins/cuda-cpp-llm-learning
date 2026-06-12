#include "utils.cuh"

__global__ void naiveVectorAdd(float *const A, float *const B, float *const out,
                               unsigned int size) {
    const unsigned int idx{blockDim.x * blockIdx.x + threadIdx.x};

    if (idx >= size) {
        return;
    }

    out[idx] = A[idx] + B[idx];
}

__global__ void restrictVectorAdd(float *const) {}

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

    constexpr unsigned int vecSize{2048};
    const int threadsPerBlock{prop.maxThreadsPerMultiProcessor / 4};
    const int blocks{(static_cast<int>(vecSize) + threadsPerBlock - 1) / threadsPerBlock};

    DefaultVector<vecSize> A{};
    DefaultVector<vecSize> B{};
    DefaultVector<vecSize> out{};

    std::cout << "\n\n========================\n";
    std::cout << "Launching naive vector add kernel with:\n";
    std::cout << "\tNum blocks           : " << blocks << '\n';
    std::cout << "\tNum threads per block: " << threadsPerBlock << '\n';
    std::cout << "========================\n\n";

    naiveVectorAdd<<<blocks, threadsPerBlock>>>(A.devicePtr, B.devicePtr, out.devicePtr, A.size);

    cudaDeviceSynchronize();
    CUDA_CHECK(cudaMemcpy(out.data.data(), out.devicePtr, out.memSize, cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    out.print();

    out = DefaultVector<vecSize>{};

    return 0;
}
