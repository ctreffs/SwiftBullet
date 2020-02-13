//
//  BulletPhysicsClient.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

import CBullet

// https://github.com/bulletphysics/bullet3/blob/master/examples/SharedMemory/PhysicsClientExample.cpp
open class BulletPhysicsClient {
    internal let cmd: PCmd
    internal var build: PhysicsCommandBuilder {
        cmd.build
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

        self.cmd = PCmd(clientHandle)
    }

    @discardableResult
    public final func setPhysicsParameters(_ parameters: [PhysicsParameter]) -> StatusResult {
        build
            .command(b3InitPhysicsParamCommand)
            .inject(parameters.map { $0.closure })
            .expect(CMD_CLIENT_COMMAND_COMPLETED)
            .submit()
    }

    @discardableResult
    public final func stepSimulation() -> StatusResult {
        build
            .command(b3InitStepSimulationCommand)
            .expect(CMD_STEP_FORWARD_SIMULATION_COMPLETED)
            .submit()
    }

    public final func createCollisionShape(_ shapes: CollisionShape...) -> StatusResult {
        build
            .command(b3CreateCollisionShapeCommandInit)
            .injectIndexed(shapes.map { $0.closure })
            .expect(CMD_CREATE_COLLISION_SHAPE_COMPLETED)
            .submit()
    }

    @discardableResult
    public final func createCollisionShapeBox(position: Vector3 = .zero, orienation: Vector4 = .identity, halfExtents: Vector3) -> StatusResult {
        createCollisionShape(.box(position: position, orientation: orienation, halfExtents: halfExtents))
    }

    @discardableResult
    public final func createCollisionShapeSphere(position: Vector3 = .zero, orienation: Vector4 = .identity, radius: Double) -> StatusResult {
        createCollisionShape(.sphere(position: position, orientation: orienation, radius: radius))
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
