#include <stdio.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <cuda_runtime_api.h>
#include <errno.h>
#include <unistd.h>

/******************************************************************************
 * This program takes an initial estimate of m and c and finds the associated 
 * rms error. It is then as a base to generate and evaluate 8 new estimates, 
 * which are steps in different directions in m-c space. The best estimate is 
 * then used as the base for another iteration of "generate and evaluate". This 
 * continues until none of the new estimates are better than the base. This is
 * a gradient search for a minimum in mc-space.
 * 
 * To compile:
 *   nvcc -o a.cuda_linear a.cuda_linear.cu -lm
 * 
 * To run:
 *   ./a.cuda_linear
 * 
 * Prakash Dahal,      1828421
 *****************************************************************************/

typedef struct point_t {
  double x;
  double y;
} point_t;
 int total_number = 1000;
__device__ int d_total_number = 1000;

point_t data[] = {
  {74.69,99.28},{65.02,109.60},{77.71,123.74},{73.40,108.04},
  {69.29,111.21},{72.64,116.04},{65.55,130.71},{76.96,90.04},
  {76.23,123.13},{26.44,83.79},{97.66,140.19},{37.68,53.23},
  {82.23,125.32},{32.07,72.38},{95.22,150.88},{33.26,54.07},
  {77.46,114.15},{18.68,35.38},{ 5.10,45.57},{84.85,128.09},
  {57.02,106.30},{ 7.03,19.73},{85.94,137.30},{24.83,61.85},
  {26.37,71.04},{78.85,118.49},{77.44,120.70},{11.48,41.75},
  { 0.16,21.82},{36.66,71.84},{90.56,139.49},{37.25,45.15},
  {10.08,33.86},{61.56,98.22},{11.56,62.48},{38.74,56.21},
  {62.90,120.17},{96.42,144.85},{13.21,33.91},{ 3.39,29.39},
  {64.24,135.92},{56.52,94.48},{92.92,140.76},{14.60,48.13},
  {77.01,123.39},{23.85,57.67},{92.40,125.19},{85.05,133.37},
  {89.29,163.94},{57.47,92.44},{27.93,59.65},{70.50,117.63},
  {81.93,126.91},{11.80,38.22},{54.36,98.10},{21.55,51.14},
  {60.70,117.37},{37.09,79.12},{81.06,124.33},{96.19,137.42},
  {72.68,128.22},{ 1.58,35.82},{92.21,120.51},{33.85,69.42},
  {69.39,119.85},{31.89,71.67},{ 4.87,39.54},{89.43,137.22},
  { 0.41,21.09},{39.37,73.74},{46.65,94.79},{56.87,74.99},
  {55.37,94.32},{36.79,70.17},{66.31,88.97},{85.67,125.06},
  {55.54,89.60},{70.39,108.81},{72.83,118.44},{45.30,86.05},
  {49.81,93.20},{50.32,84.93},{15.60,55.39},{41.18,81.37},
  {97.31,157.08},{36.81,54.19},{82.31,120.22},{69.77,109.54},
  { 3.14,38.17},{75.96,117.00},{30.27,63.54},{28.32,61.85},
  {51.94,92.48},{32.56,73.39},{20.96,52.20},{83.23,147.97},
  {74.84,113.50},{ 4.16,31.21},{80.60,121.92},{10.50,25.21},
  {26.61,72.08},{55.35,83.19},{70.40,108.27},{20.93,58.63},
  {56.88,86.75},{41.23,66.87},{92.32,149.89},{89.84,132.61},
  {92.52,148.00},{68.33,116.82},{21.33,33.29},{73.17,131.35},
  {97.12,118.49},{45.50,81.04},{36.52,70.47},{38.26,60.20},
  {52.97,64.96},{93.32,151.52},{47.92,73.89},{56.97,91.02},
  {48.85,89.32},{96.90,138.08},{72.51,113.73},{53.47,97.44},
  {12.09,46.88},{95.97,152.92},{44.99,70.27},{59.39,109.78},
  {31.22,79.99},{40.25,46.61},{68.25,118.76},{99.54,152.24},
  {72.58,109.52},{72.71,138.39},{83.25,113.22},{10.67,34.02},
  {31.92,55.42},{ 1.57,42.77},{89.69,159.53},{54.87,103.36},
  {97.79,129.77},{87.94,137.51},{83.98,116.01},{ 7.47,54.29},
  {67.13,117.42},{92.65,141.49},{22.02,59.76},{65.29,102.56},
  {33.60,69.70},{50.08,89.18},{89.92,128.48},{14.73,36.30},
  {74.50,113.61},{90.20,131.51},{58.20,96.79},{35.20,74.72},
  {74.28,114.96},{95.28,146.19},{46.03,83.96},{ 7.89,32.97},
  {50.76,88.15},{84.00,128.85},{ 3.89,30.51},{67.27,93.75},
  {28.38,61.53},{94.97,153.14},{50.61,82.82},{49.23,112.06},
  {58.45,94.00},{65.22,108.26},{48.65,91.11},{40.31,81.09},
  {42.43,103.23},{57.16,84.21},{11.36,52.34},{80.02,129.26},
  {65.32,85.03},{23.97,53.17},{ 1.08,36.41},{ 1.00,14.45},
  {92.13,138.46},{93.40,142.58},{96.22,151.61},{73.56,106.58},
  {25.38,53.47},{39.97,65.53},{ 3.83,29.52},{13.17,39.35},
  { 6.20,36.18},{22.86,55.67},{67.41,101.87},{48.10,83.35},
  {95.66,139.32},{48.79,87.81},{77.79,122.37},{22.71,67.95},
  {80.15,128.19},{ 8.42,40.16},{24.45,62.07},{27.74,64.74},
  {95.75,166.13},{99.03,144.87},{77.43,119.95},{42.57,48.59},
  {12.30,33.07},{88.59,124.89},{99.11,136.16},{24.81,47.13},
  {12.91,49.83},{98.09,156.21},{69.28,113.98},{44.38,82.45},
  { 6.79,43.53},{ 3.11,27.56},{93.20,137.86},{15.62,39.22},
  {36.51,55.42},{16.78,60.21},{85.19,139.31},{95.51,139.49},
  {16.50,46.90},{64.12,101.80},{82.28,125.06},{19.86,54.81},
  {38.21,79.07},{67.14,100.72},{13.50,38.36},{83.81,126.24},
  {88.91,132.10},{85.41,133.46},{10.75,29.16},{15.79,47.25},
  {22.42,55.38},{10.83,59.58},{ 6.98,37.39},{68.18,122.61},
  {69.90,116.29},{65.05,112.64},{98.62,157.81},{63.08,97.52},
  {71.16,127.93},{79.76,125.58},{ 0.12,17.82},{18.17,36.38},
  {89.96,135.09},{48.33,96.65},{28.77,80.47},{73.25,118.98},
  {55.21,90.03},{88.15,140.00},{33.49,69.61},{64.85,100.75},
  {89.30,146.76},{72.02,113.06},{43.64,85.53},{75.32,135.24},
  {75.16,121.55},{69.62,109.46},{61.93,115.80},{41.06,85.42},
  {65.22,118.45},{14.38,26.70},{ 8.41,33.31},{50.48,83.26},
  {41.44,86.80},{90.01,131.83},{18.64,61.09},{60.97,96.68},
  {12.01,61.96},{74.06,127.67},{99.15,140.47},{46.74,87.86},
  {40.50,78.14},{36.18,82.02},{90.81,150.35},{20.81,35.24},
  {70.79,115.26},{47.94,83.17},{94.58,135.25},{17.29,57.99},
  {98.20,134.18},{66.62,90.57},{93.82,128.58},{ 0.25, 8.69},
  {30.33,77.18},{37.07,71.60},{61.26,84.55},{49.98,90.76},
  {15.03,53.07},{98.90,159.45},{51.38,88.46},{55.01,84.40},
  {36.52,75.78},{28.11,55.73},{ 3.60,24.91},{77.16,120.27},
  { 8.39,53.60},{78.36,133.61},{39.42,73.04},{27.72,36.17},
  {80.52,133.90},{44.38,91.52},{75.03,118.49},{75.29,121.04},
  {89.00,123.69},{32.66,54.95},{48.29,90.26},{41.25,78.69},
  {55.13,100.60},{ 1.80,45.60},{87.08,119.21},{ 5.01,18.10},
  { 1.65,23.93},{ 6.74,36.14},{20.52,58.27},{69.77,108.09},
  {81.57,117.81},{91.77,153.82},{ 6.39,38.05},{52.57,100.33},
  {34.64,56.71},{14.88,30.50},{68.34,102.94},{36.57,80.28},
  {48.44,95.18},{64.89,110.15},{58.29,89.11},{77.51,116.99},
  {58.96,86.34},{ 9.69,40.59},{49.19,79.13},{72.68,113.12},
  {11.98,47.68},{ 7.21,37.42},{28.31,57.46},{59.83,108.52},
  {51.82,99.71},{65.09,106.95},{65.64,110.71},{57.38,87.80},
  {56.78,113.06},{25.90,67.41},{27.19,57.71},{34.00,73.50},
  {51.02,83.26},{36.11,82.56},{32.32,67.92},{ 7.31,36.84},
  {17.91,52.11},{ 4.38,46.12},{77.87,122.46},{12.17,30.71},
  {23.65,58.55},{65.72,110.85},{71.40,126.86},{13.99,37.87},
  {95.58,153.06},{54.67,89.93},{83.39,124.01},{62.42,123.17},
  { 4.99,24.47},{ 2.71,19.68},{ 8.77,39.73},{ 2.57,15.85},
  {78.63,130.43},{25.41,79.97},{72.39,131.22},{47.52,93.49},
  {48.27,90.34},{13.01,43.74},{79.28,118.50},{90.67,147.84},
  {45.65,68.59},{43.79,74.57},{49.44,112.03},{15.13,46.30},
  {22.41,59.24},{26.62,77.53},{33.30,71.27},{42.20,87.87},
  {56.26,96.88},{22.75,48.65},{12.19,54.02},{96.31,148.09},
  {49.49,93.02},{90.94,135.03},{74.83,109.68},{55.89,103.40},
  {58.15,90.34},{ 9.23,53.49},{40.17,63.05},{47.24,84.24},
  {15.03,43.84},{44.37,78.56},{18.70,47.53},{97.69,142.36},
  {73.04,119.49},{26.89,68.28},{ 2.25,38.74},{94.99,136.29},
  {50.71,81.20},{85.08,127.34},{ 3.43,33.26},{ 5.63,35.76},
  { 8.89,47.84},{58.15,101.62},{40.69,79.61},{39.20,76.25},
  { 0.70,31.29},{56.92,96.95},{64.07,124.74},{14.39,55.04},
  {63.78,123.46},{61.68,116.45},{93.18,144.89},{41.85,94.00},
  {46.39,89.25},{ 0.91,46.07},{26.54,61.19},{60.38,88.52},
  {52.53,89.61},{60.70,99.98},{57.10,78.20},{26.56,62.26},
  {48.21,78.23},{91.46,145.79},{55.63,88.09},{57.70,109.49},
  {22.52,66.25},{33.80,55.53},{40.43,78.05},{36.60,71.29},
  {27.23,53.76},{26.41,51.51},{12.04,53.04},{82.14,137.19},
  {33.63,84.35},{90.87,163.40},{59.93,113.03},{42.96,77.05},
  {41.82,69.63},{82.76,107.06},{65.86,87.85},{14.71,31.91},
  {98.01,150.72},{60.93,103.18},{64.91,105.27},{44.90,75.91},
  {59.87,94.18},{86.72,119.77},{98.51,144.39},{19.16,57.45},
  {59.11,91.92},{77.39,117.35},{58.02,107.89},{33.20,58.50},
  {97.35,150.35},{48.37,77.44},{90.44,129.30},{58.90,94.13},
  {82.09,122.03},{97.30,153.52},{88.14,133.90},{98.39,163.50},
  {29.55,74.17},{12.38,29.74},{94.91,145.25},{67.94,100.02},
  {36.01,75.48},{84.02,122.91},{99.60,151.32},{13.34,66.21},
  {85.99,139.00},{94.33,155.46},{17.05,44.47},{77.16,139.93},
  {31.50,76.62},{75.26,118.68},{32.65,69.06},{94.91,140.10},
  {14.07,61.24},{33.22,71.91},{42.85,77.94},{52.02,93.02},
  {83.90,124.18},{41.81,66.21},{58.32,106.61},{25.29,60.73},
  {72.68,116.44},{18.79,40.93},{79.02,128.76},{55.11,92.21},
  {88.39,127.01},{95.51,141.52},{75.77,96.74},{72.72,134.84},
  {70.58,105.06},{ 7.73,39.27},{ 0.95,34.23},{63.64,102.87},
  {53.58,93.58},{73.86,116.90},{32.79,58.85},{32.40,56.91},
  {14.37,43.63},{83.41,123.34},{95.45,146.29},{33.07,69.84},
  {17.57,55.00},{40.96,61.08},{45.33,86.60},{23.68,52.60},
  {30.85,69.45},{26.87,47.86},{60.47,104.25},{ 7.48,19.75},
  { 8.33,29.09},{38.58,92.71},{93.34,146.96},{78.29,126.13},
  {23.76,54.52},{88.07,133.56},{17.23,41.06},{ 0.14,25.86},
  {47.03,77.49},{87.94,118.48},{78.20,126.19},{94.67,132.52},
  {74.85,114.96},{79.55,117.74},{27.50,39.71},{96.27,131.31},
  {94.77,138.99},{67.98,109.04},{88.38,135.16},{77.73,110.85},
  {44.09,85.25},{26.99,69.91},{21.75,42.50},{36.70,66.52},
  {92.67,128.08},{82.57,130.95},{35.05,65.65},{75.16,99.10},
  {10.46,32.88},{88.82,129.88},{26.10,68.24},{24.09,68.25},
  {95.93,162.47},{18.15,38.52},{70.79,114.03},{62.14,98.15},
  {46.68,80.03},{95.31,146.05},{43.03,86.98},{54.77,89.46},
  {31.64,76.97},{42.65,86.85},{55.30,64.28},{47.10,67.51},
  {99.31,132.71},{47.97,79.92},{91.13,128.29},{39.85,88.26},
  {91.19,137.63},{26.52,61.87},{ 9.11,41.90},{12.43,51.26},
  {56.88,112.39},{83.67,145.01},{60.61,109.35},{13.56,45.15},
  {80.86,126.98},{65.83,97.30},{ 2.84,30.93},{73.62,98.09},
  {83.68,128.90},{76.50,132.10},{60.94,103.13},{88.64,128.73},
  {92.06,143.68},{93.27,139.43},{ 0.94,34.20},{ 0.42,31.09},
  { 3.82,36.21},{ 3.97,37.36},{48.53,73.85},{27.08,77.42},
  {30.99,61.96},{79.44,130.52},{90.96,137.73},{98.00,148.23},
  {39.53,79.43},{36.57,74.64},{74.04,114.31},{60.66,96.60},
  {67.94,122.36},{37.19,75.08},{26.65,55.35},{65.93,114.37},
  {51.66,86.08},{38.51,79.60},{30.59,54.77},{42.50,60.80},
  {33.50,60.47},{99.06,147.95},{35.77,59.57},{92.83,131.99},
  { 1.48,20.59},{ 4.87,26.92},{77.99,124.66},{22.14,72.25},
  {78.80,128.05},{56.51,101.74},{ 8.81,43.60},{75.19,127.51},
  { 3.58,25.51},{63.78,116.14},{93.79,136.40},{27.34,67.43},
  { 0.85,28.46},{57.89,113.55},{99.49,152.75},{36.46,72.62},
  {50.85,97.67},{55.25,91.02},{58.13,84.12},{ 3.06,54.81},
  {27.70,44.87},{75.92,132.51},{43.35,71.13},{49.42,103.40},
  { 3.28,33.06},{43.22,100.55},{98.35,131.28},{17.83,36.08},
  {11.84,39.36},{46.06,86.08},{99.29,152.02},{80.46,117.92},
  {39.19,81.88},{15.28,39.29},{15.92,51.54},{97.35,132.27},
  {98.12,136.84},{75.82,116.79},{46.42,65.59},{65.87,91.44},
  { 4.85,41.45},{30.24,72.04},{99.09,142.49},{69.88,135.05},
  {54.25,93.14},{27.62,73.45},{37.94,77.36},{72.56,127.26},
  {88.00,138.34},{59.21,83.67},{26.65,54.52},{91.70,129.18},
  {28.48,65.59},{27.46,57.77},{46.10,78.31},{56.12,91.37},
  {22.70,63.12},{61.96,108.85},{56.67,98.09},{56.50,93.67},
  {54.62,88.31},{98.58,161.37},{ 2.00,22.02},{83.20,140.32},
  {64.26,120.04},{62.18,95.07},{51.20,91.82},{41.03,82.36},
  {52.10,96.14},{53.13,103.70},{41.47,80.93},{12.66,42.60},
  { 8.49,35.91},{45.46,90.00},{44.52,86.22},{65.02,118.45},
  {16.36,60.50},{48.49,93.66},{42.43,65.96},{73.10,127.57},
  {35.27,62.58},{26.65,41.31},{62.95,115.80},{20.23,52.22},
  {18.67,35.99},{33.48,81.19},{11.96,50.91},{41.99,77.89},
  {97.63,133.86},{81.54,123.52},{ 7.04,26.35},{41.78,88.24},
  {50.20,86.10},{19.86,51.20},{73.68,128.71},{33.41,62.58},
  {53.84,107.52},{20.05,47.10},{46.93,101.63},{81.76,101.34},
  {83.38,123.93},{73.56,136.67},{36.98,68.12},{59.68,100.10},
  {14.09,45.31},{46.77,78.62},{83.92,126.69},{32.83,66.23},
  { 2.77,23.79},{70.06,100.72},{69.99,111.15},{ 3.66,28.96},
  { 1.21,38.19},{ 8.39,49.38},{61.13,94.06},{72.20,117.27},
  {52.48,90.90},{27.16,70.44},{29.89,62.37},{83.04,151.23},
  {94.01,143.39},{69.23,110.62},{26.83,57.66},{65.68,127.32},
  {35.58,66.36},{69.41,119.16},{ 0.75,23.88},{ 2.52,22.34},
  {64.29,100.14},{75.15,129.98},{52.29,85.31},{71.05,107.92},
  {57.76,74.21},{ 0.93,47.59},{39.50,85.40},{ 1.43,39.23},
  {25.93,51.48},{81.25,119.14},{23.12,78.86},{74.97,132.25},
  {77.76,144.86},{27.30,64.65},{36.90,70.85},{46.93,83.87},
  {86.09,121.78},{48.74,84.18},{41.66,74.30},{28.52,69.77},
  { 0.24,30.96},{17.33,54.38},{83.08,131.16},{47.09,62.67},
  {17.93,29.63},{77.73,133.39},{38.63,80.93},{97.50,146.91},
  {76.82,102.18},{12.27,42.41},{84.15,133.76},{39.43,72.66},
  {84.51,129.01},{35.22,66.07},{69.66,113.62},{84.53,109.94},
  {83.05,118.61},{ 1.21,39.46},{98.00,163.57},{18.46,50.51},
  {15.48,35.13},{24.97,43.06},{21.44,47.02},{ 2.29,28.38},
  {23.85,52.64},{28.73,62.50},{ 6.49,30.72},{ 7.32,37.19},
  {19.22,40.89},{97.51,159.34},{ 1.33,44.79},{72.84,114.81},
  {29.88,82.48},{39.15,79.02},{16.53,78.10},{85.98,140.83},
  {99.45,132.63},{ 4.22,33.47},{80.84,116.31},{75.58,122.60},
  {91.46,146.13},{28.96,57.81},{30.66,73.24},{20.01,27.47},
  {23.10,50.98},{59.72,117.54},{82.86,124.74},{45.46,82.74},
  {96.35,136.02},{29.13,66.13},{65.12,103.13},{64.62,103.29},
  {26.75,47.57},{ 2.11,40.30},{30.54,52.42},{62.89,110.09},
  {26.08,66.67},{75.01,111.23},{89.58,133.39},{70.49,121.93},
  {47.38,72.36},{70.53,127.11},{33.27,66.63},{78.84,116.77},
  {93.13,150.29},{40.12,71.32},{ 6.59,20.65},{43.11,87.68},
  {49.67,90.10},{64.73,107.17},{84.82,133.27},{ 2.02,20.47},
  {20.81,56.26},{64.28,92.45},{14.33,52.13},{72.60,115.41},
  {59.45,113.71},{21.29,51.55},{40.79,74.64},{51.99,88.13},
  {34.84,62.22},{37.94,85.39},{56.49,99.77},{85.21,118.40},
  {44.68,72.29},{92.24,130.62},{38.70,68.49},{52.12,108.86},
  {42.85,88.62},{96.51,156.66},{90.22,116.81},{94.31,128.10},
  {97.83,134.43},{22.14,56.52},{75.98,126.58},{52.69,87.87},
  {36.08,75.01},{ 9.30,38.95},{96.04,144.27},{ 4.28,15.96},
  {49.46,86.71},{95.06,130.37},{ 9.40,57.02},{54.86,93.86},
  {23.25,46.79},{33.40,62.80},{50.05,93.80},{45.01,91.42},
  {57.29,78.47},{50.86,89.72},{88.97,131.59},{ 1.27,32.87},
  { 0.08,13.72},{45.70,87.42},{13.49,56.28},{13.46,39.78},
  {82.56,120.89},{19.46,64.34},{74.80,106.27},{39.64,83.91},
  {55.61,99.96},{64.19,101.84},{20.01,30.05},{95.96,157.87},
  {77.68,125.56},{ 9.43,32.49},{67.42,113.54},{70.34,119.49},
  {54.92,86.36},{43.82,82.81},{58.03,92.05},{ 3.52,47.41},
  {28.76,72.01},{ 0.90,28.46},{33.88,81.46},{10.32,50.95},
  {18.07,52.16},{78.14,128.22},{67.55,115.51},{86.26,148.55},
  {63.82,97.64},{22.44,36.19},{41.61,85.92},{ 2.17,40.45},
  { 6.75,44.60},{14.80,39.59},{38.43,74.78},{ 4.97,40.85},
  { 6.66,30.95},{95.03,151.01},{48.12,106.01},{ 7.32,41.29},
  { 1.09,29.82},{ 9.95,23.19},{10.72,50.40},{ 7.63,37.42},
  {44.38,82.28},{53.06,80.51},{15.66,47.85},{58.95,100.34},
  {56.06,89.40},{89.23,160.98},{79.23,130.36},{10.02,30.23},
  {28.83,66.80},{13.42,52.18},{46.06,72.92},{52.80,79.93},
  {28.37,46.66},{82.70,115.13},{51.29,71.06},{32.03,70.39},
  {66.15,125.25},{14.27,37.30},{14.67,40.04},{29.36,63.26},
  {86.82,138.78},{ 4.32,32.28},{90.23,146.03},{57.25,100.84},
  {40.86,76.28},{34.07,82.24},{20.77,44.97},{12.07,62.29},
  {51.72,75.16},{53.42,91.48},{65.42,96.53},{55.56,92.54},
  {42.14,73.30},{37.03,70.93},{57.73,88.76},{10.67,16.23},
  {41.97,90.16},{52.09,81.53},{81.72,134.96},{22.46,65.59},
  {49.52,75.37},{65.58,105.40},{23.06,60.99},{94.43,153.42},
  {96.67,139.99},{99.29,149.64},{11.25,52.88},{72.73,108.55},
  {33.94,60.67},{14.36,36.54},{12.40,58.07},{20.05,36.96},
  {80.29,123.98},{50.77,81.95},{63.59,88.37},{ 3.75,23.78},
  {99.83,145.11},{80.97,113.92},{ 5.10,45.95},{67.46,109.80},
  {21.39,52.17},{27.40,61.48},{77.10,119.21},{62.12,95.79},
  {96.80,161.28},{20.45,56.75},{84.53,118.14},{60.44,96.82},
  {88.77,149.13},{54.53,97.21},{79.67,124.39},{40.23,62.04},
  {74.40,112.70},{95.72,143.71},{71.21,127.89},{23.65,91.26},
  {43.20,76.40},{31.93,46.92},{40.11,53.23},{80.73,113.03},
  { 8.70,39.89},{32.67,58.40},{65.87,108.27},{85.01,132.20},
  {85.42,123.88},{42.46,75.88},{79.36,124.93},{86.33,138.60}
};
double residual_error(double x, double y, double m, double c) {
  double e = (m * x) + c - y;
  return e * e;
}

__device__ double d_residual_error(double x, double y, double m, double c) {
  double e = (m * x) + c - y;
  return e * e;
}

double rms_error(double m, double c) {
  int i;
  double mean;
  double error_sum = 0;
  
  for(i=0; i<total_number; i++) {
    error_sum += residual_error(data[i].x, data[i].y, m, c);
  }
  
  mean = error_sum / total_number;
  
  return sqrt(mean);
}

__global__ void d_rms_error(double *m, double *c, double *error_sum_arr, point_t *d_data) {
	/*kernel
		Calculate the current index by using:
		- The thread id
		- The block id
		- The number of threads per block
	*/
	int i = threadIdx.x + blockIdx.x * blockDim.x;

	//Work out the error sum 1000 times and store them in an array.
  error_sum_arr[i] = d_residual_error(d_data[i].x, d_data[i].y, *m, *c);
}

int time_difference(struct timespec *start, struct timespec *finish, 
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
  int i;
  double bm = 1.3;
  double bc = 10;
  double be;
  double dm[8];
  double dc[8];
  double e[8];
  double step = 0.01;
  double best_error = 999999999;
  int best_error_i;
  int minimum_found = 0;
  
  double om[] = {0,1,1, 1, 0,-1,-1,-1};
  double oc[] = {1,1,0,-1,-1,-1, 0, 1};

	struct timespec start, finish;   
  long long int time_elapsed;

	//Get the system time before we begin the linear regression.
  clock_gettime(CLOCK_MONOTONIC, &start);

	cudaError_t error;

	//Device variables
	double *device_dm;
  double *device_dc;
	double *d_error_sum_arr;
	point_t *d_data;
	
  be = rms_error(bm, bc);

	//Allocate memory for device_dm
	error = cudaMalloc(&device_dm, (sizeof(double) * 8));
 	if(error){
   	fprintf(stderr, "cudaMalloc on device_dm returned %d %s\n", error,
    	cudaGetErrorString(error));
   	exit(1);
 	}
	
	//Allocate memory for device_dc
	error = cudaMalloc(&device_dc, (sizeof(double) * 8));
 	if(error){
   	fprintf(stderr, "cudaMalloc on device_dc returned %d %s\n", error,
  	  cudaGetErrorString(error));
   	exit(1);
 	}
	
	//Allocate memory for d_error_sum_arr
	error = cudaMalloc(&d_error_sum_arr, (sizeof(double) * 1000));
 	if(error){
   	fprintf(stderr, "cudaMalloc on d_error_sum_arr returned %d %s\n", error,
   	  cudaGetErrorString(error));
   	exit(1);
 	}

	//Allocate memory for d_data
	error = cudaMalloc(&d_data, sizeof(data));
 	if(error){
   	fprintf(stderr, "cudaMalloc on d_data returned %d %s\n", error,
   	  cudaGetErrorString(error));
   	exit(1);
 	}

  while(!minimum_found) {
    for(i=0;i<8;i++) {
      dm[i] = bm + (om[i] * step);
      dc[i] = bc + (oc[i] * step);    
    }

		//Copy memory for dm to device_dm
  	error = cudaMemcpy(device_dm, dm, (sizeof(double) * 8), cudaMemcpyHostToDevice);  
  	if(error){
    	fprintf(stderr, "cudaMemcpy to device_dm returned %d %s\n", error,
      cudaGetErrorString(error));
  	}

		//Copy memory for dc to device_dc
  	error = cudaMemcpy(device_dc, dc, (sizeof(double) * 8), cudaMemcpyHostToDevice);  
  	if(error){
    	fprintf(stderr, "cudaMemcpy to device_dc returned %d %s\n", error,
      cudaGetErrorString(error));
  	}

		//Copy memory for data to d_data
  	error = cudaMemcpy(d_data, data, sizeof(data), cudaMemcpyHostToDevice);  
  	if(error){
    	fprintf(stderr, "cudaMemcpy to d_data returned %d %s\n", error,
      cudaGetErrorString(error));
  	}
		
    for(i=0;i<8;i++) {
			//Host variable storing the array returned from the kernel function.
			double h_error_sum_arr[1000];
			
			//Stores the total sum of the values from the error sum array.
			double error_sum_total;

			//Stores the mean of the total sum of the error sums.
			double error_sum_mean;

			//Call the rms_error function using 100 blocks and 10 threads.
			dim3 block_Dim(100,1,1), thread_Dim(10,1,1);
			d_rms_error <<<block_Dim,thread_Dim>>>(&device_dm[i], &device_dc[i], d_error_sum_arr, d_data);
			cudaThreadSynchronize();

			//Copy memory for d_error_sum_arr
		  error = cudaMemcpy(&h_error_sum_arr, d_error_sum_arr, (sizeof(double) * 1000), cudaMemcpyDeviceToHost);  
		  if(error){
	    fprintf(stderr, "cudaMemcpy to error_sum returned %d %s\n", error,
	      cudaGetErrorString(error));
		  }

			//Loop through the error sum array returned from the kernel function
			for(int j=0; j<total_number; j++) {
				//Add each error sum to the error sum total.
    		error_sum_total += h_error_sum_arr[j];
  		}

			//Calculate the mean for the error sum.
			error_sum_mean = error_sum_total / total_number;

			//Calculate the square root for the error sum mean.
			e[i] = sqrt(error_sum_mean);

      if(e[i] < best_error) {
        best_error = e[i];
        best_error_i = i;
      }

			//Reset the error sum total.
			error_sum_total = 0;
    }

    //printf("best m,c is %lf,%lf with error %lf in direction %d\n", 
      //dm[best_error_i], dc[best_error_i], best_error, best_error_i);

    if(best_error < be) {
      be = best_error;
      bm = dm[best_error_i];
      bc = dc[best_error_i];
    } else {
      minimum_found = 1;
    }
  }

	//Free memory for device_dm
	error = cudaFree(device_dm);
	if(error){
		fprintf(stderr, "cudaFree on device_dm returned %d %s\n", error,
	  	cudaGetErrorString(error));
		exit(1);
	}
	
	//Free memory for device_dc
	error = cudaFree(device_dc);
	if(error){
		fprintf(stderr, "cudaFree on device_dc returned %d %s\n", error,
			cudaGetErrorString(error));
		exit(1);
	}

	//Free memory for d_data
	error = cudaFree(d_data);
	if(error){
		fprintf(stderr, "cudaFree on d_data returned %d %s\n", error,
	  	cudaGetErrorString(error));
	 	exit(1);
	}
		
	//Free memory for d_error_sum_arr
	error = cudaFree(d_error_sum_arr);
	if(error){
		fprintf(stderr, "cudaFree on d_error_sum_arr returned %d %s\n", error,
	  	cudaGetErrorString(error));
	 	exit(1);
	}

  printf("minimum m,c is %lf,%lf with error %lf\n", bm, bc, be);

	//Get the system time after we have run the linear regression function.
	clock_gettime(CLOCK_MONOTONIC, &finish);

	//Calculate the time spent between the start time and end time.
  time_difference(&start, &finish, &time_elapsed);

	//Output the time spent running the program.
  printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, 
         (time_elapsed/1.0e9));
	
  return 0;
}
