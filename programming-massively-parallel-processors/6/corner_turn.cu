#include "utils.cuh"

int main() {
    DefaultSquareMatrix<16> mat_h{};
    DefaultSquareMatrix<16> T_h{};

    mat_h.print();

    // Setup grid and block dimensions
    const dim3 dimGrid(mat_h.size, 1, 1);
    const dim3 dimBlock(1, 1, 1);

    return 0;
}
