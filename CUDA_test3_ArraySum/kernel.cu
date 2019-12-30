
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#define _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
__global__ void sum(float a, float b) {
	int id = threadIdx.x;

	//__shared__ float sdata[16];


}
int main()
{
	float a[16];
	for (int i = 0; i < 16; i++)

	{
		a[i] = i * (i + 1);

	}
	float* aGpu;
	cudaMalloc((void**)&aGpu, 16 * sizeof(float));
	cudaMemcpy(aGpu, a, 16 * sizeof(float), cudaMemcpyHostToDevice);

	float* bGpu;
	cudaMalloc((void**)&bGpu, 1 * sizeof(float));
	sum <<<1, 16>>> (*aGpu, *bGpu);

	float b[1];
	cudaMemcpy(bGpu, b, 1 * sizeof(float), cudaMemcpyDeviceToHost);

	printf("b: %f\n", b);

    return 0;
}
