// Bullet 3
#define BT_ENABLE_ENET
#define BT_ENABLE_CLSOCKET
#define BT_ENABLE_PHYSX
#define BT_ENABLE_DART
#define BT_ENABLE_MUJOCO

#ifdef __APPLE__

// === APPLE =========
// This solves the following error in the CollisionSdkC_Api:
// Must use 'struct' tag to refer to type 'lwContactPoint'
typedef struct lwContactPoint lwContactPoint;

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
#include <Bullet/Collision/CollisionSdkC_Api.h>
#include <Bullet/SharedMemory/dart/DARTPhysicsC_API.h>
#include <Bullet/SharedMemory/mujoco/MuJoCoPhysicsC_API.h>
#include <Bullet/SharedMemory/physx/PhysXC_API.h>
#include <Bullet/TinyAudio/b3Sound_C_Api.h>

#else

// === Linux ========
// FIXME: No C-API yet for linux!!!
//#include "/usr/include/bullet/btBulletCollisionCommon.h"
//#include "/usr/include/bullet/btBulletDynamicsCommon.h"


#endif
