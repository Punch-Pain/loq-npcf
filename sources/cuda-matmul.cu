#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void matmul(float *A, float *B, float *C, int N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < N && col < N) {
        float sum = 0.0f;
        for (int k = 0; k < N; k++) {
            sum += A[row * N + k] * B[k * N + col];
        }
        C[row * N + col] = sum;
    }
}

int main(int argc, char **argv) {
    int N = 4096;
    int secs = 300;
    if (argc > 1) secs = atoi(argv[1]);

    size_t size = N * N * sizeof(float);
    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);
    cudaMalloc(&d_C, size);

    float *h_A = (float *)malloc(size);
    float *h_B = (float *)malloc(size);
    for (int i = 0; i < N * N; i++) {
        h_A[i] = (float)(rand() % 1000) / 1000.0f;
        h_B[i] = (float)(rand() % 1000) / 1000.0f;
    }
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    dim3 bl(16, 16);
    dim3 gr((N + 15) / 16, (N + 15) / 16);

    printf("cuda-matmul: N=%d secs=%d gr(%d,%d) bl(%d,%d)\n", N, secs, gr.x, gr.y, bl.x, bl.y);
    printf("Starting GPU compute loop...\n");
    fflush(stdout);

    clock_t start = clock();
    int iters = 0;
    while ((clock() - start) / CLOCKS_PER_SEC < secs) {
        matmul<<<gr, bl>>>(d_A, d_B, d_C, N);
        cudaDeviceSynchronize();
        iters++;
    }
    printf("Done: %d iterations in %ld seconds\n", iters, (long)(clock() - start) / CLOCKS_PER_SEC);
    fflush(stdout);

    free(h_A);
    free(h_B);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    return 0;
}
