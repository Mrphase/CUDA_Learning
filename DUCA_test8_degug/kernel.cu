#include <iostream>


#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include "../CUDA_Practice-master/include/matrix.cuh"




int getThreadNum(int gpu = 0)

{

	cudaDeviceProp prop;

	int count, maxThreadsPerBlock = 0;



	HANDLE_ERROR(cudaGetDeviceCount(&count));

	printf("GPU num: %d\n", count);



	for (size_t i = 0; i < count; i++)

	{

		HANDLE_ERROR(cudaGetDeviceProperties(&prop, i));

		printf("GPU: %d\n", i);

		printf("Max thread num: %d\n", prop.maxThreadsPerBlock);

		printf("Max grid dimensions: %d, %d, %d\n", prop.maxGridSize[0], prop.maxGridSize[1], prop.maxGridSize[2]);



		if (gpu == i)

		{

			maxThreadsPerBlock = prop.maxThreadsPerBlock;

		}

	}



	return maxThreadsPerBlock;

}



__global__ void

conv(float* imgGPU, float* kernelGPU, float* resultGPU,

	int width, int height, int kernelSize)

{

	int thIdx = threadIdx.x;

	int blkIdx = blockIdx.x;

	int id = blkIdx * blockDim.x + thIdx;

	if (id < width * height)

	{

		int row = id / width, // 卷积结果的行号

			col = id % width; // 卷积结果的列号



		for (int i = 0; i < kernelSize; ++i)

		{

			for (int j = 0; j < kernelSize; ++j)

			{

				float val = 0.0;

				int curRow = row - kernelSize / 2 + i,

					curCol = col - kernelSize / 2 + j;



				if (curRow >= 0 && curCol >= 0 && curRow < height && curCol < width)

					val = imgGPU[curRow * width + curCol];



				resultGPU[id] += kernelGPU[i * kernelSize + j] * val;
				//resultGPU[id] ++;
				
			}

		}

	}
	
}





int main(int argc, char const* argv[])

{

	int width = 1920, height = 1080;

	// float *img = new float[width * height];



	Matrix<float> img(width, height), result(width, height);

	for (size_t row = 0; row < height; ++row)

	{

		for (size_t col = 0; col < width; ++col)

		{

			img(row, col) = (row + col) % 256;

		}

	}

	img.printData();



	int kernelSize = 3;

	Matrix<float> kernel(kernelSize);

	for (size_t index = 0; index < kernel.getLength(); ++index)

	{

		kernel.data[index] = float(index % kernelSize) - 1.0;

	}

	kernel.printData();



	// GPU data

	float* imgGPU = img.toCUDA();

	float* kernelGPU = kernel.toCUDA();

	float* resultGPU;

	HANDLE_ERROR(cudaMalloc((void**)&resultGPU, img.getLength() * sizeof(float)));



	int threadNum = getThreadNum();

	int blockNum = (img.getLength() - 0.5) / threadNum + 1;

	conv << <blockNum, threadNum >> > (imgGPU, kernelGPU, resultGPU, width, height, kernelSize);

	// conv<<<blockNum, width*height>>>(imgGPU, kernelGPU, resultGPU, width, height, kernelSize);



	result.toCPU(resultGPU);

	result.printData();



	return 0;

}