
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "device_functions.h"
#include <stdio.h>
//# define num 10 
__global__ void add1(int* a, int* b, int* c, int nu) {
	int i = threadIdx.x;
	if (i < nu) {
		c[i] = b[i] + a[i];
		//__syncthreads();
	}
	//__syncthreads();
}
int main(void) {
	const int num = 10;//没有从上图报错 ： 表达式必须有常量值
	int a[num], b[10], c[10];
	int* a_gpu, * b_gpu, * c_gpu;

	for (int i = 0; i < num; i++) {
		a[i] = i;
		b[i] = i * i;

	}
	cudaMalloc((void**)&a_gpu, num * sizeof(int));
	cudaMalloc((void**)&b_gpu, num * sizeof(int));
	cudaMalloc((void**)&c_gpu, num * sizeof(int));

	//copy data
	cudaMemcpy(a_gpu, a, num * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(b_gpu, b, num * sizeof(int), cudaMemcpyHostToDevice);

	
	add1 <<<1,10>>>(a_gpu, b_gpu, c_gpu, num); //应输入表达式，解决： 应输入表达式： 形参出问题， 是*a 不是a 与文件名无关

	//将此处改为<<<10,1>>>会出现问题： c为0
	//get data 
	cudaMemcpy(c, c_gpu, num * sizeof(int), cudaMemcpyDeviceToHost);

	//visualization
	for (int i = 0; i < num; i++)
	{
		printf("%d + %d = %d\n", a[i], b[i], c [i]);
	}

	return 0;


}