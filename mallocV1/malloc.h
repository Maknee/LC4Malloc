typedef int size_t;

void* malloc(size_t size);
void free(void*);
void* calloc(size_t nmemb, size_t size);
void* realloc(void* ptr, size_t size);