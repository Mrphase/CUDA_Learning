
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "cuda_runtime.h"
#include <stdio.h>
#include "malloc.h"
#include "gputimer.h"
const int N = 16; //size of mat

void Transpose_Normal(int in[], int out[]){
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			out[i * N + j] = in[j * N + i];
		}
	}

}

__global__ void Transpose_GPU_ROW(int in[], int out[]) {
	int id = threadIdx.x;
	for (int i = 0; i < N; i++)
	{
		out[i * N + id] = in[id * N + i];  //?????????  data hazard?

	}
}

__global__ void Transpose_GPU_Element(int in[], int out[]) {
	int idx = blockIdx.x*16 + threadIdx.x;  //16 thread each block
	int idy = blockIdx.y*16+threadIdx.y;
	out[idx * N + idy] = in[idy * N + idx];
}

__global__ void Transpose_GPU_Element2(int in[], int out[]) {
	//??????????????????????use any way to define idx and idy dose matter?  Transpose 1,2 is correctboth and time using is simmilar
	int idx =threadIdx.x;  //16 thread each block    //use any way to define idx and idy dose matter?  Transpose 1,2 is correctboth and time using is simmilar
	int idy = blockIdx.x;
	out[idx * N + idy] = in[idy * N + idx];
}


int K = 32;

__global__ void transpose_parallel_per_element_tiled(float in[], float out[])
{
	int in_corner_i = blockIdx.x * K, in_corner_j = blockIdx.y * K;
	int out_corner_i = blockIdx.y * K, out_corner_j = blockIdx.x * K;

	int x = threadIdx.x, y = threadIdx.y;

	__shared__ float tile[K][K];

	tile[y][x] = in[(in_corner_i + x) + (in_corner_j + y) * N];
	__syncthreads();
	out[(out_corner_i + x) + (out_corner_j + y) * N] = title[x][y];
}

void Print_Matrix(int in[]) {
	printf("below is %c\n", in);
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++)
		{
			printf("%d  ", in[i * N + j]);
		}
		printf("\n");
	}
	printf("finish！！！！！！！！！！！！！！！！！！！！！！！！！！\n");
}
int main(){

	int sizeOfMat = N * N * sizeof(int);

	int* in = (int*) malloc(sizeOfMat);
	int* out = (int*)malloc(sizeOfMat);
	int* gold = (int*)malloc(sizeOfMat);
	int temp = 0;
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++) {
			in[i * N + j] = temp;
			gold[j * N + i] = temp;
			temp++;
		}
	}
	////GPU
	int* GPU_in, * GPU_out;
	cudaMalloc(&GPU_in, sizeOfMat);
	cudaMalloc(&GPU_out, sizeOfMat);
	cudaMemcpy(GPU_in, in, sizeOfMat, cudaMemcpyHostToDevice);

	////Gpu- Row
	GpuTimer timer;  //???? how to judge auglothim improvement runing on different device?  
	//such as: someone write A program running in 1 second, i change his' and running in 0.5 second on differint device, how can we compare this program?

	//
	timer.Start();
	Transpose_GPU_ROW << <1, N >> > (GPU_in, GPU_out);
	timer.Stop();
	printf("Time Transpose_GPU_ROW  = %g ms\n", timer.Elapsed()); // 補竃


	////Gpu- Element
	GpuTimer timer2;
	timer2.Start();
	dim3 block(N / 16, N / 16);
	dim3 thread(16, 16);
	//Transpose_GPU_Element << <block, thread >> > (GPU_in, GPU_out);
	Transpose_GPU_Element2 << <block, thread >> > (GPU_in, GPU_out);
	timer2.Stop();
	printf("Time Transpose_GPU_Element  = %g ms\n", timer2.Elapsed()); // 補竃


	Print_Matrix(in);
	//Print_Matrix(gold);
	
	Transpose_Normal(in, out);
	Print_Matrix(out);
	return 0;

}