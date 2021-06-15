#define BT_ENABLE_ENET
#define BT_ENABLE_CLSOCKET
#define BT_ENABLE_PHYSX
#define BT_ENABLE_DART
#define BT_ENABLE_MUJOCO

#ifdef __APPLE__
#include "apple.h"
#endif
#else
#include "linux.h"
#endif
