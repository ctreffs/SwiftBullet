//
//  CollisionShape.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

import CBullet

// capsule:     position: SIMD3<Double>, orientation: SIMD4<Double>, radius: Double, height: Double
// cylinder:    position: SIMD3<Double>, orientation: SIMD4<Double>, radius: Double, height: Double
// plane:       position: SIMD3<Double>, orientation: SIMD4<Double>, normal: SIMD3<Double>, constant: Double

// mesh:        position: SIMD3<Double>, orientation: SIMD4<Double>, fileName: String, scale: SIMD3<Double>
// convexMesh:  position: SIMD3<Double>, orientation: SIMD4<Double>, fileName: String, scale: SIMD3<Double>
// concaveMesh: position: SIMD3<Double>, orientation: SIMD4<Double>, fileName: String, scale: SIMD3<Double>

public struct CollisionShape {
    let closure: SettableIndexedClosure

    init(_ closure: @escaping SettableIndexedClosure) {
        self.closure = closure
    }
}

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
}
