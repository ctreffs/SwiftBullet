//
//  File.swift
//
//
//  Created by Christian Treffs on 10.02.20.
//

import CBullet

public struct PCmd {
    let build: PhysicsCommandBuilder

    public init(_ client: b3PhysicsClientHandle) {
        self.build = PhysicsCommandBuilder(client)
    }
}

extension PCmd {
    public func stepSimulation() -> MemoryStatusHandleResult {
        build
            .command(b3InitStepSimulationCommand)
            .expect(CMD_STEP_FORWARD_SIMULATION_COMPLETED)
            .submit()
    }

    public func requestCollisionInfo(bodyUniqueId: Int32) -> MemoryStatusHandleResult {
        build
            .command { b3RequestCollisionInfoCommandInit($0, bodyUniqueId) }
            .expect(CMD_REQUEST_COLLISION_INFO_COMPLETED)
            .submit()
    }

    public func requestActualStateCommand(bodyUniqueId: Int32) -> MemoryStatusHandleResult {
        build
            .command { b3RequestActualStateCommandInit($0, bodyUniqueId) }
            .expect(CMD_ACTUAL_STATE_UPDATE_COMPLETED)
            .submit()
    }

    public func getActualPlacement(_ statusHandle: MemoryStatusHandleResult,
                                   _ bodyUniqueId: inout Int32,
                                   _ position: inout SIMD3<Double>,
                                   _ orientation: inout SIMD4<Double>
    ) -> MemoryStatusHandleResult {
        statusHandle
            .command(expectedStatus: 1) { handle in
                // FIXME: this allocates per call
                var actualStateQPtr = UnsafeMutablePointer<UnsafePointer<Double>?>.allocate(capacity: 7)
                defer { actualStateQPtr.deallocate() }
                var numDegreeOfFreedomQ: Int32 = -1

                let status = b3GetStatusActualState(handle,
                                                    &bodyUniqueId,
                                                    &numDegreeOfFreedomQ,
                                                    nil,
                                                    nil,
                                                    actualStateQPtr,
                                                    nil,
                                                    nil)

                precondition(numDegreeOfFreedomQ == 7)
                let actualStateQ = actualStateQPtr.pointee!

                // position
                position[0] = actualStateQ[0]
                position[1] = actualStateQ[1]
                position[2] = actualStateQ[2]

                // orientation
                orientation[0] = actualStateQ[3]
                orientation[1] = actualStateQ[4]
                orientation[2] = actualStateQ[5]
                orientation[3] = actualStateQ[6]

                return status
            }
    }

    public func createBoxShape(startPosition: SIMD3<Double>, startOrientation: SIMD4<Double>, halfExtents: SIMD3<Double>, mass: Double, collisionShapeType: CollisionShape.Kind, colorRGBA: SIMD4<Double>) -> MemoryStatusHandleResult {
        build
            .command(b3CreateBoxShapeCommandInit)
            .set { b3CreateBoxCommandSetStartPosition($0, startPosition.x, startPosition.y, startPosition.z) }
            .set { b3CreateBoxCommandSetStartOrientation($0, startOrientation.x, startOrientation.y, startOrientation.z, startOrientation.w) }
            .set { b3CreateBoxCommandSetHalfExtents($0, halfExtents.x, halfExtents.y, halfExtents.z) }
            .set { b3CreateBoxCommandSetMass($0, mass) }
            .set { b3CreateBoxCommandSetCollisionShapeType($0, collisionShapeType.rawValue) }
            .set { b3CreateBoxCommandSetColorRGBA($0, colorRGBA.x, colorRGBA.y, colorRGBA.z, colorRGBA.w) }
            .expect(CMD_RIGID_BODY_CREATION_COMPLETED)
            .submit()
    }

    public func createCollisionShape(_ shapes: CollisionShape...) -> MemoryStatusHandleResult {
        build
            .command(b3CreateCollisionShapeCommandInit)
            .injectIndexed(shapes.map { $0.closure })
            .expect(CMD_CREATE_COLLISION_SHAPE_COMPLETED)
            .submit()
    }

    public func createMultiBody(collisionShapeUniqueId: Int32, visualShapeUniqueId: Int32, mass: Double, basePosition: SIMD3<Double>, baseOrientation: SIMD4<Double>, baseInertialFramePosition: SIMD3<Double>, baseInertialFrameOrientation: SIMD4<Double>) -> MemoryStatusHandleResult {
        basePosition.unsafeScalars { basePosPtr in
            baseOrientation.unsafeScalars { baseOriPtr in
                baseInertialFramePosition.unsafeScalars { baseInertialFramePosPtr in
                    baseInertialFrameOrientation.unsafeScalars { baseInertialFrameOriPtr in
                        build
                            .command(b3CreateMultiBodyCommandInit)
                            .set { b3CreateMultiBodyBase($0, mass, collisionShapeUniqueId, visualShapeUniqueId, basePosPtr, baseOriPtr, baseInertialFramePosPtr, baseInertialFrameOriPtr) }
                            .expect(CMD_CREATE_MULTI_BODY_COMPLETED)
                            .submit()
                    }
                }
            }
        }
    }

    public func getStatusBodyIndex(_ statusHandle: MemoryStatusHandleResult) -> Int32 {
        statusHandle.id { b3GetStatusBodyIndex($0) }
    }

    public func getStatusAABB(_ statusHandle: MemoryStatusHandleResult, linkIndex: Int32, aabbMin: inout SIMD3<Double>, aabbMax: inout SIMD3<Double>) -> MemoryStatusHandleResult {
        aabbMin.unsafeMutableScalars { aabbMinPtr in
            aabbMax.unsafeMutableScalars { aabbMaxPtr in
                statusHandle
                    .command { b3GetStatusAABB($0, linkIndex, aabbMinPtr, aabbMaxPtr) }
            }
        }
    }

    public func getStatusCollisionShapeUniqueId(_ status: MemoryStatusHandleResult) -> Int32 {
        status.id { b3GetStatusCollisionShapeUniqueId($0) }
    }
}
