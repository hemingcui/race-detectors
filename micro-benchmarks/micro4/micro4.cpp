#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>
#include <pthread.h>


#define MAX (100)

int sum=0;

pthread_t th[2];
pthread_mutex_t mu;


void* thread_func_1(void* arg) {
//sleep(1);
    sum+=1;
    pthread_mutex_lock(&mu);
    pthread_mutex_unlock(&mu);
}
void* thread_func_2(void* arg) {
sleep(1);
    pthread_mutex_lock(&mu);
    pthread_mutex_unlock(&mu);
    sum+=2;
}

extern "C" int main(int argc, char * argv[]);
int main(int argc, char *argv[]) {
  int ret;


    pthread_mutex_init(&mu, NULL);
    ret  = pthread_create(&th[0], NULL, thread_func_1,NULL);
    assert(!ret && "pthread_create() failed!");
    ret  = pthread_create(&th[1], NULL, thread_func_2,NULL);
    assert(!ret && "pthread_create() failed!");
  for(int i=0; i<2; ++i)
    pthread_join(th[i], NULL);
  printf("sum=%d\n",sum);
  return 0;
}
