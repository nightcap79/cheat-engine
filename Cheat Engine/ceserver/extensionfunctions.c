/*
 * extensionfunctions.c
 *
 *  Created on: Aug 25, 2013
 *      Author: eric
 */


#include <stdio.h>
#include <pthread.h>

#include "extensionloader.h"
#include "extensionfunctions.h"
#include "api.h"

//todo: Make all of these fail if the debugger is waiting to continue from a debug event

uint64_t ext_createThread(HANDLE hProcess, uint64_t startaddress, uint64_t parameter)
{
  uint64_t result=0;
  printf("ext_createThread(%d, %lx, %lx\n", hProcess, startaddress, parameter);

  if (GetHandleType(hProcess) == htProcesHandle )
  {
    PProcessData p=(PProcessData)GetPointerFromHandle(hProcess);

#pragma pack(1)
    struct {
      uint8_t command;
      uint64_t startaddress;
      uint64_t parameter;
    } createThreadCommand;
#pragma pack()

    if (p->hasLoadedExtension==FALSE)
    {
      printf("hasLoadedExtension == FALSE");
      if (loadCEServerExtension(hProcess)==FALSE)
      {
        printf("Failure to load the extension\n");
        return 0;
      }
    }

    createThreadCommand.command=EXTCMD_CREATETHREAD;
    createThreadCommand.startaddress=startaddress;
    createThreadCommand.parameter=parameter;

    pthread_mutex_lock(&p->extensionMutex);

    if (sendall(p->extensionFD, &createThreadCommand, sizeof(createThreadCommand), 0)>0)
      recvall(p->extensionFD, &result, sizeof(result), 0);

    pthread_mutex_unlock(&p->extensionMutex);

  }


  return result;
}

int ext_free(HANDLE hProcess, uint64_t address, int size)
{
  uint32_t result=0;

  printf("ext_free(%d, %llx, %d)\n", hProcess, address, size);

  if (GetHandleType(hProcess) == htProcesHandle )
  {
    PProcessData p=(PProcessData)GetPointerFromHandle(hProcess);

#pragma pack(1)
    struct {
      uint8_t command;
      uint64_t address;
      uint32_t size;
    } freeCommand;
#pragma pack()

    if (p->hasLoadedExtension==FALSE)
    {
      printf("hasLoadedExtension == FALSE");
      if (loadCEServerExtension(hProcess)==FALSE)
      {
        printf("Failure to load the extension\n");
        return 0;
      }
    }


    freeCommand.command=EXTCMD_FREE;
    freeCommand.address=address;
    freeCommand.size=size;

    pthread_mutex_lock(&p->extensionMutex);

    if (sendall(p->extensionFD, &freeCommand, sizeof(freeCommand), 0)>0)
      recvall(p->extensionFD, &result, sizeof(result), 0);

    pthread_mutex_unlock(&p->extensionMutex);

  }

  return result;
}

uint64_t ext_alloc(HANDLE hProcess, uint64_t preferedBase, int size)
{
  uint64_t result=0;
  printf("ext_alloc(%d, %llx, %d\n", hProcess, preferedBase, size);

  if (GetHandleType(hProcess) == htProcesHandle )
  {
    PProcessData p=(PProcessData)GetPointerFromHandle(hProcess);

#pragma pack(1)
    struct {
      uint8_t command;
      uint64_t preferedAddress;
      uint32_t size;
    } allocCommand;
#pragma pack()

    if (p->hasLoadedExtension==FALSE)
    {
      printf("hasLoadedExtension == FALSE");
      if (loadCEServerExtension(hProcess)==FALSE)
      {
        printf("Failure to load the extension\n");
        return 0;
      }
    }




    allocCommand.command=EXTCMD_ALLOC;
    allocCommand.preferedAddress=preferedBase;
    allocCommand.size=size;

    pthread_mutex_lock(&p->extensionMutex);

    if (sendall(p->extensionFD, &allocCommand, sizeof(allocCommand), 0)>0)
      recvall(p->extensionFD, &result, sizeof(result), 0);

    pthread_mutex_unlock(&p->extensionMutex);

  }


  return result;
}
