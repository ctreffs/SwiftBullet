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

    public static func mesh(position: Vector3, orientation: Vector4, fileName: String, scale: Vector3) -> CollisionShape {
        .init { build, shapeIndex -> PhysicsCommandBuilder.Settable in
            position.unsafeScalars { positionPtr in
                orientation.unsafeScalars { orientationPtr in
                    scale.unsafeScalars { scalePtr in
                        build
                            .set { b3CreateCollisionShapeAddMesh($0, fileName, scalePtr) }
                            .apply { b3CreateCollisionShapeSetChildTransform($0, Int32(shapeIndex), positionPtr, orientationPtr) }
                    }
                }
            }
        }
    }

    public static func convexMesh(position: Vector3, orientation: Vector4, meshScale: Vector3, vertices: [Vector3]) -> CollisionShape {
        let numVertices = Int32(vertices.count)
        let flatVertices = vertices.flatMap { $0 }
        return flatVertices.withUnsafeBufferPointer { (flatVerticesBufferPtr: UnsafeBufferPointer<Double>) in
            let startVerticesPtr = flatVerticesBufferPtr.baseAddress!
            return meshScale.unsafeScalars { meshScalePtr in
                CollisionShape { build, _ in
                    build
                        .set {
                            b3CreateCollisionShapeAddConvexMesh($0, meshScalePtr, startVerticesPtr, numVertices)
                        }
                }
            }
        }
    }

    public static func concaveMesh(position: Vector3, orientation: Vector4, fileName: String, scale: Vector3) -> CollisionShape {
        fatalError()
    }
}
