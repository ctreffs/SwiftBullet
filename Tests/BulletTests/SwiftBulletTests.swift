@testable import Bullet
import XCTest

final class SwiftBulletTests: XCTestCase {
    var client: PhysicsClient!

    override func setUp() {
        super.setUp()
        client = try? PhysicsClient()
    }

    override func tearDown() {
        client = nil
        super.tearDown()
    }

    func testSimpleGravitySim() {
        let frequency: Double = 240
        let mass: Double = 10.0
        let pos: Vector3 = [0, 100, 100]
        let ori: Vector4 = [0, 0, 0, 1]
        //let extents: Vector3 = [10, 10, 10]

        do {
            let uid = try client.createMultiBody(mass: mass, basePosition: pos, baseOrientation: ori)

            try client.setPhysicsEngineParameters(.gravity([0, 0, -9.81]),
                                                  .fixedTimeStep(1.0 / frequency))

            let (p1, o1) = try client.getPositionAndOrientation(bodyUniqueId: uid)
            XCTAssertEqual(p1, pos)
            XCTAssertEqual(o1, ori)

            for _ in 0..<Int(frequency) {
                try client.simulateStep()
            }

            let (p2, _) = try client.getPositionAndOrientation(bodyUniqueId: uid)
            XCTAssertNotEqual(p2, p1)
            XCTAssertEqual(p2, Vector3(0.0, 100.0, 95.421_646_118_164_06))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testCreateRemoveCollisionShape() {
        var sphereId: Int32 = -1

        XCTAssertNoThrow(sphereId = try client.createCollisionShape(.sphere(radius: 3.0), childPosition: [0, 0, 0], childOrientation: [0, 0, 0, 1]))
        XCTAssertNotEqual(sphereId, -1)

        XCTAssertNoThrow(try client.removeCollisionShapeCommand(sphereId))
    }

    func testSingleRayCast() {
        var hits: [RayHitInfo]!
        var cBox1: Int32!
        var cBox2: Int32!

        XCTAssertNoThrow(cBox1 = try client.createCollisionShape(.box(halfExtents: [1, 1, 1])))
        XCTAssertNoThrow(cBox2 = try client.createCollisionShape(.box(halfExtents: [1, 1, 1])))

        XCTAssertNoThrow(try client.createMultiBody(mass: 0,
                                                    collisionShapeUniqueId: cBox1,
                                                    basePosition: [0, 0, 0],
                                                    baseOrientation: [0, 0, 0, 1]))
        XCTAssertNoThrow(try client.createMultiBody(mass: 0,
                                                    collisionShapeUniqueId: cBox2,
                                                    basePosition: [0, 0, -10],
                                                    baseOrientation: [0, 0, 0, 1]))

        XCTAssertNoThrow(hits = try client.raycast(from: [0, 0, 3], to: [0, 0, -10]))
        XCTAssertFalse(hits.isEmpty)
        XCTAssertEqual(hits.count, 1)

        XCTAssertEqual(hits[0].objectUniqueId, 0)
        XCTAssertEqual(hits[0].fraction, 0.153_846_144_676_208_5)
    }

    func testBatchRayCast() {
        var hits: [RayHitInfo]!
        var cBox1: Int32!
        var cBox2: Int32!

        XCTAssertNoThrow(cBox1 = try client.createCollisionShape(.box(halfExtents: [1, 1, 1])))
        XCTAssertNoThrow(cBox2 = try client.createCollisionShape(.box(halfExtents: [1, 1, 1])))

        XCTAssertNoThrow(try client.createMultiBody(mass: 0,
                                                    collisionShapeUniqueId: cBox1,
                                                    basePosition: [0, 0, 0],
                                                    baseOrientation: [0, 0, 0, 1]))
        XCTAssertNoThrow(try client.createMultiBody(mass: 0,
                                                    collisionShapeUniqueId: cBox2,
                                                    basePosition: [0, 0, -10],
                                                    baseOrientation: [0, 0, 0, 1]))

        let from: [Vector3] = [
            [0, 0, 3], [0, 1, 3]
        ]
        let to: [Vector3] = [
            [0, 0, -10], [0, 1, -10]
        ]

        XCTAssertNoThrow(hits = try client.raycastBatch(from: from, to: to, numThreads: .auto))
        XCTAssertFalse(hits.isEmpty)
    }

    func testNumBodies() {
        _ = try? client.createMultiBody(mass: 0,
                                        basePosition: [0, 0, 0],
                                        baseOrientation: [0, 0, 0, 1])

        XCTAssertEqual(client.numBodies(), 1)
    }

    func testResetSimulation() {
        _ = try? client.createMultiBody(mass: 0,
                                        basePosition: [0, 0, 0],
                                        baseOrientation: [0, 0, 0, 1])
        XCTAssertEqual(client.numBodies(), 1)

        XCTAssertNoThrow(try client.resetSimulation())
        XCTAssertEqual(client.numBodies(), 0)
    }

    func testApplyExternalForce() {
        var cBox1: Int32 = -1
        var box1: Int32 = -1

        XCTAssertNoThrow(cBox1 = try client.createCollisionShape(.box(halfExtents: [1, 1, 1])))

        XCTAssertNoThrow(box1 = try client.createMultiBody(mass: 0,
                                                           collisionShapeUniqueId: cBox1,
                                                           basePosition: [0, 0, 0],
                                                           baseOrientation: [0, 0, 0, 1]))

        XCTAssertNoThrow(try client.applyExternalForce(bodyUniqueId: box1, linkIndex: -1, force: Vector3(1, 0, 0), position: Vector3(0, 0, 0)))
    }

    func testApplyExternalTorque() {
        var cBox1: Int32 = -1
        var box1: Int32 = -1

        XCTAssertNoThrow(cBox1 = try client.createCollisionShape(.box(halfExtents: [1, 1, 1])))

        XCTAssertNoThrow(box1 = try client.createMultiBody(mass: 0,
                                                           collisionShapeUniqueId: cBox1,
                                                           basePosition: [0, 0, 0],
                                                           baseOrientation: [0, 0, 0, 1]))

        XCTAssertNoThrow(try client.applyExternalTorque(bodyUniqueId: box1, linkIndex: -1, torque: [1, 2, 3]))
    }
}
