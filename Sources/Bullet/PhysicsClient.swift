//
//  PhysicsClient.swift
//  SwiftBullet
//
//  Created by Christian Treffs on 04.03.19.
//

import CBullet

public final class PhysicsClient: B3PhysicsClient {
    public func simulateStep() throws {
        let cmd = try initStepSimulationCommand()
        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_STEP_FORWARD_SIMULATION_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
    }

    public func getAABB(_ bodyUniqueId: Int32, linkIndex: Int32) throws -> (aabbMin: Vector3, aabbMax: Vector3) {
        let cmd = try requestCollisionInfoCommand(bodyUniqueId)
        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_REQUEST_COLLISION_INFO_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }

        // FIXME: I don't like it but there is currently no other bridge to C vector pointers afaik
        var min = [Double](repeating: 0, count: 3)
        var max = [Double](repeating: 0, count: 3)

        try getStatusAABB(status.0, linkIndex, aabbMin: &min, aabbMax: &max)

        return (aabbMin: Vector3(x: min[0], y: min[1], z: min[2]),
                aabbMax: Vector3(x: max[0], y: max[1], z: max[2]))
    }

    public func getPositionAndOrientation(bodyUniqueId: Int32) throws -> (position: Vector3, orientation: Vector4) {
        let cmd = try requestActualStateCommand(bodyUniqueId)
        let status = try submitClientCommandAndWaitStatus(cmd)

        guard status.1 == CMD_ACTUAL_STATE_UPDATE_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }

        var bodyUniqueId = bodyUniqueId
        return try getStatusActualState(status.0, bodyUniqueId: &bodyUniqueId)
    }

    @discardableResult
    public func setDynamicsInfo(bodyUniqueId: Int32, linkIndex: Int32, _ dynamicsInfo: DynamicsInfo...) throws -> (b3SharedMemoryStatusHandle, EnumSharedMemoryServerStatus)? {
        guard !dynamicsInfo.isEmpty else {
            // nothing to do
            return nil
        }

        let cmd = try changeDynamicsInfo()
        for info in dynamicsInfo {
            switch info {
            case let .mass(mass):
                try changeDynamicsInfoSetMass(cmd, bodyUniqueId, linkIndex, mass: mass)

            case let .lateralFriction(latFric):
                try changeDynamicsInfoSetLateralFriction(cmd, bodyUniqueId, linkIndex, lateralFriction: latFric)

            case let .spinningFriction(spinFric):
                try changeDynamicsInfoSetSpinningFriction(cmd, bodyUniqueId, linkIndex, friction: spinFric)

            case let .rollingFriction(rolFric):
                try changeDynamicsInfoSetRollingFriction(cmd, bodyUniqueId, linkIndex, friction: rolFric)

            case let .restitution(res):
                try changeDynamicsInfoSetRestitution(cmd, bodyUniqueId, linkIndex, restitution: res)

            case let .linearDamping(linDam):
                try changeDynamicsInfoSetLinearDamping(cmd, bodyUniqueId, linearDamping: linDam)

            case let .angularDamping(anDam):
                try changeDynamicsInfoSetAngularDamping(cmd, bodyUniqueId, angularDamping: anDam)

            case let .contact(stiffness, damping):
                try changeDynamicsInfoSetContactStiffnessAndDamping(cmd, bodyUniqueId, linkIndex, contactStiffness: stiffness, contactDamping: damping)

            case let .ccdSweptSphereRadius(radius):
                try changeDynamicsInfoSetCcdSweptSphereRadius(cmd, bodyUniqueId, linkIndex, ccdSweptSphereRadius: radius)

            case let .activationState(state):
                try changeDynamicsInfoSetActivationState(cmd, bodyUniqueId, activationState: state)

            case .jointDamping:
                fatalError("missing")
            }
        }

        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_CLIENT_COMMAND_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
        return status
    }

    public func getDynamicsInfo(bodyUniqueId: Int32, linkIndex: Int32) throws -> b3DynamicsInfo {
        let cmd = try getDynamicsInfoCommand(bodyUniqueId, linkIndex)
        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_GET_DYNAMICS_INFO_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
        var info = b3DynamicsInfo()
        try getDynamicsInfo(status.0, &info)
        return info
    }

    public func setPhysicsEngineParameters(_ parameters: EngineParameter...) throws {
        guard !parameters.isEmpty else {
            return
        }

        let cmd = try initPhysicsParamCommand()

        for param in parameters {
            switch param {
            case let .fixedTimeStep(timeStep):
                try setTimeStep(cmd, timeStep: timeStep)

            case let .gravity(grav):
                try setGravity(cmd, gravity: grav)

            case let .realTimeSimulation(enabled):
                try setRealTimeSimulation(cmd, enableRealTimeSimulation: enabled)

            default:
                fatalError("not implemented")
            }
        }

        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_CLIENT_COMMAND_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
    }

    public func createShapeBox(halfExtents: Vector3, at position: Vector3, orientation: Vector4 = [0, 0, 0, 1]) throws -> Int32 {
        let cmd = try createBoxShapeCommand()
        // ret = b3CreateBoxCommandSetStartPosition(command, 0, 0, -1);
        try createBoxCommandSetStartPosition(cmd, startPosition: position)
        //ret = b3CreateBoxCommandSetStartOrientation(command, 0, 0, 0, 1);
        try createBoxCommandSetStartOrientation(cmd, startOrientation: orientation)
        /// ret = b3CreateBoxCommandSetHalfExtents(command, 10, 10, 1);
        try createBoxCommandSetHalfExtents(cmd, halfExtents: halfExtents)

        let status = try submitClientCommandAndWaitStatus(cmd)

        guard status.1 == CMD_RIGID_BODY_CREATION_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }

        return getStatusBodyIndex(status.0)
    }

    public func createCollisionShape(_ type: CollisionShape,
                                     childPosition: Vector3 = [0, 0, 0],
                                     childOrientation: Vector4 = [0, 0, 0, 1]) throws -> Int32 {
        let cmd = try createCollisionShapeCommand()

        let shapeIndex: Int32
        switch type {
        case let .box(halfExtents: halfExtents):
            shapeIndex = try createCollisionShapeAddBox(cmd, halfExtends: halfExtents)

        case let .sphere(radius):
            shapeIndex = try createCollisionShapeAddSphere(cmd, radius: radius)
        }

        assert(shapeIndex >= 0, "shape index invalid")

        createCollisionShapeSetChildTransform(cmd, shapeIndex: shapeIndex, childPosition: childPosition, childOrientation: childOrientation)

        let status = try submitClientCommandAndWaitStatus(cmd)

        guard status.1 == CMD_CREATE_COLLISION_SHAPE_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }

        let uid = getStatusCollisionShapeUniqueId(status.0)
        return uid
    }

    public func createMultiBody(mass: Double,
                                collisionShapeUniqueId: Int32 = -1,
                                visualShapeUniqueId: Int32 = -1,
                                basePosition: Vector3,
                                baseOrientation: Vector4,
                                baseInertialFramePosition: Vector3 = [0, 0, 0],
                                baseInertialFrameOrientation: Vector4 = [0, 0, 0, 1]) throws -> Int32 {
        let cmd = try createMultiBodyCommand()

        let basePos = [Double](basePosition)
        let baseOri = [Double](baseOrientation)
        let inertialPos = [Double](baseInertialFramePosition)
        let inertialOri = [Double](baseInertialFrameOrientation)

        _ = b3CreateMultiBodyBase(cmd,
                                  mass,
                                  collisionShapeUniqueId,
                                  visualShapeUniqueId,
                                  basePos,
                                  baseOri,
                                  inertialPos,
                                  inertialOri)

        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_CREATE_MULTI_BODY_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
        let uid = getStatusBodyIndex(status.0)
        return uid
    }

    public func removeCollisionShape(_ collisionShapeUniqueId: Int32) throws {
        let cmd = try removeCollisionShapeCommand(collisionShapeUniqueId)
        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_REMOVE_BODY_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
    }

    public func removeBody(_ bodyUniqueId: Int32) throws {
        let cmd = try removeBodyCommand(bodyUniqueId)
        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_REMOVE_BODY_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
    }

    public func raycast(from rayFromWorld: Vector3, to rayToWorld: Vector3) throws -> [RayHitInfo] {
        let cmd = try createRaycastCommand(rayFromWorld: rayFromWorld, rayToWorld: rayToWorld)
        let status = try submitClientCommandAndWaitStatus(cmd)

        guard status.1 == CMD_REQUEST_RAY_CAST_INTERSECTIONS_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }

        return getRaycastInformation()
    }

    public func raycastBatch(from raysFromWorld: [Vector3],
                             to raysToWorld: [Vector3],
                             numThreads: Threads = .auto) throws -> [RayHitInfo] {
        let cmd = try createRaycastBatchCommand()

        raycastBatchSetNumThreads(cmd, numThreads: numThreads)

        try raycastBatchAddRays(cmd, from: raysFromWorld, to: raysToWorld)

        // TODO: raycastBatchSetParentObject(cmd, parentUniqueId: <#T##Int32#>, parentLinkIndex: <#T##Int32#>)

        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_REQUEST_RAY_CAST_INTERSECTIONS_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }

        return getRaycastInformation()
    }

    public func numBodies() -> Int {
        Int(self.getNumBodies())
    }

    /// "Reset the simulation: remove all objects and start from an empty world."
    public func resetSimulation() throws {
        let cmd = try resetSimulationCommand()
        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_RESET_SIMULATION_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
    }

    public func applyExternalForce(bodyUniqueId: Int32, linkIndex: Int32, force: Vector3, position: Vector3) throws {
        let cmd = try applyExternalForceCommandInit()
        var _force: [Double] = force.array
        var _position: [Double] = position.array

        // use EF_WORLD_FRAME & EF_LINK_FRAME
        applyExternalForce(cmd, bodyUniqueId, linkIndex, force: &_force, position: &_position, flag: 0)

        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_CLIENT_COMMAND_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
    }

    public func applyExternalTorque(bodyUniqueId: Int32, linkIndex: Int32, torque: Vector3) throws {
        let cmd = try applyExternalForceCommandInit()

        var _torque = torque.array

        applyExternalTorque(cmd, bodyUniqueId, linkIndex, torque: &_torque, flag: 0)

        let status = try submitClientCommandAndWaitStatus(cmd)
        guard status.1 == CMD_CLIENT_COMMAND_COMPLETED else {
            throw Error.commandFailedWithStatus(status.1)
        }
    }
}

public typealias Threads = Int32
public extension Threads {
    /// "Specify 0 to let Bullet decide,
    /// 1 (default) for single core execution,
    /// 2 or more to select the number of threads to use."},
    static let auto: Int32 = 0
    static let `default`: Int32 = 1
}

public extension PhysicsClient {
    enum DynamicsInfo {
        case activationState(Int32)
        case angularDamping(Double)
        case ccdSweptSphereRadius(Double)
        case contact(stiffness: Double, damping: Double)
        case jointDamping(Double)
        case lateralFriction(Double)
        case linearDamping(Double)
        case mass(Double)
        case restitution(Double)
        case rollingFriction(Double)
        case spinningFriction(Double)
    }

    enum EngineParameter {
        case allowedCcdPenetration(Double)
        case collisionFilterMode(Int32)
        case constraintSolverType(Int32)
        case contactBreakingThreshold(Double)
        case contactERP(Double)
        case contactSlop(Double)
        case deterministicOverlappingPairs(Int32)
        case enableConeFriction(Int32)
        case enableFileCaching(Int32)
        case enableSAT(Int32)
        case erp(Double)
        case fixedTimeStep(Double)
        case frictionERP(Double)
        case globalCFM(Double)
        case jointFeedbackMode(Int32)
        case maxNumCmdPer1ms(Int32)
        case minimumSolverIslandSize(Int32)
        case numSolverIterations(Int32)
        case numSubSteps(Int32)
        case restitutionVelocityThreshold(Double)
        case solverResidualThreshold(Double)
        case splitImpulsePenetrationThreshold(Double)
        case useSplitImpulse(Int32)
        case gravity(Vector3)
        case realTimeSimulation(Bool)
    }

    enum CollisionShape {
        case box(halfExtents: Vector3)
        case sphere(radius: Double)
    }
}
