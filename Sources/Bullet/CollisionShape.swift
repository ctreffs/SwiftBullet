//
//  CollisionShape.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

import CBullet

public struct CollisionShape {
    let closure: SettableClosure

    init(_ closure: @escaping SettableClosure) {
        self.closure = closure
    }
}

// MARK: - Builder
extension CollisionShape {
    public static func box(_ halfExtents: Vector3) -> CollisionShape {
        CollisionShape { build in
            halfExtents.unsafeScalars { halfExtentsPtr in
                build.set { b3CreateCollisionShapeAddBox($0, halfExtentsPtr) }
            }
        }
    }

    public static func sphere(_ radius: Double) -> CollisionShape {
        .init { $0.set { b3CreateCollisionShapeAddSphere($0, radius) } }
    }

    public static func capsule(_ radius: Double, _ height: Double) -> CollisionShape {
        .init { $0.set { b3CreateCollisionShapeAddCapsule($0, radius, height) } }
    }

    public static func cylinder(_ radius: Double, _ height: Double) -> CollisionShape {
        .init { $0.set { b3CreateCollisionShapeAddCylinder($0, radius, height) } }
    }

    public static func plane(_ normal: Vector3, _ constant: Double) -> CollisionShape {
        CollisionShape { build in
            normal.unsafeScalars { planeNormalPtr in
                build.set { b3CreateCollisionShapeAddPlane($0, planeNormalPtr, constant) }
            }
        }
    }

    public static func mesh(_ fileName: String, _ scale: Vector3) -> CollisionShape {
        CollisionShape { build in
            scale.unsafeScalars { scalePtr in
                build.set { b3CreateCollisionShapeAddMesh($0, fileName, scalePtr) }
            }
        }
    }

    public static func convexMesh(_ meshScale: Vector3, _ vertices: [Vector3]) -> CollisionShape {
        CollisionShape { build in
            let numVertices = Int32(vertices.count)
            let flatVertices = vertices.flatMap { $0 }
            return flatVertices.withUnsafeBufferPointer { (flatVerticesBufferPtr: UnsafeBufferPointer<Double>) in
                let startVerticesPtr = flatVerticesBufferPtr.baseAddress
                return meshScale.unsafeScalars { meshScalePtr in
                    build.setUsingClient { b3CreateCollisionShapeAddConvexMesh($0, $1, meshScalePtr, startVerticesPtr, numVertices) }
                }
            }
        }
    }

    public static func concaveMesh(_ meshScale: Vector3, _ vertices: [Vector3], _ indices: [Int32]) -> CollisionShape {
        CollisionShape { build in
            let numVertices = Int32(vertices.count)
            let flatVertices = vertices.flatMap { $0 }
            return flatVertices.withUnsafeBufferPointer { (flatVerticesBufferPtr: UnsafeBufferPointer<Double>) in
                let startVerticesPtr = flatVerticesBufferPtr.baseAddress
                let numIndices = Int32(indices.count)
                return indices.withUnsafeBufferPointer { (indicesBufferPtr: UnsafeBufferPointer<Int32>) in
                    let startIndicesPtr = indicesBufferPtr.baseAddress
                    return meshScale.unsafeScalars { meshScalePtr in
                        build.setUsingClient { b3CreateCollisionShapeAddConcaveMesh($0, $1, meshScalePtr, startVerticesPtr, numVertices, startIndicesPtr, numIndices) }
                    }
                }
            }
        }
    }
}
