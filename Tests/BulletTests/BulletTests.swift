//
//  BulletTests.swift
//
//
//  Created by Christian Treffs on 11.02.20.
//

import Bullet
import CBullet
import XCTest

extension SIMD4 where Scalar == Double {
    static let identity = SIMD4<Double>(x: 0, y: 0, z: 0, w: 1)
}

// https://github.com/bulletphysics/bullet3/blob/master/examples/SharedMemory/PhysicsClientExample.cpp
final class BulletTests: XCTestCase {
    let cmd = PCmd(b3ConnectPhysicsDirect()!)

    func testCollisionShape() {
        let boxStatus = cmd.createCollisionShape(.box(position: .zero, orientation: .identity, halfExtents: .one))
        let boxId = cmd.getStatusCollisionShapeUniqueId(boxStatus)

        let multiBodyStatus = cmd.createMultiBody(collisionShapeUniqueId: boxId,
                                                  visualShapeUniqueId: -1,
                                                  mass: 10,
                                                  basePosition: .zero,
                                                  baseOrientation: .identity,
                                                  baseInertialFramePosition: .zero,
                                                  baseInertialFrameOrientation: .identity)
        var multiBodyId = cmd.getStatusBodyIndex(multiBodyStatus)

        var posActual: SIMD3<Double> = .zero
        var oriActual: SIMD4<Double> = .zero

        let actualStateStatus = cmd.requestActualStateCommand(bodyUniqueId: multiBodyId)
        let actualStatus = cmd.getActualPlacement(actualStateStatus, &multiBodyId, &posActual, &oriActual)

        print(actualStatus)
    }
}
