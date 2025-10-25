#include <stdio.h>
#include <cuda_runtime.h> // <-- ADDED: Necessary CUDA header



__global__ void rgba_to_greyscale(const uchar4* const rgbaImage,
                                  unsigned char* const greyImage,
                                  int numRows, int numCols)
{
    // Fill in the kernel to convert from colour to greyscale
    // The mapping from components of a uchar4 to RGBA is:
    // .x -> R; .y -> G; .z -> B; .w -> A
    //
    // The output (greyImage) at each pixel should be the result of
    // applying the formula: output = .299f * R + .587f * G + .114f * B;
    // Note: We will be ignoring the alpha channel for this conversation

    // First create a mapping from 2D block and grid locations
    // to an absolute 2D location in the image, then use that to 
    // calculate a 1D offset

    // 1. Calculate absolute 2D column and row index
    // gridDim.x is the number of blocks in the X dimension
    // blockIdx.x is the current block's index in the X dimension
    // blockDim.x is the number of threads per block in the X dimension
    // threadIdx.x is the current thread's index in the block's X dimension

    const int col = blockIdx.x * blockDim.x + threadIdx.x;
    const int row = blockIdx.y * blockDim.y + threadIdx.y;

    // 2. Check if the thread is within the image bounds
    if (col < numCols && row < numRows)
    {
        // 3. Calculate 1D offset
        const int index = row * numCols + col;

        // 4. Load the RGBA pixel value
        const uchar4 rgba = rgbaImage[index];

        // 5. Apply the greyscale conversion formula
        // Use float for the calculation to maintain precision, then cast to unsigned char
        // .x -> R; .y -> G; .z -> B
        const float grey_float = 
            0.299f * rgba.x +  // Red component
            0.587f * rgba.y +  // Green component
            0.114f * rgba.z;   // Blue component

        // 6. Store the result in the greyscale image array
        greyImage[index] = (unsigned char)grey_float;
    }
}

void my_rgba_to_greyscale(const uchar4 * const h_rgbaImage, uchar4 * const d_rgbaImage,
                          unsigned char* const d_greyImage, size_t numRows, size_t numCols)
{
    // You must fill in the correct sizes for the blockSize and gridSize

    // A common practice is to use a 2D block size, e.g., 16x16, for image processing.
    // This allows for efficient access to surrounding pixels (though not used here)
    // and good occupancy.
    const int THREADS_PER_BLOCK_X = 16;
    const int THREADS_PER_BLOCK_Y = 16;

    // blockSize: Defines the dimensions of the thread block (e.g., 16 threads in X, 16 in Y)
    const dim3 blockSize(THREADS_PER_BLOCK_X, THREADS_PER_BLOCK_Y); 

    // gridSize: Defines the dimensions of the grid of blocks
    // This is calculated by dividing the total number of pixels by the threads per block, 
    // and using the ceiling function (integer division + 1 if there's a remainder)
    
    // Grid size in X (columns)
    const int gridX = (numCols + blockSize.x - 1) / blockSize.x;
    // Grid size in Y (rows)
    const int gridY = (numRows + blockSize.y - 1) / blockSize.y;
    
    const dim3 gridSize(gridX, gridY);

    // Launch the kernel
    rgba_to_greyscale<<<gridSize, blockSize>>>(d_rgbaImage, d_greyImage, (int)numRows, (int)numCols);

    
}