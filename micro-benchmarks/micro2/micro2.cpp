#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>
//#include "tern/user.h"

#if defined(ENABLE_DMP)
  #include "dmp.h"
#else
  #include <pthread.h>
#endif

#define MAX (100)

int T; // number of threads
int C; // computation size
int I = 1E3; // total number of iterations

pthread_t th[MAX];
pthread_mutex_t mutex;
pthread_cond_t cond;
#include <list>
using namespace std;
std::list<int *> worklist;

long x = 0;
int compute(int C, int key) {
  //int x = 0;
  for(int i=0;i<C;++i)
    x = (long)(x * (i^5) * (x % 12345));
  return x;
}

int nExit = 0;
int tag[MAX];
void* thread_func(void* arg) {
  long tid = (long)arg;
  bool last = (tid == T - 1);
  int *p;
  for(int i=0; i<I; ++i) {
    int key;
    //if (!last) {
      //pthread_mutex_lock(&mutex);
      //key = tag[tid];
      //pthread_mutex_unlock(&mutex);
    //}
    //else {
      for (int i = 0; i < tid; i++) {
        pthread_mutex_lock(&mutex);
        key += tag[tid];
        pthread_mutex_unlock(&mutex);
      }
    //}
    //tern_lineup(0);
    compute(C, key);
  }
}

long sum = 0;
void* writer_func(void* arg) {
  int nTasks = 0;
  while (true) {
    int *p;
    pthread_mutex_lock(&mutex);
    if (worklist.size() == 0)
      pthread_cond_wait(&cond, &mutex);
    //while (worklist.size() > 0) {	    
	p = worklist.front();
    	worklist.pop_front();
	nTasks++;
    //}
    pthread_mutex_unlock(&mutex);
    delete p;
    pthread_mutex_lock(&mutex);
    pthread_mutex_unlock(&mutex);
    pthread_mutex_lock(&mutex);
    pthread_mutex_unlock(&mutex);

    //nTasks++;
    fprintf(stderr, "writer done tasks %d\n", nTasks);
    if (nTasks == I*T) {
      fprintf(stderr, "writer done\n");
      return NULL;
    }
  }
  return NULL;
}

extern "C" int main(int argc, char * argv[]);
int main(int argc, char *argv[]) {
  int ret;

  assert(argc == 3);
  T = atoi(argv[1]); assert(T <= MAX);
  C = atoi(argv[2]);
 
  //tern_lineup_init(0, T, T*100);
  pthread_cond_init(&cond, NULL);
  pthread_mutex_init(&mutex, NULL);
  for(long i=0; i<T; ++i) {
    ret  = pthread_create(&th[i], NULL, thread_func, (void*)i);
    assert(!ret && "pthread_create() failed!");
  }

  pthread_t th2;
  //ret  = pthread_create(&th2, NULL, writer_func, NULL);
  assert(!ret && "pthread_create() failed!");

  for(int i=0; i<T; ++i)
    pthread_join(th[i], NULL);

  //pthread_join(th2, NULL);
  return 0;
}
