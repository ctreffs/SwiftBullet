//
//  BulletPhysicsClient.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

import CBullet

// https://github.com/bulletphysics/bullet3/blob/master/examples/SharedMemory/PhysicsClientExample.cpp
// https://github.com/goretkin/Bullet.jl/blob/master/src/wrap.jl
open class BulletPhysicsClient {
    @usableFromInline let clientHandle: b3PhysicsClientHandle

    let build: PhysicsCommandBuilder

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
        self.build = PhysicsCommandBuilder(clientHandle)
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

    /// Reset the simulation: remove all objects and start from an empty world.
    @discardableResult
    public final func resetSimulation() -> MemoryStatusHandleResult {
        build
            .command(b3InitResetSimulationCommand)
            .expect(CMD_RESET_SIMULATION_COMPLETED)
            .submit()
    }

    /// There can only be 1 outstanding command. Check if a command can be send.
    @inlinable
    public final var canSubmitCommand: Bool {
        b3CanSubmitCommand(clientHandle) == 1
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
    public final func removeCollisionShape(_ shapeId: CollisionShapeId) -> MemoryStatusHandleResult {
        removeCollisionShape(shapeId.rawValue)
    }

    @discardableResult
    public final func createMultiBody(collisionShape: CollisionShapeId,
                                      visualShape: VisualShapeId,
                                      mass: Double,
                                      basePosition: Vector3,
                                      baseOrientation: Vector4,
                                      baseInertialFramePosition: Vector3 = .zero,
                                      baseInertialFrameOrientation: Vector4 = .identity) -> MultiBodyId {
        let status = makeMultiBody(collisionShape: collisionShape, visualShape: visualShape, mass: mass, basePosition: basePosition, baseOrientation: baseOrientation, baseInertialFramePosition: baseInertialFramePosition, baseInertialFrameOrientation: baseInertialFrameOrientation)
        return getMultiBodyUniqueId(status)
    }

    @discardableResult
    public final func removeMultiBody(bodyId: MultiBodyId) -> MemoryStatusHandleResult {
        build
            .command { b3InitRemoveBodyCommand($0, bodyId.rawValue) }
            .expect(CMD_REMOVE_BODY_COMPLETED)
            .submit()
    }

    @discardableResult
    public final func getActualPositionAndOrientation(multiBody: MultiBodyId, position: inout Vector3, orientation: inout Vector4) -> MemoryStatusHandleResult {
        var bodyId = multiBody.rawValue
        let status = requestActualStateCommand(bodyUniqueId: bodyId)
        return getActualPlacement(status, &bodyId, &position, &orientation)
    }

    @inlinable public final var numBodies: Int {
        Int(b3GetNumBodies(clientHandle))
    }

    public final func castRay(from rayFromWorld: Vector3, to rayToWorld: Vector3) -> [RayHitInfo] {
        let status = createRaycast(rayFromWorld: rayFromWorld, rayToWorld: rayToWorld)
        guard case .success = status else {
            return []
        }
        return getRaycastInfo()
    }

    public final func castRays(from rayFromWorld: [Vector3], to rayToWorld: [Vector3], threads numOfThreads: Threads) -> [RayHitInfo] {
        let status = createRaycastBatch(from: rayFromWorld, to: rayToWorld, numThreads: numOfThreads.rawValue)
        guard case .success = status else {
            return []
        }
        return getRaycastInfo()
    }

    /// Apply external force at the body (or link) center of mass, in world space/Cartesian coordinates.
    @discardableResult
    public final func applyExternalForce(bodyId: MultiBodyId, linkId: LinkId, force: Vector3, position: Vector3, flag: EnumExternalForceFlags = EF_WORLD_FRAME) -> MemoryStatusHandleResult {
        applyExternalForce(bodyUniqueId: bodyId.rawValue,
                           linkId: linkId.rawValue,
                           force: force,
                           position: position,
                           flag: Int32(flag.rawValue))
    }

    /// Apply external force at the body (or link) center of mass, in world space/Cartesian coordinates.
    @discardableResult
    public final func applyExternalTorque(bodyId: MultiBodyId, linkId: LinkId, torque: Vector3, flag: EnumExternalForceFlags = EF_WORLD_FRAME) -> MemoryStatusHandleResult {
        applyExternalTorque(bodyUniqueId: bodyId.rawValue,
                            linkId: linkId.rawValue,
                            torque: torque,
                            flag: Int32(flag.rawValue))
    }

    @discardableResult
    public final func getAABB(bodyId: MultiBodyId, linkId: LinkId, aabbMin: inout Vector3, aabbMax: inout Vector3) -> MemoryStatusHandleResult {
        let status = requestCollisionInfo(bodyUniqueId: bodyId.rawValue)

        return getStatusAABB(bodyUniqueId: status,
                             linkUniqueId: linkId.rawValue,
                             aabbMin: &aabbMin,
                             aabbMax: &aabbMax)
    }

    @discardableResult
    public final func setDynamics(bodyId: MultiBodyId, linkId: LinkId, dynamics: [ChangeDynamicsInfo]) -> MemoryStatusHandleResult {
        setDynamicsInfo(bodyUniqueId: bodyId.rawValue, linkIndex: linkId.rawValue, changes: dynamics)
    }

    public final func getDynamics(bodyId: MultiBodyId, linkId: LinkId) -> DynamicsInfo? {
        getDynamicsInfo(bodyUniqueId: bodyId.rawValue, linkIndex: linkId.rawValue)
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

    public enum Threads: RawRepresentable {
        case auto
        case single
        case count(Int)

        public init(rawValue: Int32) {
            switch rawValue {
            case 0:
                self = .auto

            case 1:
                self = .single

            default:
                self = .count(Int(rawValue))
            }
        }

        public var rawValue: Int32 {
            switch self {
            case .auto:
                return 0

            case .single:
                return 1

            case let .count(count):
                return Int32(count)
            }
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

    final func removeCollisionShape(_ collisionShapeId: Int32) -> MemoryStatusHandleResult {
        build
            .command { b3InitRemoveCollisionShapeCommand($0, collisionShapeId) }
            .expect(CMD_REMOVE_BODY_COMPLETED)
            .submit()
    }

    final func getCollisionShapeUniqueId(_ status: MemoryStatusHandleResult) -> CollisionShapeId {
        CollisionShapeId(rawValue: status.id { b3GetStatusCollisionShapeUniqueId($0) })
    }

    final func getMultiBodyUniqueId(_ status: MemoryStatusHandleResult) -> MultiBodyId {
        MultiBodyId(rawValue: status.id { b3GetStatusBodyIndex($0) })
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

    func makeMultiBody(collisionShape: CollisionShapeId,
                       visualShape: VisualShapeId,
                       mass: Double,
                       basePosition: Vector3,
                       baseOrientation: Vector4,
                       baseInertialFramePosition: Vector3,
                       baseInertialFrameOrientation: Vector4) -> MemoryStatusHandleResult {
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

    func createRaycast(rayFromWorld: Vector3, rayToWorld: Vector3) -> MemoryStatusHandleResult {
        build
            .command { b3CreateRaycastCommandInit($0, rayFromWorld.x, rayFromWorld.y, rayFromWorld.z, rayToWorld.x, rayToWorld.y, rayToWorld.z) }
            .expect(CMD_REQUEST_RAY_CAST_INTERSECTIONS_COMPLETED)
            .submit()
    }

    func getRaycastInfo() -> [RayHitInfo] {
        var raycastInfo = b3RaycastInformation()
        b3GetRaycastInformation(clientHandle, &raycastInfo)
        let numHits = Int(raycastInfo.m_numRayHits)
        guard numHits > 0 else {
            return []
        }
        return [b3RayHitInfo](UnsafeBufferPointer<b3RayHitInfo>(start: raycastInfo.m_rayHits, count: numHits))
            .compactMap {
                guard $0.m_hitObjectUniqueId > -1 || $0.m_hitObjectLinkIndex > -1 else {
                    // NOTE: this fixes an issue where a strange
                    // hit object appears when raycast does not hit anything.
                    return nil
                }
                return RayHitInfo($0)
            }
    }

    /// <#Description#>
    /// - Parameters:
    ///   - raysFromWorld: <#raysFromWorld description#>
    ///   - raysToWorld: <#raysToWorld description#>
    ///   - numThreads: Sets the number of threads to use to compute the ray intersections for the batch.
    ///   Specify 0 to let Bullet decide, 1 (default) for single core execution, 2 or more to select the number of threads to use.
    func createRaycastBatch(from raysFromWorld: [Vector3], to raysToWorld: [Vector3], numThreads: Int32) -> MemoryStatusHandleResult {
        precondition(raysFromWorld.count == raysToWorld.count)

        let numRays = Int32(raysFromWorld.count)

        // SIMD3 values are stored in a SIMD4Storage,
        // so you can not directly map their memory, hence the flapMap here
        var raysFromWorldValues: [Double] = raysFromWorld.flatMap { $0 }
        var raysToWorldValues: [Double]   = raysToWorld.flatMap { $0 }

        return build
            .command(b3CreateRaycastBatchCommandInit)
            .apply { b3RaycastBatchSetNumThreads($0, numThreads) }
            .apply { b3RaycastBatchAddRays(clientHandle, $0, &raysFromWorldValues, &raysToWorldValues, numRays) }
            .expect(CMD_REQUEST_RAY_CAST_INTERSECTIONS_COMPLETED)
            .submit()

        // b3RaycastBatchSetParentObject(<#T##commandHandle: b3SharedMemoryCommandHandle!##b3SharedMemoryCommandHandle!#>, <#T##parentObjectUniqueId: Int32##Int32#>, <#T##parentLinkIndex: Int32##Int32#>)
    }

    func applyExternalForce(bodyUniqueId: Int32, linkId: Int32, force: Vector3, position: Vector3, flag: Int32) -> MemoryStatusHandleResult {
        force.unsafeScalars { forcePtr in
            position.unsafeScalars { positionPtr in
                build
                    .command(b3ApplyExternalForceCommandInit)
                    .apply { b3ApplyExternalForce($0, bodyUniqueId, linkId, forcePtr, positionPtr, flag) }
                    .expect(CMD_CLIENT_COMMAND_COMPLETED)
                    .submit()
            }
        }
    }

    func applyExternalTorque(bodyUniqueId: Int32, linkId: Int32, torque: Vector3, flag: Int32) -> MemoryStatusHandleResult {
        torque.unsafeScalars { torquePtr in
            build
                .command(b3ApplyExternalForceCommandInit)
                .apply { b3ApplyExternalTorque($0, bodyUniqueId, linkId, torquePtr, flag) }
                .expect(CMD_CLIENT_COMMAND_COMPLETED)
                .submit()
        }
    }

    func setDynamicsInfo(bodyUniqueId: Int32, linkIndex: Int32, changes: [ChangeDynamicsInfo]) -> MemoryStatusHandleResult {
        build
            .command { b3GetDynamicsInfoCommandInit($0, bodyUniqueId, linkIndex) }
            .injectWith(bodyIndex: bodyUniqueId, linkIndex: linkIndex, changes.map { $0.closure })
            .expect(CMD_GET_DYNAMICS_INFO_COMPLETED)
            .submit()
    }

    func getDynamicsInfo(bodyUniqueId: Int32, linkIndex: Int32) -> DynamicsInfo? {
        let status = build
            .command { b3GetDynamicsInfoCommandInit($0, bodyUniqueId, linkIndex) }
            .expect(CMD_GET_DYNAMICS_INFO_COMPLETED)
            .submit()
        guard case .success = status else {
            return nil
        }

        var info = b3DynamicsInfo()
        let result = status
            .command { b3GetDynamicsInfo($0, &info) }

        guard case .success = result else {
            return nil
        }
        return DynamicsInfo(info)
    }

    func getStatusAABB(bodyUniqueId: MemoryStatusHandleResult, linkUniqueId: Int32, aabbMin: inout Vector3, aabbMax: inout Vector3) -> MemoryStatusHandleResult {
        aabbMin.unsafeMutableScalars { minPtr in
            aabbMax.unsafeMutableScalars { maxPtr in
                bodyUniqueId
                    .command { b3GetStatusAABB($0, linkUniqueId, minPtr, maxPtr) }
            }
        }
    }
}
