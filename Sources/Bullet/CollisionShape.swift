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

// MARK: - Builder
extension CollisionShape {
    // box:         position: Vector3, orientation: Vector4, halfExtents: Vector3
    public static func box(position: Vector3, orientation: Vector4, halfExtents: Vector3) -> CollisionShape {
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

    // sphere:      position: Vector3, orientation: Vector4, radius: Double
    public static func sphere(position: Vector3, orientation: Vector4, radius: Double) -> CollisionShape {
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

    public static func capsule(position: Vector3, orientation: Vector4, radius: Double, height: Double) -> CollisionShape {
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

    public static func cylinder(position: Vector3, orientation: Vector4, radius: Double, height: Double) -> CollisionShape {
        .init { build, shapeIndex -> PhysicsCommandBuilder.Settable in
            position.unsafeScalars { positionPtr in
                orientation.unsafeScalars { orientationPtr in
                    build
                        .set { b3CreateCollisionShapeAddCylinder($0, radius, height) }
                        .apply { b3CreateCollisionShapeSetChildTransform($0, Int32(shapeIndex), positionPtr, orientationPtr) }
                }
            }
        }
    }

    public static func plane(position: Vector3, orientation: Vector4, normal: Vector3, constant: Double) -> CollisionShape {
        .init { build, shapeIndex -> PhysicsCommandBuilder.Settable in
            position.unsafeScalars { positionPtr in
                orientation.unsafeScalars { orientationPtr in
                    normal.unsafeScalars { planeNormalPtr in
                        build
                            .set { b3CreateCollisionShapeAddPlane($0, planeNormalPtr, constant) }
                            .apply { b3CreateCollisionShapeSetChildTransform($0, Int32(shapeIndex), positionPtr, orientationPtr) }
                    }
                }
            }
        }
    }

    // TODO: more collision shapes
    // mesh:        position: Vector3, orientation: Vector4, fileName: String, scale: Vector3
    // convexMesh:  position: Vector3, orientation: Vector4, fileName: String, scale: Vector3
    // concaveMesh: position: Vector3, orientation: Vector4, fileName: String, scale: Vector3
}
