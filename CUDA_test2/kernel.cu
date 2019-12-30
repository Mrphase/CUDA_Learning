
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size);

__global__ void addKernel(int *c, const int *a, const int *b)
{
    int i = threadIdx.x;//����ʹ��1��block�����̣߳�������Ҫʹ��thredid �ο���p31ҳ
    c[i] = a[i] + b[i];
}

int main() {
	int width = 1920;
	int height = 1080;
	float* img = new float[width * height];
	for (int row = 0; row < height; row++)
	{
		for (int col = 0; col < width; col++) {
			img[row * width + col] = (col + row) % 256;
		}
	}
	int kernelSize = 3;
	float* kernel = new float[kernelSize * kernelSize];

	for (int i = 0; i < kernelSize * kernelSize; i++)
	{
		kernel[i] = i % kernelSize - 1;
	}

	//visualization
	for (int row = 0; row < 10; row++)
	{
		for (int col = 0; col < 10; col++) {
			printf("%2.0f", img[row * width + col]);

		}
		printf("\n");
	}

	return 0;
}