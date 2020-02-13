//
//  BulletPhysicsClient.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

import CBullet

// https://github.com/bulletphysics/bullet3/blob/master/examples/SharedMemory/PhysicsClientExample.cpp
open class BulletPhysicsClient {
    let clientHandle: b3PhysicsClientHandle
    let cmd: PCmd
    var build: PhysicsCommandBuilder {
        cmd.build
    }

    internal var numDegreeOfFreedomQ: Int32 = -1
    internal lazy var actualStateQPtr = UnsafeMutablePointer<UnsafePointer<Double>?>.allocate(capacity: 7)

    deinit {
        actualStateQPtr.deallocate()

        b3DisconnectSharedMemory(clientHandle)
    }

    public init(_ config: Config = .direct) throws {
        var handle: b3PhysicsClientHandle?
        switch config {
        case .direct:
            handle = b3ConnectPhysicsDirect()

        case let .remoteTCP(config):
            handle = b3ConnectPhysicsTCP(config.hostName, Int32(config.port))

        case let .remoteUDP(config):
            handle = b3ConnectPhysicsUDP(config.hostName, Int32(config.port))

        case let .sharedMemory(config):
            handle = b3ConnectSharedMemory(config.sharedMemoryKey)
        }

        guard let clientHandle = handle else {
            throw Error.failedToInitializeWithConfig(config)
        }

        self.clientHandle = clientHandle
        self.cmd = PCmd(clientHandle)
    }

    @discardableResult
    public final func setPhysicsParameters(_ parameters: [PhysicsParameter]) -> MemoryStatusHandleResult {
        build
            .command(b3InitPhysicsParamCommand)
            .inject(parameters.map { $0.closure })
            .expect(CMD_CLIENT_COMMAND_COMPLETED)
            .submit()
    }

    @discardableResult
    public final func stepSimulation() -> MemoryStatusHandleResult {
        build
            .command(b3InitStepSimulationCommand)
            .expect(CMD_STEP_FORWARD_SIMULATION_COMPLETED)
            .submit()
    }

    @discardableResult
    public final func createCollisionShapeBox(position: Vector3 = .zero, orienation: Vector4 = .identity, halfExtents: Vector3) -> CollisionShapeId {
        let status = createCollisionShape(.box(position: position, orientation: orienation, halfExtents: halfExtents))
        return getCollisionShapeUniqueId(status)
    }

    @discardableResult
    public final func createCollisionShapeSphere(position: Vector3 = .zero, orienation: Vector4 = .identity, radius: Double) -> CollisionShapeId {
        let status = createCollisionShape(.sphere(position: position, orientation: orienation, radius: radius))
        return getCollisionShapeUniqueId(status)
    }

    @discardableResult
    public final func createCollisionShapeCapsule(position: Vector3 = .zero, orienation: Vector4 = .identity, radius: Double, height: Double) -> CollisionShapeId {
        let status = createCollisionShape(.capsule(position: position, orientation: orienation, radius: radius, height: height))
        return getCollisionShapeUniqueId(status)
    }

    @discardableResult
    public final func createMultiBody(collisionShape: CollisionShapeId,
                                      visualShape: VisualShapeId,
                                      mass: Double,
                                      basePosition: Vector3 = .zero,
                                      baseOrientation: Vector4 = .identity,
                                      baseInertialFramePosition: Vector3 = .zero,
                                      baseInertialFrameOrientation: Vector4 = .identity) -> MemoryStatusHandleResult {
        basePosition.unsafeScalars { basePosPtr in
            baseOrientation.unsafeScalars { baseOriPtr in
                baseInertialFramePosition.unsafeScalars { baseInertialFramePosPtr in
                    baseInertialFrameOrientation.unsafeScalars { baseInertialFrameOriPtr in
                        build
                            .command(b3CreateMultiBodyCommandInit)
                            .set { b3CreateMultiBodyBase($0,
                                                         mass,
                                                         collisionShape.rawValue,
                                                         visualShape.rawValue,
                                                         basePosPtr,
                                                         baseOriPtr,
                                                         baseInertialFramePosPtr,
                                                         baseInertialFrameOriPtr)
                            }
                            .expect(CMD_CREATE_MULTI_BODY_COMPLETED)
                            .submit()
                    }
                }
            }
        }
    }
}

// MARK: - Error
extension BulletPhysicsClient {
    public enum Error: Swift.Error {
        case failedToInitializeWithConfig(Config)
    }
}

// MARK: - Config
extension BulletPhysicsClient {
    public enum Config {
        case direct
        case remoteTCP(RemoteConfig)
        case remoteUDP(RemoteConfig)
        case sharedMemory(SharedMemoryConfig)
    }

    public struct RemoteConfig {
        public let port: UInt
        public let hostName: String

        public init(_ hostName: String, _ port: UInt) {
            self.port = port
            self.hostName = hostName
        }
    }

    public struct SharedMemoryConfig {
        public let sharedMemoryKey: Int32

        public init(_ sharedMemoryKey: Int32) {
            self.sharedMemoryKey = sharedMemoryKey
        }
    }
}

// MARK: - internal API
extension BulletPhysicsClient {
    final func createCollisionShape(_ shapes: CollisionShape...) -> MemoryStatusHandleResult {
        build
            .command(b3CreateCollisionShapeCommandInit)
            .injectIndexed(shapes.map { $0.closure })
            .expect(CMD_CREATE_COLLISION_SHAPE_COMPLETED)
            .submit()
    }

    final func getCollisionShapeUniqueId(_ status: MemoryStatusHandleResult) -> CollisionShapeId {
        CollisionShapeId(rawValue: status.id { b3GetStatusCollisionShapeUniqueId($0) })
    }

    func requestCollisionInfo(bodyUniqueId: Int32) -> MemoryStatusHandleResult {
        build
            .command { b3RequestCollisionInfoCommandInit($0, bodyUniqueId) }
            .expect(CMD_REQUEST_COLLISION_INFO_COMPLETED)
            .submit()
    }

    func requestActualStateCommand(bodyUniqueId: Int32) -> MemoryStatusHandleResult {
        build
            .command { b3RequestActualStateCommandInit($0, bodyUniqueId) }
            .expect(CMD_ACTUAL_STATE_UPDATE_COMPLETED)
            .submit()
    }

    func getActualPlacement(_ statusHandle: MemoryStatusHandleResult,
                            _ bodyUniqueId: inout Int32,
                            _ position: inout SIMD3<Double>,
                            _ orientation: inout SIMD4<Double>) -> MemoryStatusHandleResult {
        statusHandle
            .command(expectedStatus: 1) { handle in
                let status = b3GetStatusActualState(handle,
                                                    &bodyUniqueId,
                                                    &numDegreeOfFreedomQ,
                                                    nil,
                                                    nil,
                                                    actualStateQPtr,
                                                    nil,
                                                    nil)

                precondition(numDegreeOfFreedomQ == 7)
                let actualStateQ = actualStateQPtr.pointee!

                // position
                position[0] = actualStateQ[0]
                position[1] = actualStateQ[1]
                position[2] = actualStateQ[2]

                // orientation
                orientation[0] = actualStateQ[3]
                orientation[1] = actualStateQ[4]
                orientation[2] = actualStateQ[5]
                orientation[3] = actualStateQ[6]

                return status
            }
    }
}
