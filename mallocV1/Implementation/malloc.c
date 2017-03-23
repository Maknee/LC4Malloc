/* LC4_DMMGR (Dynamic memory manager for PennSim)
 * malloc.c: Made by Henry Zhu | Modified @  3/21/2017
 * Version 1.0
 * First Release
 * First fit Implementation
 * Malloc O(n) - Has to iterate through most, if not all blocks in order to find a free block
 * Free O(1) - unlinks the current chunk from the set of chunks in use
 * Space - 4 words for each chunk. 
 */

/************************************************
 *  References/Sources
 *  Bin implementation - https://github.com/iamnotnader/memory_heap_manager
 *  (Abstractly) Different implementations of heap - https://www.cs.princeton.edu/courses/archive/fall16/cos217/lectures/20_DynamicMemory.pdf
 *  First fit implementation of malloc - http://www.inf.udec.cl/~leo/Malloc_tutorial.pdf
 *  Understanding how glibc (dlmalloc) was implemented - https://sploitfun.wordpress.com/2015/02/10/understanding-glibc-malloc/
 ***********************************************/


#include "lc4libc.h"

// ############################ DEBUGGING #################################

#ifdef _DEBUG

/************************************************
 *  Printnum - 
 *  Prints out the value on the lc4
 ***********************************************/

void printnum (int n) {
  int abs_n;
  char str[10], *ptr;

  // Corner case (n == 0)
  if (n == 0) {
    lc4_puts ((lc4uint*)"0");
    return;
  }
 
  abs_n = (n < 0) ? -n : n;

  // Corner case (n == -32768) no corresponding +ve value
  if (abs_n < 0) {
    lc4_puts ((lc4uint*)"-32768");
    return;
  }

  ptr = str + 10; // beyond last character in string

  *(--ptr) = 0; // null termination

  while (abs_n) {
    *(--ptr) = (abs_n % 10) + 48; // generate ascii code for digit
    abs_n /= 10;
  }

  // Handle -ve numbers by adding - sign
  if (n < 0) *(--ptr) = '-';

  lc4_puts((lc4uint*)ptr);
}

/************************************************
 *  endl - 
 *  Ends a line by printing a newline character
 ***********************************************/
void endl () {
    lc4_puts((lc4uint*)"\n");
}

void assertGTZero(int val, char* message) {
    if(val < 0)
    {
        lc4_puts((lc4uint*)message);
        lc4_halt();
    }
}

void assertEQZero(int val, char* message) {
    if(val != 0)
    {
        lc4_puts((lc4uint*)message);
        lc4_halt();
    }
}

void assertLTZero(int val, char* message) {
    if(val > 0)
    {
        lc4_puts((lc4uint*)message);
        lc4_halt();
    }
}

#endif

/***************************************************************
 *  Defines - 
 *  USER_HEAP_ADDR     | Start of the heap
 *  USER_HEAP_MAX_SIZE | The size of the heap
 *  SET_IN_USE_BIT(x)  | Sets the MSB - indicates that the chunk is in use
 *  UNSET_IN_USE_BIT(x)| Unsets the MSB - indicates that the chunk is not in use
 *  CHECK_IN_USE_BIT(X)| Checks if chunk is in use - returns true if chunk is in use
 **************************************************************/

#define USER_HEAP_ADDR          0x4000
#define USER_HEAP_MAX_SIZE      0x3000

#define SET_IN_USE_BIT(x)       (x | 0x8000)
#define UNSET_IN_USE_BIT(x)     (x & 0x7FFF)
#define CHECK_IN_USE_BIT(x)     ((x & 0x8000) != 0)

/***************************************************************
 *  Typedefs - 
 *  Want to make sure everything is aligned properly (1 WORD)
 **************************************************************/

typedef int INTERNAL_SIZE_T;
typedef INTERNAL_SIZE_T size_t;

/***************************************************************
 *  MIMIC OS CALLS
 **************************************************************/

//Break is "edge" between mapped memory and unmapped memory. 
static void* breakAddr;

/***************************************************************
 *  sbrk - Mimics OS call and moves break (Maps more/less memory to the heap)
 *  Parameters: 
 *  INTERNAL_SIZE_T size - takes in a size to increase/decrease the break by
 *  
 *  Return Value:
 *  INTERNAL_SIZE_T - a pointer to the new break or SBRK_FAILURE
 *
 *  Implementation details:
 *  1) updates the break's location by (size)
 *  2) checks if the new break is less than the start of the heap (return SBRK_FAILURE)
 *  3) checks if the new break is greater than the start of the heap (return SBRK_FAILURE)
 *  4) returns the new break
 **************************************************************/

#define SBRK_FAILURE               -1;

INTERNAL_SIZE_T sbrk(INTERNAL_SIZE_T size)
{   
    //Update break
    breakAddr = (void*)((int)breakAddr + size);

    //Check if new break is still in range of heap
    if((int)breakAddr < USER_HEAP_ADDR)
    {
        lc4_puts((lc4uint*)"Break cannot be placed before the heap (break < 0x4000)");
        return SBRK_FAILURE;
    }

    //Check if the break goes out of heap
    if((int)breakAddr >= USER_HEAP_ADDR + USER_HEAP_MAX_SIZE)
    {
        lc4_puts((lc4uint*)"Break cannot be placed after the heap (break < 0x3000)");
        return SBRK_FAILURE;
    }

    return (INTERNAL_SIZE_T)breakAddr;
}

/***************************************************************
 *  Chunk struct - definition of a chunk
 *  currentSize - the size of the chunk (the amount of memory the user has requested)
 *  (currentSize's MSB will be set if the chunk is in use or not set if the chunk is free)
 *  prevPtr - pointer to the previous chunk
 *  fowardPtr - pointer to the next chunk
 *  corruptionCheckPtr - pointer to itself (checks if the chunk has not been over written by overflow)
 **************************************************************/

typedef struct chunk{
    //Bit 15 - is prev set
    INTERNAL_SIZE_T currentSize;
    struct chunk* prevPtr;
    struct chunk* fowardPtr;
    struct chunk* corruptionCheckPtr;
    //Start of data (this variable does not matter - only for readability since data's size will be based on currentSize)
    size_t data;
}Chunk;

//Make sure that the chunk size is 4 (this replaces sizeof() operator)
//Consist of 4 words - currentSize | prevPtr | fowardPtr | corruptionCheckPtr
#define CHUNK_SIZE 0x0004
//Get the malloc pointer (what the user uses)
#define GET_DATA_POINTER(x)     (x + CHUNK_SIZE)
//Get the data structure pointer (the start of the struct chunk)
#define GET_STRUCT_POINTER(x)   (x - CHUNK_SIZE)

typedef struct chunk* chunkptr;

/***************************************************************
 *  Arena struct
 *  magic - Just some magic number (Why not)
 *  flags - Not in use right now. Might be useful later
 *  topChunkPtr - pointer to the top chunk
 *  (The top chunk borders the break. It's variables have a different meaning than a regular chunk)
 *  topChunk's currentSize = amount of space left in the heap (unmapped)
 *  topChunk's fowardPtr = always NULL
 *  topChunk's prevPtr = previous chunk
 *  topChunk's corruptionCheckPtr = point to itself (check if heap has been corrupted)
 **************************************************************/

typedef struct arena{
    int magic;
    int flags;
    chunkptr topChunkPtr;
}Arena;

//Global variable for the main_arena. Pennsim is not multithreaded, so we only have the main arena
static struct arena main_arena = {0x485A, 0x0001, NULL};

/***************************************************************
 *  initialize_heap - initializes the heap (called at start of OS_START) (Implemented only because lcc doesn't like to initialize variables to be > 0x0100)
 *  Parameters: 
 *  none
 *  
 *  Return Value:
 *  void
 *
 *  Implementation details:
 *  1) initializes the break to the start of the heap's address
 *  2) initializes the top chunk
 **************************************************************/

void intialize_heap()
{
    //Initialize break to the start of the heap
    breakAddr = (void*)((unsigned short)USER_HEAP_ADDR);

    main_arena.topChunkPtr = (chunkptr)((unsigned short)USER_HEAP_ADDR);
    main_arena.topChunkPtr->currentSize = UNSET_IN_USE_BIT(0);
    main_arena.topChunkPtr->fowardPtr = NULL;
    main_arena.topChunkPtr->prevPtr = NULL;
    //We are going check corruptionCheckPtr to see if the heap is initalized later with the first call to malloc
    main_arena.topChunkPtr->corruptionCheckPtr = NULL;
}

/***************************************************************
 *  find_block - Starts the first chunk and iterates through all the chunks (free or not free) 
 *               and tries to find a free block that can hold the requested size
 *               O(n) -> might need to iterate through every block
 *  Parameters: 
 *  chunkptr* previousChunk - a pointer to the previous chunk in the iteration 
 *                            (necessary because if we cannot find a chunk that will fit,
 *                             we will need the top chunk's prevPtr to point at the last chunk)
 *  size_t size - takes in a chunk size to find
 *  
 *  Return Value:
 *  chunkptr - a pointer to a free block or NULL if not found
 *
 *  Implementation details:
 *  1) initializes a chunkptr that points at the first chunk. 
 *  2) checks if the chunkptr has found a in use chunk or the chunk's size is less than the requested (size) 
 *      1) update the previous chunk
 *      2) update the ptr to point to the next chunk
 *  3) returns the pointer to a free chunk or NULL
 **************************************************************/

chunkptr find_block(chunkptr* previousChunk, size_t size)
{
    //return found chunk if there is a free chunk or NULL if no blocks can be found
    chunkptr foundChunk = (chunkptr)((unsigned short)USER_HEAP_ADDR);

    //will exit this loop if chunk is found. 
    //First checks if foundChunk is valid (NULL if reaches top chunk's foward ptr)
    //and then if its IN_USE_BIT is set (block is in use)
    //or its current size < requested size (requested size doesn't fit block)
    //if, so move on to the next chunk
    while(foundChunk && (CHECK_IN_USE_BIT(foundChunk->currentSize) || foundChunk->currentSize < size))
    {
        *previousChunk = foundChunk;
        foundChunk = foundChunk->fowardPtr;
    }
    //FoundChunk will be NULL if we reach the topChunk (topChunk's forwardptr is NULL)
    //else it will be whatever chunk was found
    return foundChunk;
}

/***************************************************************
 *  extend_heap - requests more mapped memory from the OS (sbrk call) for a new chunk
 *  Parameters: 
 *  chunkptr* previousChunk - a pointer to the last chunk before the top chunk
 *                            (we will need the top chunk's prevPtr to point at the last chunk)
 *  size_t size - takes in a chunk size to allocate
 *  
 *  Return Value:
 *  chunkptr - a pointer to last chunk before the top chunk or NULL if sbrk has failed
 *
 *  Implementation details:
 *  1) initializes a chunkptr that points at the top chunk
 *  2) call sbrk to allocate a new chunk (for the new top chunk) + the requested (size)
 *      1) if failed, return NULL
 *  3) initialize a new chunk that takes in the requested (size)
 *      1)currentSize = (size), prevPtr = previousChunk (if possible), fowardPtr = topChunk, corruptionCheckPtr = returnChunk
 *  4) initialize the new topChunk
 *      1)currentSize = End of heap (0x7000) - top chunk's memory location - top chunk size (CHUNK_SIZE), prevPtr = returnChunk, fowardPtr = NULL, corruptionCheckPtr = topChunk
 *  5) returns the pointer to the last chunk before the top chunk or NULL if sbrk has failed
 **************************************************************/

chunkptr extend_heap(chunkptr previousChunk, size_t size)
{
    //Make a pointer to the top chunk (This will be the new chunk)
    chunkptr returnChunk = main_arena.topChunkPtr;

    //Call sbrk to extend the heap
    //We want to allocate the size required and another chunk struct
    //for the top chunk
    //(returnChunk || size || top chunk)

    size_t requestedSbrkSize;

    //Initially if malloc was never called
    //Requested size = size + offset from the start to get to the data section 
    //+ amount of memory needed for a chunk 
    //else just offset by size + size of chunk struct
    if(main_arena.topChunkPtr->prevPtr == NULL)
        requestedSbrkSize = size + 2 * CHUNK_SIZE;
    else
        requestedSbrkSize = size + CHUNK_SIZE;

    main_arena.topChunkPtr = (chunkptr)sbrk(requestedSbrkSize);

    //Lcc giving errors if I use SBRK_FAILURE instead of -1... :(
    if(main_arena.topChunkPtr == (chunkptr)((unsigned short)-1))
        return NULL;

    //make sure that the top chunk is correctly offseted
    main_arena.topChunkPtr = (chunkptr)((size_t)main_arena.topChunkPtr - CHUNK_SIZE);

    //modify the returnChunk's foward pointer to point to the top chunk 
    //and set its size to the parameter size 
    returnChunk->currentSize = SET_IN_USE_BIT(size);
    //Check if this was the first malloc
    if((size_t)returnChunk == USER_HEAP_ADDR)
    {
        returnChunk->prevPtr = NULL;
    }
    else
    {
        //Update the current chunk to point at the previous chunk
        if(previousChunk)
            returnChunk->prevPtr = previousChunk;
    }

    returnChunk->fowardPtr = main_arena.topChunkPtr;
    returnChunk->corruptionCheckPtr = returnChunk;

    //update the topChunkPtr's member variables
    main_arena.topChunkPtr->currentSize = USER_HEAP_ADDR + USER_HEAP_MAX_SIZE - (size_t)main_arena.topChunkPtr - CHUNK_SIZE;
    main_arena.topChunkPtr->prevPtr = returnChunk;
    main_arena.topChunkPtr->fowardPtr = NULL;
    main_arena.topChunkPtr->corruptionCheckPtr = main_arena.topChunkPtr;

    //Update the previous to point to the current chunk (Is this necessary?)
    if(previousChunk)
        previousChunk->fowardPtr = returnChunk;

    return returnChunk;
}

/***************************************************************
 *  shrink_heap - requests the OS to take back mapped memory (sbrk call) to coalesce the previous chunk before the top chunk and the top chunk
 *  Parameters: 
 *  chunkptr* previousChunk - a pointer to the last chunk before the top chunk
 *                            (we will need to merge the top chunk)
 *  size_t size - takes in a chunk size to find
 *  
 *  Return Value:
 *  chunkptr - a pointer to top chunk or NULL if sbrk call failed.
 *
 *  Implementation details:
 *  1) initializes a chunkptr that points at the top chunk
 *  2) call sbrk to take back a chunk
 *      1) if failed, return NULL
 *  3) initialize a new chunk that is the new top chunk
 *  4) copy the old top chunk into the new top chunk
 *  5) returns the pointer to the new top chunk
 **************************************************************/

chunkptr shrink_heap(chunkptr previousChunk, size_t size)
{
    //make a copy of the top chunk
    struct chunk copyOfTopChunk = *main_arena.topChunkPtr;

    //Ask the OS to take back some memory
    main_arena.topChunkPtr = (chunkptr)sbrk(-size);

    //Lcc giving errors if I use SBRK_FAILURE instead of -1... :(
    if(main_arena.topChunkPtr == (chunkptr)((unsigned short)-1))
        return NULL;

    //make sure that the top chunk is correctly offseted (two chunk sizes one for current top chunk and one for the chunk to be overwritten as top chunk)
    main_arena.topChunkPtr = (chunkptr)((size_t)main_arena.topChunkPtr - CHUNK_SIZE - CHUNK_SIZE);

    //copy the original contents into top chunk
    main_arena.topChunkPtr->currentSize = copyOfTopChunk.currentSize;
    main_arena.topChunkPtr->prevPtr = previousChunk;
    main_arena.topChunkPtr->fowardPtr = copyOfTopChunk.fowardPtr;
    main_arena.topChunkPtr->corruptionCheckPtr = copyOfTopChunk.corruptionCheckPtr;

    //make sure that the previous chunk points at top chunk
    previousChunk->fowardPtr = main_arena.topChunkPtr;

    //IMPLEMENT MERGING IF THE PREVIOUS CHUNK IS FREED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    return main_arena.topChunkPtr;
}

/***************************************************************
 *  split_chunk - splits an (in use) allocated chunk into two (one is in use and one that is free) -> leads to fragmentation
 *  Parameters: 
 *  chunkptr* chunkToSplit - a pointer to the chunk to split
 *  size_t size - takes in the size that we want to chunk to be. The remaining of the chunkToSplit's currentSize will be given to the remaining chunk
 *  
 *  Return Value:
 *  none
 *
 *  Implementation details:
 *  1) initializes a chunkptr will point at the remaining chunk
 *  2) The remaining chunk will be offseted at chunkToSplit + size + size of chunk struct (CHUNK_SIZE)
 *  3) initialize the remaining chunk
 *      1) currentSize = chunkToSplit->currentSize - (size) - size of chunk struct(CHUNK_SIZE), prevPtr = previousChunk (if possible), fowardPtr = topChunk, corruptionCheckPtr = returnChunk
 *  4) set the next chunk's prevPtr to point at the remaining chunk
 *  5) set the chunkToSplit's forwardPtr to point at the remaining chunk
 *  6) update the chunkToSplit's currentSize to the requested (size)
 **************************************************************/

void split_chunk(chunkptr chunkToSplit, size_t size)
{
    //Visual of splitting chunk
    //chunkToSplit | data                         |
    //chunkToSplit | data | remainingChunk | data |

    //The remaining chunk that is split in half
    chunkptr remainingChunk;

    //Set the remaining chunk to be after the chunk to be allocated
    //lcc is complaining about DEFINE
    size_t newChunkMemLocation = (size_t)chunkToSplit + size;
    newChunkMemLocation += CHUNK_SIZE;
    remainingChunk = (chunkptr)newChunkMemLocation;

    //Now modify the remaining chunk
    //Set the remainingChunk's foward ptr to point to the next chunk
    remainingChunk->fowardPtr = chunkToSplit->fowardPtr;
    //Set the remainingChunk's previous ptr to point to the split chunk
    remainingChunk->prevPtr = chunkToSplit;
    //Set the current size to be equal to the chunk's size - the allocated size - the chunk struct size
    remainingChunk->currentSize = (size_t)chunkToSplit->currentSize - size - CHUNK_SIZE;
    //Set in use bit to be off
    remainingChunk->currentSize = UNSET_IN_USE_BIT(remainingChunk->currentSize);
    remainingChunk->corruptionCheckPtr = remainingChunk;
    //Update the next chunk's previous pointer
    remainingChunk->fowardPtr->prevPtr = remainingChunk;

    //update the split chunk
    //update its size and split chunk's in use bit
    chunkToSplit->currentSize = SET_IN_USE_BIT(size);

    //update its foward ptr to point to the new chunk
    chunkToSplit->fowardPtr = remainingChunk;
}

/***************************************************************
 *  malloc - allocates the requested (size) of WORDs into the heap
 *  Parameters: 
 *  size_t size - takes in the requested (size) that we want to chunk to be.
 *  
 *  Return Value:
 *  void* (allocatedChunk or NULL) - pointer to the data region of the chunk where the user can do whatever they want to do in that region
 *
 *  Implementation details:
 *  1) previousChunk will be used to find the last chunk before the top chunk if no free chunk was found
 *  2) allocatedChunk is the pointer to the data section of the chunk that is returned to the use
 *  3) first checks if the topChunkPtr is initialized
 *      1) if so, attempt to find a free chunk
 *          1) if a free chunk is found, see if we can split the free chunk
 *      2) else, we call extend_heap to ask the OS for more mapped memory
 *  4) else, we call extend_heap to ask the OS for more mapped memory
 *  5) return the data section of the chunk struct
 **************************************************************/

void* malloc(size_t size)
{
    //previous chunk is used to check if we need to call sbrk to get more memory
    chunkptr previousChunk;
    //allocated chunk is the requested allocated memory we are going to give to the user
    chunkptr allocatedChunk = NULL;

    //Check if the topChunkPtr is initialized
    if(main_arena.topChunkPtr->corruptionCheckPtr != NULL)
    {
        //intialize previous chunk to topChunkPtr incase the allocated chunk is not set to topChunkPtr
        previousChunk = main_arena.topChunkPtr;
        //try to find a block (could be bigger than the requested size)
        allocatedChunk = find_block(&previousChunk, size);
        //if we found a block, check if we can split the block
        if(allocatedChunk && allocatedChunk != main_arena.topChunkPtr)
        {
            //Get the difference in the actual size and requested size
            size_t chunkSizeDifference = allocatedChunk->currentSize - size;
            //If the difference is bigger than the threshold, split the chunk
            size_t thresholdSizeDifference = 1;

            //Add the chunk size to threshold because space required for a new chunk struct
            thresholdSizeDifference += CHUNK_SIZE;
            //Check if the difference is big enough
            if(chunkSizeDifference >= thresholdSizeDifference)
            {
                split_chunk(allocatedChunk, size);
            } 
            else 
            {
                //If we cannot split, there are two cases to consider
                //1) the size is a perfect fit
                //2) the requested size is bigger than the marked location (does this even happen?)

                // if(allocatedChunk->currentSize == size)
                // {
                    //Set the IN_USE_BIT on
                    allocatedChunk->currentSize = SET_IN_USE_BIT(size);
                // }
                // else
                // {
                //     //if the size is greater,
                //     lc4_puts((lc4uint*)"SIZE IS GREATER SOMEHOW?");
                // }
            }
            //update the allocated size
            //allocatedChunk->currentSize = SET_IN_USE_BIT(allocatedChunk->currentSize);
            //Set allocated chunk's corruption pointer
            allocatedChunk->corruptionCheckPtr = allocatedChunk;
        }
        else
        {
            //If we cannot find a block, we have to extend the heap
            //(this is where previous chunk is useful)
            allocatedChunk = extend_heap(previousChunk, size);

            //Link the allocated chunk with the previous Chunk
            allocatedChunk->prevPtr = previousChunk;

            //If we cannot extend the heap anymore, return NULL
            if(!allocatedChunk)
                return NULL;
        }
    }
    else
    {
        //This is where we call malloc for the first time

        //Extend the heap
        allocatedChunk = extend_heap(NULL, size);
        //Check if the call to extending the heap has failed
        if(!allocatedChunk)
            return NULL;

        //initialize topChunkPtr to not freed
        //main_arena.topChunkPtr->currentSize = SET_IN_USE_BIT(sbrk(size));
    }
    return &(allocatedChunk->data);
}

/***************************************************************
 *  merge_chunk - attempts to coalesce next chunk if the next chunk is free (assumes that the current chunk is free)
 *  Parameters: 
 *  chunkptr mergeChunk - the free chunk that we want to merge with its adjacent next chunk
 *  
 *  Return Value:
 *  size_t - MERGE_SUCCESS or MERGE_FAILURE
 *
 *  Implementation details:
 *  1) Get a pointer to the next chunk by offseting the mergeChunk's memory location by its size and CHUNK_SIZE (the size of the chunk struct)
 *  2) Check if the next chunk is free and if it isn't the top chunk ptr
 *      1) if so, merge the chunks. The mergeChunk will now be:
 *          1) currentSize = currentSize + CHUNK_SIZE (consume other chunk struct) + other chunk struct's currentSize, prevPtr = same, fowardPtr = nextChunk's forwardPtr, corruptionCheckPtr = same
 *          2) return MERGE_SUCESS
 *      2) else, return MERGE_FAILURE
 **************************************************************/

#define MERGE_SUCCESS 1
#define MERGE_FAILED  0

size_t merge_chunk(chunkptr mergeChunk)
{
    //next chunk may not be free, so attempt to find if it is free and merge it
    chunkptr nextChunk = (chunkptr)((size_t)mergeChunk + UNSET_IN_USE_BIT(mergeChunk->currentSize) + CHUNK_SIZE);
    if(nextChunk && !CHECK_IN_USE_BIT(nextChunk->currentSize) && nextChunk != main_arena.topChunkPtr)
    {
        //Merge the size
        mergeChunk->currentSize += CHUNK_SIZE + mergeChunk->fowardPtr->currentSize;
        //Unset the IN_USE_BIT
        mergeChunk->currentSize = UNSET_IN_USE_BIT(mergeChunk->currentSize);
        //Point to the correct next chunk
        mergeChunk->fowardPtr = nextChunk->fowardPtr;
        //Make sure that the next pointer points at this correct chunk
        if(mergeChunk->fowardPtr)
            mergeChunk->fowardPtr->prevPtr = mergeChunk;

        return MERGE_SUCCESS;
    }
    return MERGE_FAILED;
}

/***************************************************************
 *  check_if_valid - checks if a chunkptr is valid
 *  Parameters: 
 *  void* ptr - a chunkptr that we want to check is valid
 *  
 *  Return Value:
 *  size_t - IS_VALID or IS_NOT_VALID
 *
 *  Implementation details:
 *  1) Check if the corruption ptr is same as the ptr
 *      1) Check if the ptr is pointing in somewhere in the heap
 *          1) Check if malloc has been called
 *              1) return IS_VALID
 *  2) return IS_NOT_VALID
 **************************************************************/

#define IS_VALID     1
#define IS_NOT_VALID 0

size_t check_if_valid(void* ptr)
{
    //check if the corruption pointer is the same as the ptr
    if(((chunkptr)ptr)->corruptionCheckPtr == (chunkptr)ptr)
    {
        //check if malloc has been called once
        if(main_arena.topChunkPtr->prevPtr != NULL)
        {
            //check if ptr is within heap range
            if((size_t)ptr >= USER_HEAP_ADDR && (size_t)ptr < (size_t)main_arena.topChunkPtr)
            {
                return IS_VALID;
            }
        }
    }
    return IS_NOT_VALID;
}

/***************************************************************
 *  free - attempts to free a chunk that was malloc'ed
 *  Parameters: 
 *  void* ptr - a ptr to the chunk's data
 *  
 *  Return Value:
 *  none
 *
 *  Implementation details:
 *  1) offset the ptr to point to the actual chunk
 *  2) check if the chunk ptr is valid by checking its corruption ptr
 *      1) if so, mark the chunk as free and set its corruption ptr to NULL
 *          1) attempt to merge with previous chunk if the previous chunk is free
 *          2) else, make sure that the previous chunk's forwardPtr points at the chunk after this (free'd) chunk
 *          3) check if the forwardPtr is pointing to topChunk
 *          4) if not, attempt to merge with next chunk
 *          5) else, shrink the heap or reinitialize the heap if all chunks are free
 *  3) if chunk is not valid, segfault
 **************************************************************/

void free(void* ptr)
{
    //Get the structure's pointer (offset ptr to the struct chunk)
    ptr = (void*)GET_STRUCT_POINTER((size_t)ptr);
    //check is ptr is a valid ptr
    if(check_if_valid(ptr))
    {
        //mark the chunk as free
        ((chunkptr)ptr)->currentSize = UNSET_IN_USE_BIT(((chunkptr)ptr)->currentSize);
        //set the corruption chunk ptr to NULL, so double free will cause segfault
        ((chunkptr)ptr)->corruptionCheckPtr = NULL;

        //If the previous chunk is free, merge it with the current chunk
        if(((chunkptr)ptr)->prevPtr && !CHECK_IN_USE_BIT(((chunkptr)ptr)->prevPtr->currentSize))
        {
            merge_chunk(((chunkptr)ptr)->prevPtr);
        }
        else
        {
            //WRONG - SHOULD NOT!!!
            //else, update the previous chunk's ptr to point to the next chunk (if not NULL) 
            //if(((chunkptr)ptr)->prevPtr != NULL)
                //((chunkptr)ptr)->prevPtr->fowardPtr = ((chunkptr)ptr)->fowardPtr;
        }

        //If the next chunk is free, merge this chunk with the next chunk 
        //(also, check if it's not the top chunk)
        if(((chunkptr)ptr)->fowardPtr && (size_t)((chunkptr)ptr)->fowardPtr != (size_t)main_arena.topChunkPtr)
        {
            if(merge_chunk((chunkptr)ptr) == MERGE_FAILED)
            {
                //WRONG - SHOULD NOT!!!
                //if merging failed, update the next's chunk foward to point at this chunk (redundant code?)
                //((chunkptr)ptr)->fowardPtr->prevPtr = (chunkptr)ptr;
            }
        }
        else
        {
            //If it is the case that the foward ptr is the topchunk, ask the OS to 
            //take back memory
            //We pass prev ptr because this is a free block and we want the
            //previous to point at top chunk
            if(((chunkptr)ptr)->prevPtr)
            {
                shrink_heap(((chunkptr)ptr)->prevPtr, ((chunkptr)ptr)->currentSize);
            }
            else
            {
                //else, we know that the entire heap is free'd, now reset everything
                intialize_heap();
            }
        }
    }
    else
    {
        lc4_puts((lc4uint*)"SEGFAULT - freeing twice");
        lc4_halt();
    }
}

/***************************************************************
 *  calloc - allocates n chunks with s size that are 0 initialized
 *  Parameters: 
 *  size_t nmemb - number of chunks to allocate
 *  size_t size  - size of each chunk
 *  Return Value:
 *  void* - a pointer to the start of the first chunk
 *
 *  Implementation details:
 *  1) call malloc of nmemb * size
 *  2) zero each memory location
 **************************************************************/

void* calloc(size_t nmemb, size_t size)
{
    void* allocatedMemory;
    size_t i = 0;
    size_t totalSize = nmemb * size;
    allocatedMemory = malloc(totalSize);
    while(i < totalSize)
    {
        //zero each memory location
        *((size_t*)allocatedMemory + i) = 0;
        i++;
    }
    return 0;
}

/***************************************************************
 *  copy_chunk - copies the data from one chunk to another chunk
 *  Parameters: 
 *  chunkptr src - source chunk
 *  chunkptr dst - destination chunk
 *  Return Value:
 *  none
 *
 *  Implementation details:
 *  1) find the size of the destination chunk
 *  2) copy the data in the destination chunk into the data of the src chunks
 **************************************************************/

void copy_chunk(chunkptr src, chunkptr dst)
{
    size_t i = 0;
    size_t totalSize = UNSET_IN_USE_BIT(dst->currentSize);
    //iterate through each variable in dest and copy it into src
    src = GET_DATA_POINTER(src);
    dst = GET_DATA_POINTER(dst);
    while(i < totalSize)
    {
        dst[i] = src[i];
        i++;
    }
}

/***************************************************************
 *  realloc - reallocates a chunk to be another size
 *  Parameters: 
 *  void* ptr   - the chunk to be resized
 *  size_t size - the size the chunk should become
 *  Return Value:
 *  void* - pointer to the new chunk
 *
 *  Implementation details:
 *  1) cet the struct chunk
 *  2) if the ptr is null, just call malloc
 *  3) if the ptr is valid
 *      1) try to split the chunk if the size requested was smaller
 *      2) else, check if next chunk is free and attempt to merge and split if possible
 **************************************************************/

void* realloc(void* ptr, size_t size)
{
    chunkptr allocatedChunkToFitSize;
    //Get the structure's pointer (offset ptr to the struct chunk)
    ptr = (void*)GET_STRUCT_POINTER((size_t)ptr);

    if(!ptr)
        return malloc(size);

    //Check if ptr is valid
    if(check_if_valid(ptr))
    {
        //Get the difference in the actual size and requested size
        size_t chunkSizeDifference = ((chunkptr)ptr)->currentSize - size;
        //If the difference is bigger than the threshold, split the chunk
        size_t thresholdSizeDifference = 1;

        //Add the chunk size to threshold because space required for a new chunk struct
        thresholdSizeDifference += CHUNK_SIZE;
        //Check if the difference is big enough
        if(chunkSizeDifference >= thresholdSizeDifference)
        {
            split_chunk((chunkptr)ptr, size);
        } 
        else 
        {   
            //If the next chunk is free, merge this chunk with the next chunk 
            //(also, check if it's not the top chunk)
            if(((chunkptr)ptr)->fowardPtr && (size_t)((chunkptr)ptr)->fowardPtr != (size_t)main_arena.topChunkPtr)
            {
                if(merge_chunk((chunkptr)ptr) == MERGE_SUCCESS)
                {
                    //Get the difference in the actual size and requested size
                    size_t chunkSizeDifference = ((chunkptr)ptr)->currentSize - size;                
                    //Check if the difference is big enough (check to see if we can attempt to split block again)
                    if(chunkSizeDifference >= thresholdSizeDifference)
                    {
                        split_chunk((chunkptr)ptr, size);
                    } 
                }
            }
            else
            {
                allocatedChunkToFitSize = malloc(size);

                //copy this chunk and free it
                copy_chunk(ptr, GET_STRUCT_POINTER(allocatedChunkToFitSize));

                //free the copied chunk
                free((void*)GET_DATA_POINTER((size_t)ptr));

                return allocatedChunkToFitSize;
            }
        }
    }
    else
    {
        lc4_puts((lc4uint*)"SEGFAULT - Realloc - ptr is invalid");
        lc4_halt();
    }
    return 0;
}

// int main()
// {
//     return 0;
// }
