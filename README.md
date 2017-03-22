# LC4Malloc
Provides a dynamic memory manager for PennSim. 
The malloc implementation based on a first fit algorithm.

mallocV1 - first version (first fit)
  | Binaries - files required to link malloc library to the c program
  | Example - example of a fully linked malloc library
  | Implementation - the malloc c implementation file

# How to link the malloc library to your c program (using malloc_test as an example)

### Setup script files
Go to your script file (in my case, malloc_test.txt) and link the malloc file by:

- Change (as malloc_test user lc4libc malloc_test) to (as malloc_test malloc user lc4libc malloc_test)
- Add (break set OS_START) at the end

### Include malloc.h
In your .c file (in my case, malloc_test.c), and include malloc.h, so lcc can see the prototypes for heap functions
(#include "malloc.h")

### Call initialize_heap
In your .c file, in main() function, call intialize_heap() (Not calling this function first will cause your program to access illegal memory!!!)
int main() {
    intialize_heap();
    ...
}

### And now, you're good to go!

======

## Usage
Download the binary and link it with your current c file by including "malloc.h"

# Known Bugs
```diff
- Free does not merge top chunk and the chunk before it
```

# Todos
```diff
+ Check for negative size malloc
```

## Contributors
Henry Zhu

### Contributors on GitHub
* [Contributors](https://github.com/Maknee/LC4Malloc/graphs/contributors)

### Third party libraries
* LCC, PennSim-Debugger

## License 
* see [LICENSE](https://github.com/Maknee/LC4Malloc/blob/master/LICENSE.txt)

## Version 
* Version 0.1

## Contact
* e-mail: henryzhu@seas.upenn.edu
