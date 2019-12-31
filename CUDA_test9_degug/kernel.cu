
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "cuda_runtime.h"
#include <stdio.h>
#include "malloc.h"

#include <stdio.h>
const int N = 10;
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

int main()
{
	const int N = 10;
	int sizeOfMat = N * N * sizeof(int);

	int* in = (int*)malloc(sizeOfMat);
	int* out = (int*)malloc(sizeOfMat);
	int* gold = (int*)malloc(sizeOfMat);
	int temp = 0;
	for (int i = 0; i < N; i++)
	{
		for (int j = 0; j < N; j++) {
			in[i * N + j] = j;
			printf("%d,%d>",i, j);
			gold[j * N + i] = j;
			temp++;

		}
	}

	Print_Matrix(in);
}