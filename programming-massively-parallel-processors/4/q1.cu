__global__ void foo_kernel(int *a, int *b) {
    unsigned int i{blockIdx.x * blockIdx.x + threadIdx.x};

    if (threadIdx.x < 40 || threadIdx.x >= 104) {
        b[i] = a[i] + 1;
    }

    if (i % 2 == 0) {
        a[i] = b[i] * 2;
    }

    for (unsigned int j{0}; j < 5 - (i % 3); ++j) {
        b[i] += j;
    }
}

void foo(int *a_d, int *b_d) {
    unsigned int N{1024};
    foo_kernel<<<(N + 128 - 1) / 128, 128>>>(a_d, b_d);
}

// 1a. Num of warps per block = 128 / 32 (assuming the warp size is 32) = 4

// 1b. Num warps in grid = (1024 + 128 - 1) / 128 = 8 blocks
// 8 * 128 (threads per block) = 1,024 threads
// 1024 / 32 = 8 warps

// 1ci. Line 4: how many warps in the grid are active?
// For each block:
// Warp 0 (0-31) is active
// Warp 1 (32-63) is not fully active
// Warp 2 (64-95) is completely inactive
// Warp 3 (96-127) is not fully active
// So 3 * 8 (blocks) = 24 active warps

// 1cii: How many warps in the grid are divergent
// Warp 2 and 4 have not all the threads in the warp going onto the condition
// So 2 * 8 (blocks) = 16

// 1ciii: What is the SIMD efficiency (in %) of warp 0 of block 0?
// All threads will be executed at the same time, so 100%

// 1civ: What is the SIMD efficiency (in %) of warp 1 of block 0?
// Because of divergence there will be 2 passes
// Pass 1: Threads 32-39 will be active = 8 / 32 = 25%
// Pass 2: Threads 40-63 will be active = 24 / 32 = 75%
// On average = 50%

// 1cv: What is the SIMD efficiency (in %) of warp 3 of block 0?
// Because of divergence there will be 2 passes
// Pass 1: Threads 96-104 will be active = 9 / 32 = 28.1%
// Pass 2: Threads 105-127 will be active = 23 / 32 = 71.9%
// On average = 50%

// 1di. Line 7: How many warps in the grid are active?
// For each block half of the threads are active: 16.
// So all would be active.
