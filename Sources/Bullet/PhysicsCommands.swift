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
    public func stepSimulation() -> StatusResult {
        build
            .command(b3InitStepSimulationCommand)
            .expect(CMD_STEP_FORWARD_SIMULATION_COMPLETED)
            .submit()
    }

    public func requestCollisionInfo(bodyUniqueId: Int32) -> StatusResult {
        build
            .command { b3RequestCollisionInfoCommandInit($0, bodyUniqueId) }
            .expect(CMD_REQUEST_COLLISION_INFO_COMPLETED)
            .submit()
    }

    public func requestActualStateCommand(bodyUniqueId: Int32) -> StatusResult {
        build
            .command { b3RequestActualStateCommandInit($0, bodyUniqueId) }
            .expect(CMD_ACTUAL_STATE_UPDATE_COMPLETED)
            .submit()
    }

    public func getActualPlacement(_ statusHandle: StatusResult,
                                   _ bodyUniqueId: inout Int32,
                                   _ position: inout SIMD3<Double>,
                                   _ orientation: inout SIMD4<Double>
    ) -> StatusResult {
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

    public func createBoxShape(startPosition: SIMD3<Double>, startOrientation: SIMD4<Double>, halfExtents: SIMD3<Double>, mass: Double, collisionShapeType: CollisionShapeType, colorRGBA: SIMD4<Double>) -> StatusResult {
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

    public func createCollisionShape(_ shapes: CollisionShape...) -> StatusResult {
        build
            .command(b3CreateCollisionShapeCommandInit)
            .injectIndexed(shapes.map { $0.closure })
            .expect(CMD_CREATE_COLLISION_SHAPE_COMPLETED)
            .submit()
    }

    public func createMultiBody(collisionShapeUniqueId: Int32, visualShapeUniqueId: Int32, mass: Double, basePosition: SIMD3<Double>, baseOrientation: SIMD4<Double>, baseInertialFramePosition: SIMD3<Double>, baseInertialFrameOrientation: SIMD4<Double>) -> StatusResult {
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

    public func getStatusBodyIndex(_ statusHandle: StatusResult) -> Int32 {
        statusHandle.id { b3GetStatusBodyIndex($0) }
    }

    public func getStatusAABB(_ statusHandle: StatusResult, linkIndex: Int32, aabbMin: inout SIMD3<Double>, aabbMax: inout SIMD3<Double>) -> StatusResult {
        aabbMin.unsafeMutableScalars { aabbMinPtr in
            aabbMax.unsafeMutableScalars { aabbMaxPtr in
                statusHandle
                    .command { b3GetStatusAABB($0, linkIndex, aabbMinPtr, aabbMaxPtr) }
            }
        }
    }

    public func getStatusCollisionShapeUniqueId(_ status: StatusResult) -> Int32 {
        status.id { b3GetStatusCollisionShapeUniqueId($0) }
    }
}

public struct CollisionShapeType: RawRepresentable {
    public let rawValue: Int32

    public init(_ rawValue: Int) {
        self.init(rawValue: Int32(rawValue))
    }
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    public static let box = CollisionShapeType(COLLISION_SHAPE_TYPE_BOX)
    public static let cylinderX = CollisionShapeType(COLLISION_SHAPE_TYPE_CYLINDER_X)
    public static let cylinderY = CollisionShapeType(COLLISION_SHAPE_TYPE_CYLINDER_Y)
    public static let cylinderZ = CollisionShapeType(COLLISION_SHAPE_TYPE_CYLINDER_Z)
    public static let capsuleX = CollisionShapeType(COLLISION_SHAPE_TYPE_CAPSULE_X)
    public static let capsuleY = CollisionShapeType(COLLISION_SHAPE_TYPE_CAPSULE_Y)
    public static let capsuleZ = CollisionShapeType(COLLISION_SHAPE_TYPE_CAPSULE_Z)
    public static let sphere = CollisionShapeType(COLLISION_SHAPE_TYPE_SPHERE)
}

// capsule:     position: SIMD3<Double>, orientation: SIMD4<Double>, radius: Double, height: Double
// cylinder:    position: SIMD3<Double>, orientation: SIMD4<Double>, radius: Double, height: Double
// plane:       position: SIMD3<Double>, orientation: SIMD4<Double>, normal: SIMD3<Double>, constant: Double

// mesh:        position: SIMD3<Double>, orientation: SIMD4<Double>, fileName: String, scale: SIMD3<Double>
// convexMesh:  position: SIMD3<Double>, orientation: SIMD4<Double>, fileName: String, scale: SIMD3<Double>
// concaveMesh: position: SIMD3<Double>, orientation: SIMD4<Double>, fileName: String, scale: SIMD3<Double>

public struct CollisionShape {
    let closure: (PhysicsCommandBuilder.Settable, Int) -> PhysicsCommandBuilder.Settable

    init(_ closure: @escaping (PhysicsCommandBuilder.Settable, Int) -> PhysicsCommandBuilder.Settable) {
        self.closure = closure
    }
}

extension CollisionShape {
    // box:         position: SIMD3<Double>, orientation: SIMD4<Double>, halfExtents: SIMD3<Double>
    public static func box(position: SIMD3<Double> = .zero, orientation: SIMD4<Double>, halfExtents: SIMD3<Double>) -> CollisionShape {
        .init { build, shapeIndex -> PhysicsCommandBuilder.Settable in
            position.unsafeScalars { positionPtr in
                orientation.unsafeScalars { orientationPtr in
                    halfExtents.unsafeScalars { halfExtentsPtr in
                        build
                            .set { b3CreateCollisionShapeAddBox($0, halfExtentsPtr) }
                            .apply { b3CreateCollisionShapeSetChildTransform($0, Int32(shapeIndex), positionPtr, orientationPtr) }
                    }
                }
            }
        }
    }

    // sphere:      position: SIMD3<Double>, orientation: SIMD4<Double>, radius: Double
    public static func sphere(position: SIMD3<Double>, orientation: SIMD4<Double>, radius: Double) -> CollisionShape {
        .init { build, shapeIndex -> PhysicsCommandBuilder.Settable in
            position.unsafeScalars { positionPtr in
                orientation.unsafeScalars { orientationPtr in
                    build
                        .set { b3CreateCollisionShapeAddSphere($0, radius) }
                        .apply { b3CreateCollisionShapeSetChildTransform($0, Int32(shapeIndex), positionPtr, orientationPtr) }
                }
            }
        }
    }
}
