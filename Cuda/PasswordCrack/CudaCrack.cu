#include <stdio.h>
#include <cuda_runtime_api.h>
#include <time.h>
/****************************************************************************
 * This is a program of password cracking of two alphabets and four digits using cuda. 
 * AV72, FT27, IR75, SC55 these passwords were provided and adding some digits to make four digits.
 * 

 To Compile:
    nvcc -o CudaCrack CudaCrack.cu 
  
  To run:
    ./CudaCrack 
     *****************************************************************************/



__device__ char password_text[4][7]={"AV7212","ES2112","GT5912","RB9612"};


__device__ void displayResult(char *password)
{
 printf("Password found is: %s\n",password);
}

__device__ void is_a_match(char *perform) {
  char *a = perform;
  char *b = perform;
  char *c = perform;
  char *d = perform;
  char *ps_1 = password_text[0];
  char *ps_2 = password_text[1];
  char *ps_3 = password_text[2];
  char *ps_4 = password_text[3];


  while(*a == *ps_1) { 
   if(*a == '\0') 
    {
        displayResult(perform);
      break;
    }

    a++;
    ps_1++;
  }
	
  while(*b == *ps_2) { 
   if(*b == '\0') 
    {
        displayResult(perform);
      break;
    }

    b++;
    ps_2++;
  }


  while(*c == *ps_3) { 
   if(*c == '\0') 
    {
	displayResult(perform);
      break;
    }

    c++;
    ps_3++;
  }


  while(*d == *ps_4) { 
   if(*d == '\0') 
    {
       displayResult(perform);
      break;
    }

    d++;
    ps_4++;
  }
  return;

}


__global__ void  kernel() {
char w,x,y,z;
  
  char password[7];
  password[6] = '\0';

int i = blockIdx.x+65;
int j = threadIdx.x+65;
char first_val = i; 
char second_val = j; 
    
password[0] = first_val;
password[1] = second_val;

	for(w='0'; w<='9'; w++){
	  for(x='0'; x<='9'; x++){
	   for(y='0'; y<='9'; y++){
	     for(z='0'; z<='9'; z++){
	        password[2] = w;
	        password[3] = x;
	        password[4] = y;
	        password[5] = z; 
	      is_a_match(password); 
	   }
	}
	}
	}

}

int time_difference(struct timespec *start, 
                    struct timespec *finish, 
                    long long int *difference) {
  long long int ds =  finish->tv_sec - start->tv_sec; 
  long long int dn =  finish->tv_nsec - start->tv_nsec; 

  if(dn < 0 ) {
    ds--;
    dn += 1000000000; 
  } 
  *difference = ds * 1000000000 + dn;
  return !(*difference > 0);
}


int main() {

  struct  timespec start, finish;
  long long int time_elapsed;
  clock_gettime(CLOCK_MONOTONIC, &start);

   dim3 block_Dim(26,1,1), thread_Dim(26,1,1);
  kernel <<<block_Dim,thread_Dim>>>();
  cudaThreadSynchronize();

  clock_gettime(CLOCK_MONOTONIC, &finish);
  time_difference(&start, &finish, &time_elapsed);
  printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, (time_elapsed/1.0e9)); 

  return 0;
}


