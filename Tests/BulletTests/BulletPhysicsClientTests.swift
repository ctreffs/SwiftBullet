//
//  BulletPhysicsClientTests.swift
//
//
//  Created by Christian Treffs on 11.02.20.
//

import Bullet
import CBullet
import XCTest

final class BulletPhysicsClientTests: XCTestCase {
    var client: BulletPhysicsClient!

    override func setUp() {
        super.setUp()
        do {
            client = try BulletPhysicsClient(.direct)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func testSetParameters() {
        let params: [PhysicsParameter] = [
            .gravity(.random(in: -1000...1000)),
            .realTimeSimulation(true),
            .timeStep(.random(in: -1000...1000)),
            .numSubSteps(.random(in: 0...1000)),
            .maxNumCommandsPer1ms(.random(in: 1...1000)),
            .numSolverIterations(.random(in: 1...1000))
        ]
        let result = client.setPhysicsParameters(params)
        XCTAssertResultIsSuccess(result)
    }

    func testStepSimulation() {
        for _ in 0..<100 {
            let result = client.stepSimulation()
            XCTAssertResultIsSuccess(result)
        }
    }

    func testCreateCollisionShapes() {
        let sphereId = client.createCollisionShapeSphere(radius: .random(in: 0.001...1000.0))
        XCTAssertNotEqual(sphereId, .noId)

        let boxId = client.createCollisionShapeBox(halfExtents: .random(in: 0.001...1000.0))
        XCTAssertNotEqual(boxId, .noId)

        let capsuleId = client.createCollisionShapeCapsule(radius: .random(in: 0.001...1000.0), height: .random(in: 0.001...1000.0))
        XCTAssertNotEqual(capsuleId, .noId)
    }

    func testCreateMultiBody() {
        let sphereId = client.createCollisionShapeSphere(radius: .random(in: 0.001...1000.0))
        let multiBodyId = client.createMultiBody(collisionShape: sphereId,
                                                 visualShape: .noId,
                                                 mass: .random(in: -10...10),
                                                 basePosition: .random(in: -10...10),
                                                 baseOrientation: .random(in: -10...10))

        XCTAssertNotEqual(multiBodyId, .noId)
    }

    func testGetActualPlacement() {
        let origPos: Vector3 = .init(x: 1, y: 2, z: 3)
        let origOri: Vector4 = .init(0.258_198_887_109_756_47, 0.516_397_833_824_157_71, 0.774_596_691_131_591_8, 0.258_198_887_109_756_47)

        let collisionBox = client.createCollisionShapeBox(halfExtents: .init(repeating: 0.5))
        let box = client.createMultiBody(collisionShape: collisionBox,
                                         visualShape: .noId,
                                         mass: 9.81,
                                         basePosition: origPos,
                                         baseOrientation: origOri)
        XCTAssertNotEqual(box, .noId)

        var pos: Vector3 = .zero
        var ori: Vector4 = .zero

        let status = client.getActualPositionAndOrientation(multiBody: box, position: &pos, orientation: &ori)
        XCTAssertResultIsSuccess(status)

        XCTAssertEqual(pos, origPos)
        XCTAssertEqual(ori, origOri)
    }
}
