
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

cudaError_t addWithCuda(int* c, const int* a, const int* b, unsigned int size);

int getNum() {
	cudaDeviceProp prop;
	int num;
	cudaGetDeviceCount(&num);
	cudaGetDeviceProperties(&prop, 0);
	printf("thread num = %d\n", prop.maxThreadsPerBlock);
	printf("thread num = %d , %d,%d\n", prop.maxGridSize[0], prop.maxGridSize[1], prop.maxGridSize[2]);
	//printf("thread num = %d", prop.maxThreadsPerBlock);
	return prop.maxThreadsPerBlock;
}

__global__ void addKernel(int* c, const int* a, const int* b)
{
	int i = threadIdx.x;//由于使用1个block，个线程，所以需要使用thredid 参考书p31页
	c[i] = a[i] + b[i];
}

__global__ void conv(float *img, float *kernel,
	float *result, int width, int height, int kernelSize) {
	int ti = threadIdx.x;
	int bi = blockIdx.x;
	int id = (bi * blockDim.x+ti);// 1024 is thread num
	//int id = threadIdx.x + blockDim.x * blockIdx.x;
	if (id >= width*height)
	{
		return;
	}
	int row = id / width;
	int col = id % width;

	for (int i = 0; i < 3; ++i)
	{
		for (int j = 0; j < 3; ++j) {
			float imgValue = 0.0;
			int curRow = row - kernelSize /2 +i;
			int curCol = col - kernelSize / 2 + j;
			
			//if (curCol < 0 || curRow < 0 || curCol >= width || curRow >= height) {}

			if (curRow >= 0 && curCol >= 0 && curRow < height && curCol < width)
			{
				imgValue = img[curRow * width + curCol];
				
				//printf("%2.0f", result[id]);
				result[id] += kernel[i * kernelSize + j] * imgValue;
			}
			
			//printf("!!!!!!!!%2.0f", result[id]);
			//result[id] += kernel[i * kernelSize + j] * imgValue;
		}
		
	}
	//printf("!!!!!!!!%2.0f", result[0]);
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

	float *d_img;
	float *d_kernel;
	float *d_result;

	cudaMalloc((void**)&d_img, width * height * sizeof(float));
	cudaMalloc((void**)&d_kernel, kernelSize * kernelSize* sizeof(float)); //3*3
	cudaMalloc((void**)&d_result, width * height * sizeof(float));
	
	cudaMemcpy(d_img,img, width * height * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(d_kernel, img, 9 * sizeof(float), cudaMemcpyHostToDevice);
	//cudaMemcpy((void**)&d_result, img, width * height * sizeof(float), cudaMemcpyHostToDevice);

	//need num of block and thread
	int threadNum =  getNum();//thread num
	int blockNum = (width * height - 0.5) / threadNum + 1;

	conv << <blockNum, threadNum >> > 
		(d_img, d_kernel, d_result, width, height, kernelSize);
	
	float* result = new float[width * height];
	cudaMemcpy(result, d_result,
		width * height * sizeof(float), cudaMemcpyDeviceToHost);


	//visualization
	printf("img\n");
	for (int row = 0; row < 10; row++)
	{
		for (int col = 0; col < 10; col++) {
			//printf("%2.0f，%2.0f ___", row, col);
			printf("%2.0f ", img[col + row * width]);

		}
		printf("\n");
	}
	//printf("kernel\n");
	printf("kernel\n");
	for (int row = 0; row < kernelSize; row++)
	{
		for (int col = 0; col < kernelSize; col++) {
			printf("%2.0f ", kernel[col + row * kernelSize]);

		}
		printf("\n");
	}

	printf("result\n");
	for (int row = 0; row < 5; row++)
	{
		for (int col = 0; col < 5; col++) {
			//printf("%2.0f，%2.0f ___", row,col);
			printf("%2.0f ", result[col + row * width]);

		}
		printf("\n");
	}
	printf("result: %2.0f",result[0]);




	return 0;
}