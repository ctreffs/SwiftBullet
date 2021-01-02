#if USE_BULLET_2XX_API

// Bullet version 2.89
#include <Bullet/SharedMemoryPublic.h>
#include <Bullet/PhysicsClientC_API.h>
#include <Bullet/PhysicsClientSharedMemory2_C_API.h>
#include <Bullet/PhysicsClientSharedMemory_C_API.h>
#include <Bullet/PhysicsClientTCP_C_API.h>
#include <Bullet/PhysicsClientUDP_C_API.h>
#include <Bullet/PhysicsDirectC_API.h>
#include <Bullet/SharedMemoryInProcessPhysicsC_API.h>

#else

// Bullet version 3.08
#include <Bullet/SharedMemory/SharedMemoryPublic.h>
#include <Bullet/SharedMemory/PhysicsClientC_API.h>
#include <Bullet/SharedMemory/PhysicsClientGRPC_C_API.h>
#include <Bullet/SharedMemory/PhysicsClientSharedMemory2_C_API.h>
#include <Bullet/SharedMemory/PhysicsClientSharedMemory_C_API.h>
#include <Bullet/SharedMemory/PhysicsClientTCP_C_API.h>
#include <Bullet/SharedMemory/PhysicsClientUDP_C_API.h>
#include <Bullet/SharedMemory/PhysicsDirectC_API.h>
#include <Bullet/SharedMemory/PhysicsLoopBackC_API.h>
#include <Bullet/SharedMemory/SharedMemoryInProcessPhysicsC_API.h>

#endif
