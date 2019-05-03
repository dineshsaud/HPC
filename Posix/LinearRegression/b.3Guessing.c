 /* The variable names and the function names of this program is same as provided by the university.
The added variable and function are the only changes made to this program.
 * 
 * To compile:
 *   cc -o Q1.3_b Q1.3_b_Guess2.c
 * 
 * To run and direct the output into a file:
 *   ./Q1.3_b
 *****************************************************************************/


#include <stdio.h>
int main(int argc, char **argv) {
  int i;
  double m;
  double c;
  double x;
  double y;
  
  if(argc != 3) {
    fprintf(stderr, "specify a slope and intercept\n");
    return 1;
  }

  sscanf(argv[1], "%lf", &m);
  sscanf(argv[2], "%lf", &c);

  printf("  M,  C\n");
  for(i=0; i<100; i++) {
    x = i;
    y = (m * x) + c;
    printf("%0.2lf,%0.2lf\n", x, y);
  }
  return 0;
}

