
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "device_functions.h"
#include <stdio.h>


__global__ void sum11(float *a, float *b) {
	int id = threadIdx.x;

	__shared__ float sdata[16];
	sdata[id] = a[id]; //赋值不用for ,一个线程做一件事
	__syncthreads();

	for (int i = 8; i >0; i/=2)
	{
		if (id < i)
		{

			sdata[id] += sdata[id + i];
		}
		__syncthreads(); //内存同步

	}
	if (id==0)
	{
		b[0] = sdata[0];
	}
}
int main()
{
	float a[16];
	for (int i = 0; i < 16; i++)

	{
		a[i] = i ;

	}
	float* aGpu;
	cudaMalloc((void**)&aGpu, 16 * sizeof(float));
	cudaMemcpy(aGpu, a, 16 * sizeof(float), cudaMemcpyHostToDevice);

	float* bGpu;
	cudaMalloc((void**)&bGpu, 1 * sizeof(float));
	sum11 <<<1, 16 >>> (aGpu, bGpu);//应输入表达式： 形参出问题， 是*a 不是a

	float b[1];
	cudaMemcpy(b, bGpu, 1 * sizeof(float), cudaMemcpyDeviceToHost);

	printf("b: %f\n", b[0]);

	return 0;
}
