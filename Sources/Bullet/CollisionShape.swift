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
}
