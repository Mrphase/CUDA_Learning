//C++
#include <time.h>
#include <iostream>
using namespace std;


#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "../CUDA_test6_conclution/gputimer.h"
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <cmath>
void Print_Matrix(int in[]) {
	printf("below is %c\n", in);
	for (int i = 0; i < 10; i++)
	{
		for (int j = 0; j < 10; j++)
		{
			printf("%d  ", in[i * 10 + j]);
		}
		printf("\n");
	}
	printf("finish——————————————————————————\n");
}
// 核函数
__global__ void transformKernel(float* output,
	cudaTextureObject_t texObj,
	int width, int height)
{
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x<0 || x>width || y<0 || y>height)
		return;
	output[x * width + y] = tex2D<float>(texObj, x + 0.5f, y + 0.5f);
}

__global__ void Transpose_GPU_Element(int in[], int out[]) {
	int idx = threadIdx.x;  //16 thread each block    //use any way to define idx and idy dose matter?  Transpose 1,2 is correctboth and time using is simmilar
	int idy = blockIdx.x;
	out[idx * 1024 + idy] = in[idy * 1024 + idx];
}
int main()
{
	
	int width = 1024;
	int height = 1024;
	int size = width * height * sizeof(float);

	float* h_data = new float[width * height];

	for (int y = 0; y < height; y++)
	{
		for (int x = 0; x < width; x++)
		{
			h_data[y * width + x] = x;
		}
	}
	printf("origin \n");
	for (int y = 0; y < 10; y++)
	{
		for (int x = 0; x < 10; x++)
		{
			printf("%2.0f ", h_data[y * width + x]);
		}
		printf("\n");
	}


	cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc(32, 0, 0, 0, cudaChannelFormatKindFloat);

	cudaArray* cuArray;
	cudaMallocArray(&cuArray, &channelDesc, width, height);
	cudaMemcpyToArray(cuArray, 0, 0, h_data, size, cudaMemcpyHostToDevice);

	// 创建纹理对象
	struct cudaResourceDesc resDesc;
	memset(&resDesc, 0, sizeof(resDesc));
	resDesc.resType = cudaResourceTypeArray;
	resDesc.res.array.array = cuArray;

	struct cudaTextureDesc texDesc;
	memset(&texDesc, 0, sizeof(texDesc));
	texDesc.addressMode[0] = cudaAddressModeBorder;
	texDesc.addressMode[1] = cudaAddressModeBorder;
	texDesc.filterMode = cudaFilterModeLinear;
	texDesc.readMode = cudaReadModeElementType;
	texDesc.normalizedCoords = 0;

	cudaTextureObject_t texObj = 0;
	cudaCreateTextureObject(&texObj, &resDesc, &texDesc, NULL);

	float* output;
	cudaMalloc((void**)&output, size);

	// 调用核函数
	dim3 dimBlock(4, 4);
	dim3 dimGrid(max((width + dimBlock.x - 1) / dimBlock.x, 1),
		max((height + dimBlock.y - 1) / dimBlock.y, 1));



	///////////////////////////////////////////////////copy from test6
	int N = 1024;
	int sizeOfMat = N * N * sizeof(int);

	int* in = (int*)malloc(sizeOfMat);
	int* out = (int*)malloc(sizeOfMat);
	int* gold = (int*)malloc(sizeOfMat);
	int temp = 0;
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++) {
			in[i * N + j] = j;
			//printf("<%2.0f,%2.0f>",i, h_data[i * width + j]);
			gold[j * N + i] = j;
			//temp++;

		}
	}
	int* GPU_in, * GPU_out;
	cudaMalloc(&GPU_in, sizeOfMat);
	cudaMalloc(&GPU_out, sizeOfMat);
	cudaMemcpy(GPU_in, h_data, sizeOfMat, cudaMemcpyHostToDevice);
	////Gpu- Element
	GpuTimer timer2;
	timer2.Start();
	dim3 block(N / 16, N / 16);
	dim3 thread(16, 16);
	Transpose_GPU_Element << <N, N >> > (GPU_in, GPU_out);

	cudaMemcpy(out, GPU_out,sizeOfMat, cudaMemcpyDeviceToHost);
	//Transpose_GPU_Element2 << <block, thread >> > (GPU_in, GPU_out

	timer2.Stop();
	printf("Time Transpose_GPU_Element  = %g ms\n", timer2.Elapsed()); // 输出
	printf("Element \n", out);
	cudaFree(GPU_out);

	for (int i = 0; i < 10; i++)
	{
		for (int j = 0; j < 10; j++)
		{
			printf("%d ", gold[i * 1024 + j]);
		}
		printf("\n");
	}
	printf("finish——————————————————————————\n");
	///////////////////////////////////////////////////copy from test6


	//Gpu- texture
	GpuTimer timer;
	timer.Start();
	transformKernel << <dimGrid, dimBlock >> > (output,
		texObj,
		width, height);;
	timer.Stop();
	printf("Time Transpose_Using_texture  = %g ms\n", timer.Elapsed()); // 输出




	cudaMemcpy(h_data, output, size, cudaMemcpyDeviceToHost);
	printf("texture  \n");
	for (int y = 0; y < 10; y++)
	{
		for (int x = 0; x < 10; x++)
		{
			printf("%2.0f ", h_data[y * 1024 + x]);
		}
		printf("\n");
	}

	// 销毁纹理对象
	cudaDestroyTextureObject(texObj);

	// 释放设备内存
	cudaFreeArray(cuArray);
	cudaFree(output);

	delete[]h_data;

	return 0;
}

