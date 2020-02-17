//
//  BulletPhysicsClientTests.swift
//
//
//  Created by Christian Treffs on 11.02.20.
//

import Bullet
import CBullet
import XCTest

public final class BulletPhysicsClientTests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var client: BulletPhysicsClient!

    override public func setUp() {
        super.setUp()
        do {
            client = try BulletPhysicsClient(.direct)
            XCTAssertEqual(client.numBodies, 0)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    override public func tearDown() {
        super.tearDown()
        client = nil
    }

    func testSetParameters() {
        let params: [PhysicsParameter] = [
            .allowedCcdPenetration(.random(in: -1000...1000)),
            .collisionFilterMode(.random(in: -1000...1000)),
            .constraintSolverType(.random(in: -1000...1000)),
            .contactBreakingThreshold(.random(in: -1000...1000)),
            .contactSlop(.random(in: -1000...1000)),
            .defaultContactERP(.random(in: -1000...1000)),
            .defaultFrictionCFM(.random(in: -1000...1000)),
            .defaultFrictionERP(.random(in: -1000...1000)),
            .defaultGlobalCFM(.random(in: -1000...1000)),
            .defaultNonContactERP(.random(in: -1000...1000)),
            .deterministicOverlappingPairs(.random(in: -1000...1000)),
            .enableConeFriction(.random(in: -1000...1000)),
            .enableFileCaching(.random()),
            .enableSAT(.random()),
            .gravity(.random(in: -1000...1000)),
            .jointFeedbackMode(.random(in: -1000...1000)),
            .maxNumCommandsPer1ms(.random(in: -1000...1000)),
            .minimumSolverIslandSize(.random(in: -1000...1000)),
            .numSolverIterations(.random(in: -1000...1000)),
            .numSubSteps(.random(in: -1000...1000)),
            .realTimeSimulation(.random()),
            .restitutionVelocityThreshold(.random(in: -1000...1000)),
            .solverResidualThreshold(.random(in: -1000...1000)),
            .splitImpulsePenetrationThreshold(.random(in: -1000...1000)),
            .timeStep(.random(in: -1000...1000)),
            .useSplitImpulse(.random())
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

    func testRemoveCollisionShape() {
        let sphereId = client.createCollisionShapeSphere(radius: .random(in: 0.001...1000.0))
        XCTAssertNotEqual(sphereId, .noId)

        let result = client.removeCollisionShape(sphereId)
        XCTAssertResultIsSuccess(result)
    }

    func testCreateMultiBody() {
        let sphereId = client.createCollisionShapeSphere(radius: .random(in: 0.001...1000.0))
        let multiBodyId = client.createMultiBody(collisionShape: sphereId,
                                                 visualShape: .noId,
                                                 mass: .random(in: -10...10),
                                                 basePosition: .random(in: -10...10),
                                                 baseOrientation: .random(in: -10...10))
        XCTAssertEqual(client.numBodies, 1)
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
        XCTAssertEqual(client.numBodies, 1)

        var pos: Vector3 = .zero
        var ori: Vector4 = .zero

        let status = client.getActualPositionAndOrientation(multiBody: box, position: &pos, orientation: &ori)
        XCTAssertResultIsSuccess(status)

        XCTAssertEqual(pos, origPos)
        XCTAssertEqual(ori, origOri)
    }

    func testCastSingleRay() {
        let boxColl1 = client.createCollisionShapeBox(halfExtents: .init(repeating: 0.5))
        let boxColl2 = client.createCollisionShapeBox(halfExtents: .init(repeating: 0.5))

        let box1 = client.createMultiBody(collisionShape: boxColl1, visualShape: .noId, mass: 0, basePosition: .zero, baseOrientation: .identity)
        let box2 = client.createMultiBody(collisionShape: boxColl2, visualShape: .noId, mass: 0, basePosition: .init(x: 0, y: 2, z: 0), baseOrientation: .identity)

        XCTAssertEqual(box1.rawValue, 0)
        XCTAssertEqual(box2.rawValue, 1)
        XCTAssertEqual(client.numBodies, 2)

        let cast1 = client.castRay(from: .init(x: 2, y: 0, z: 0),
                                   to: .init(x: 3, y: 0, z: 0))

        XCTAssertTrue(cast1.isEmpty)

        let cast2 = client.castRay(from: .init(x: 2, y: 0, z: 0),
                                   to: .init(x: -2, y: 0, z: 0))

        XCTAssertEqual(cast2.count, 1)
        XCTAssertEqual(cast2[0].objectUniqueId, box1.rawValue)
        XCTAssertEqual(cast2[0].positionWorld.x, 0.5, accuracy: 1e-7)
        XCTAssertEqual(cast2[0].positionWorld.y, 0)
        XCTAssertEqual(cast2[0].positionWorld.z, 0)

        let cast3 = client.castRay(from: .init(x: 0, y: 4, z: 0),
                                   to: .init(x: 0, y: 0, z: 0))

        XCTAssertEqual(cast3.count, 1)
        XCTAssertEqual(cast3[0].objectUniqueId, box2.rawValue)
        XCTAssertEqual(cast3[0].positionWorld.x, 0)
        XCTAssertEqual(cast3[0].positionWorld.y, 2.5)
        XCTAssertEqual(cast3[0].positionWorld.z, 0)
    }

    func testCastMultipleRays() {
        let boxColl1 = client.createCollisionShapeBox(halfExtents: .init(repeating: 0.5))
        let boxColl2 = client.createCollisionShapeBox(halfExtents: .init(repeating: 0.5))

        let box1 = client.createMultiBody(collisionShape: boxColl1, visualShape: .noId, mass: 0, basePosition: .zero, baseOrientation: .identity)
        let box2 = client.createMultiBody(collisionShape: boxColl2, visualShape: .noId, mass: 0, basePosition: .init(x: 0, y: 2, z: 0), baseOrientation: .identity)

        XCTAssertEqual(client.numBodies, 2)

        let cast1 = client.castRay(from: .init(x: 2, y: 0, z: 0),
                                   to: .init(x: 3, y: 0, z: 0))

        XCTAssertTrue(cast1.isEmpty)

        let cast2 = client.castRays(from: [.init(x: 2, y: 0, z: 0)],
                                    to: [.init(x: -2, y: 0, z: 0)],
                                    threads: .auto)

        XCTAssertEqual(cast2.count, 1)
        XCTAssertEqual(cast2[0].objectUniqueId, box1.rawValue)
        XCTAssertEqual(cast2[0].positionWorld.x, 0.5, accuracy: 1e-7)
        XCTAssertEqual(cast2[0].positionWorld.y, 0)
        XCTAssertEqual(cast2[0].positionWorld.z, 0)

        let cast3 = client.castRays(from: [.init(x: 0, y: 4, z: 0)],
                                    to: [.init(x: 0, y: 0, z: 0)],
                                    threads: .auto)

        XCTAssertEqual(cast3.count, 1)
        XCTAssertEqual(cast3[0].objectUniqueId, box2.rawValue)
        XCTAssertEqual(cast3[0].positionWorld.x, 0)
        XCTAssertEqual(cast3[0].positionWorld.y, 2.5)
        XCTAssertEqual(cast3[0].positionWorld.z, 0)
    }

    func testApplyExternalForce() {
        let shapeCol = client.createCollisionShapeSphere(radius: 1.0)
        let shape = client.createMultiBody(collisionShape: shapeCol, visualShape: .noId, mass: 1, basePosition: .zero, baseOrientation: .identity)

        var pos: Vector3 = .init(repeating: .nan)
        var ori: Vector4 = .init(repeating: .nan)

        let stat1 = client.getActualPositionAndOrientation(multiBody: shape,
                                                           position: &pos,
                                                           orientation: &ori)

        XCTAssertResultIsSuccess(stat1)
        XCTAssertEqual(pos, .zero)
        XCTAssertEqual(ori, .identity)

        let stat2 = client.applyExternalForce(bodyId: shape,
                                              linkId: .noId,
                                              force: .init(x: 100, y: 0, z: 0),
                                              position: .init(x: 0, y: 10, z: 0),
                                              flag: EF_WORLD_FRAME)
        XCTAssertResultIsSuccess(stat2)

        client.stepSimulation()

        let stat3 = client.getActualPositionAndOrientation(multiBody: shape,
                                                           position: &pos,
                                                           orientation: &ori)

        XCTAssertResultIsSuccess(stat3)
        XCTAssertNotEqual(pos, .zero)
        XCTAssertNotEqual(ori, .identity)
    }

    func testApplyExternalTorque() {
        let shapeCol = client.createCollisionShapeSphere(radius: 1.0)
        let shape = client.createMultiBody(collisionShape: shapeCol, visualShape: .noId, mass: 1, basePosition: .zero, baseOrientation: .identity)

        var pos: Vector3 = .init(repeating: .nan)
        var ori: Vector4 = .init(repeating: .nan)

        let stat1 = client.getActualPositionAndOrientation(multiBody: shape,
                                                           position: &pos,
                                                           orientation: &ori)

        XCTAssertResultIsSuccess(stat1)
        XCTAssertEqual(pos, .zero)
        XCTAssertEqual(ori, .identity)

        let stat2 = client.applyExternalTorque(bodyId: shape,
                                               linkId: .noId,
                                               torque: .init(x: 1000, y: 1000, z: 1000),
                                               flag: EF_WORLD_FRAME)

        XCTAssertResultIsSuccess(stat2)

        client.stepSimulation()

        let stat3 = client.getActualPositionAndOrientation(multiBody: shape,
                                                           position: &pos,
                                                           orientation: &ori)

        XCTAssertResultIsSuccess(stat3)
        XCTAssertEqual(pos, .zero)
        XCTAssertNotEqual(ori, .identity)
    }
}
