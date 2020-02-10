//
//  File.swift
//
//
//  Created by Christian Treffs on 10.02.20.
//

import CBullet

public struct StepSimulation: PhysicsCommand {
    public func makeCommand(_ build: PhysicsCommandBuilder) -> PhysicsCommandBuilder.Executable {
        build
            .command(b3InitStepSimulationCommand)
            .expect(CMD_STEP_FORWARD_SIMULATION_COMPLETED)
    }
}

public struct RequestCollisionInfo: PhysicsCommand {
    public let bodyUniqueId: Int32

    public init(_ bodyUniqueId: Int32) {
        self.bodyUniqueId = bodyUniqueId
    }
    public func makeCommand(_ build: PhysicsCommandBuilder) -> PhysicsCommandBuilder.Executable {
        build
            .command { b3RequestCollisionInfoCommandInit($0, bodyUniqueId) }
            .expect(CMD_REQUEST_COLLISION_INFO_COMPLETED)
    }
}

public struct BoxShape: PhysicsCommand {
    public var startPosition: SIMD3<Double>
    public var startOrientation: SIMD4<Double>

    public init(position: SIMD3<Double>, orientation: SIMD4<Double>) {
        self.startPosition = position
        self.startOrientation = orientation
    }

    public func makeCommand(_ build: PhysicsCommandBuilder) -> PhysicsCommandBuilder.Executable {
        build
            .command(b3CreateBoxShapeCommandInit)
            .set { b3CreateBoxCommandSetStartPosition($0, startPosition.x, startPosition.y, startPosition.z) }
            .set { b3CreateBoxCommandSetStartOrientation($0, startOrientation.x, startOrientation.y, startOrientation.z, startOrientation.w) }
            .expect(CMD_RIGID_BODY_CREATION_COMPLETED)
    }
}
