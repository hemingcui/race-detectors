#if defined(ENABLE_DMP)
  #include "dmp.h"
#endif
#include <stdio.h>
#include <pthread.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <list>
#include <sys/stat.h> 
#include <fcntl.h>
#include <sys/types.h>


int nThreads;
const int maxNThreads = 64;
//const int nBlocks = 4;

/////// not shown ///////

#define BLOCK_SIZE 100
#define SUM_SIZE 100000
double sum[SUM_SIZE];// = 3.14;
char blocks[maxNThreads][BLOCK_SIZE];
std::list<char *> blockQueue;

void init() {
  for (int i = 0; i < SUM_SIZE; i++)
    sum[i] = 3.14;
}

void compress(char *block) {
  fprintf(stderr, "compress block %p\n", (void *)block);
  for (long i = 0; i < 5e4; i++) {
    sum[i%SUM_SIZE] += (i^5)/sum[i%SUM_SIZE];
    /* Do not prefer to involve block[] in computation, sinc that will make
    overhead not being closed to nThreads*x. */
    //block[i%BLOCK_SIZE] = (char)sum;
  }
}

char *readBlock(char *file, int blockId) {
  // read() a 150MB file, and the time taken for pthread is negligible.
  // PBZip2 also did this read() also with a size of file_size/nThreads.
  // We comment this out because dthreads does not support this big new.
  // When reading a full of 150MB input.tar file, only takes 0.12s on my desktop.
  /*int fd = open(file, O_RDONLY);
  assert(fd >= 0);
  struct stat st;
  fstat(fd, &st);
  fprintf(stderr, "file size %u bytes\n", (unsigned)st.st_size);
  char *buf = new char[st.st_size];
  read(fd, buf, st.st_size);
  delete buf;
  close(fd);*/
  return &(blocks[blockId][0]);
}

/////// shown ///////

pthread_mutex_t mutex;
pthread_cond_t cond;
int nWorking = 0;
void *consumer(void *arg) {
  while (true) {
    char *block;
    pthread_mutex_lock(&mutex);
    if (nWorking == nThreads) {
      pthread_mutex_unlock(&mutex);
      return NULL;
    }
    nWorking++;
    if (blockQueue.size() == 0) {
      pthread_cond_wait(&cond, &mutex);
    }
    block = blockQueue.front(); blockQueue.pop_front();
    pthread_mutex_unlock(&mutex);
    fprintf(stderr, "consumer pid %d computing task start time %ld\n", getpid(), (long)time(NULL));
    compress(block);
    fprintf(stderr, "consumer pid %d computing task end time %ld\n", getpid(), (long)time(NULL));
  }
  fprintf(stderr, "consumer pid %d exit2...\n", getpid());
}

extern "C" int main(int argc, char * argv[]);
int main(int argc, char *argv[]) {
  assert(argc == 2);
  nThreads = atoi(argv[1]);
  init();
  fprintf(stderr, "# threads: %d\n", atoi(argv[1]));
  pthread_t th[nThreads];
  for(long i=0; i<nThreads; ++i)
    pthread_create(&th[i], NULL, consumer, (void*)i);
  for (int i = 0; i < nThreads; i++) {
    char *block = readBlock(argv[1], i);
    pthread_mutex_lock(&mutex);
    blockQueue.push_back(block);
    pthread_cond_signal(&cond);
    pthread_mutex_unlock(&mutex);
  }
  for(int i=0; i<nThreads; ++i)
    pthread_join(th[i], NULL);
  return 0;
}

