//
//  CollisionShape.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

import CBullet

public struct CollisionShape {
    let closure: SettableIndexedClosure

    init(_ closure: @escaping SettableIndexedClosure) {
        self.closure = closure
    }
}

// MARK: - Types
extension CollisionShape {
    public struct Kind: RawRepresentable {
        public let rawValue: Int32

        public init(_ rawValue: Int) {
            self.init(rawValue: Int32(rawValue))
        }
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let box = Kind(COLLISION_SHAPE_TYPE_BOX)
        public static let cylinderX = Kind(COLLISION_SHAPE_TYPE_CYLINDER_X)
        public static let cylinderY = Kind(COLLISION_SHAPE_TYPE_CYLINDER_Y)
        public static let cylinderZ = Kind(COLLISION_SHAPE_TYPE_CYLINDER_Z)
        public static let capsuleX = Kind(COLLISION_SHAPE_TYPE_CAPSULE_X)
        public static let capsuleY = Kind(COLLISION_SHAPE_TYPE_CAPSULE_Y)
        public static let capsuleZ = Kind(COLLISION_SHAPE_TYPE_CAPSULE_Z)
        public static let sphere = Kind(COLLISION_SHAPE_TYPE_SPHERE)
    }
}

// MARK: - Builder
extension CollisionShape {
    // box:         position: SIMD3<Double>, orientation: SIMD4<Double>, halfExtents: SIMD3<Double>
    public static func box(position: SIMD3<Double>, orientation: SIMD4<Double>, halfExtents: SIMD3<Double>) -> CollisionShape {
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

    public static func capsule(position: SIMD3<Double>, orientation: SIMD4<Double>, radius: Double, height: Double) -> CollisionShape {
        .init { build, shapeIndex -> PhysicsCommandBuilder.Settable in
            position.unsafeScalars { positionPtr in
                orientation.unsafeScalars { orientationPtr in
                    build
                        .set { b3CreateCollisionShapeAddCapsule($0, radius, height) }
                        .apply { b3CreateCollisionShapeSetChildTransform($0, Int32(shapeIndex), positionPtr, orientationPtr) }
                }
            }
        }
    }

    // TODO: more collision shapes
    // cylinder:    position: SIMD3<Double>, orientation: SIMD4<Double>, radius: Double, height: Double
    // plane:       position: SIMD3<Double>, orientation: SIMD4<Double>, normal: SIMD3<Double>, constant: Double

    // mesh:        position: SIMD3<Double>, orientation: SIMD4<Double>, fileName: String, scale: SIMD3<Double>
    // convexMesh:  position: SIMD3<Double>, orientation: SIMD4<Double>, fileName: String, scale: SIMD3<Double>
    // concaveMesh: position: SIMD3<Double>, orientation: SIMD4<Double>, fileName: String, scale: SIMD3<Double>
}
