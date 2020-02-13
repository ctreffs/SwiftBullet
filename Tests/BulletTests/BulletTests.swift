//
//  BulletTests.swift
//
//
//  Created by Christian Treffs on 11.02.20.
//

import Bullet
import CBullet
import XCTest

final class BulletTests: XCTestCase {
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
        let sphereResult = client.createCollisionShapeSphere(radius: .random(in: 0.001...1000.0))
        XCTAssertResultIsSuccess(sphereResult)

        let boxResult = client.createCollisionShapeBox(halfExtents: .random(in: 0.001...1000.0))
        XCTAssertResultIsSuccess(boxResult)
    }

    /*func testCollisionShape() {
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
     }*/
}

func XCTAssertResultIsSuccess<Value, Error>(_ result: Result<Value, Error>) where Error: Swift.Error {
    switch result {
    case let .failure(error):
        XCTFail("Result is failure: \(error)")

    default:
        XCTAssertTrue(true)
    }
}

func XCTAssertResultEquals<Value, Error>(_ result: Result<Value, Error>, _ expectedResult: Result<Value, Error>) where Error: Swift.Error & Equatable, Value: Equatable {
    switch (result, expectedResult) {
    case let (.success(value), .success(expectedValue)):
        XCTAssertEqual(value, expectedValue)

    case let (.failure(error), .failure(expectedError)):
        XCTAssertEqual(error, expectedError)

    default:
        XCTFail("Unexpected result \(result) != \(expectedResult)")
    }
}
