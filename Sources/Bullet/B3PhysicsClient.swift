//
//  B3PhysicsClient.swift
//  SwiftBullet
//
//  Created by Christian Treffs on 04.03.19.
//

import CBullet

// swiftlint:disable identifier_name
open class B3PhysicsClient {
    public enum Error: Swift.Error {
        case couldNotConnectToPhysics(String)
        case commandFailed(Int32)
        case commandFailedWithStatus(EnumSharedMemoryServerStatus)
        case couldNotCreateCommand
        case moreThanOneCommandOutstanding
        case pointerNil
        case usageFailure(String)
    }

    private let __hPhysicsClient: b3PhysicsClientHandle
    private var hPhysicsClient: b3PhysicsClientHandle {
        guard canSubmitCommand else {
            b3DisconnectSharedMemory(__hPhysicsClient)
            fatalError("physics is broken")
        }
        return __hPhysicsClient
    }

    /// Create TCP physics connection.
    /// Send physics commands using TCP networking.
    public convenience init(TCP hostName: String, _ port: UInt16) throws {
        let cHostName = hostName.withCString { $0 }
        guard let hPhysicsClient = b3ConnectPhysicsTCP(cHostName, Int32(port)) else {
            throw Error.couldNotConnectToPhysics("TCP host:\(hostName) port: \(port)")
        }
        self.init(hPhysicsClient)
    }

    /// Create UDP physics connection.
    /// Send physics commands using UDP networking.
    public convenience init(UDP hostName: String, _ port: UInt16) throws {
        let cHostName = hostName.withCString { $0 }
        guard let hPhysicsClient = b3ConnectPhysicsUDP(cHostName, Int32(port)) else {
            throw Error.couldNotConnectToPhysics("UDP host:\(hostName) port: \(port)")
        }
        self.init(hPhysicsClient)
    }

    /// Create direct physics connection.
    /// Directly execute commands without transport (no shared memory, UDP, socket, grpc etc).
    public convenience init() throws {
        guard let hPhysicsClient = b3ConnectPhysicsDirect() else {
            throw Error.couldNotConnectToPhysics("direct")
        }
        self.init(hPhysicsClient)
    }

    init(_ clientHandle: b3PhysicsClientHandle) {
        self.__hPhysicsClient = clientHandle
    }

    deinit {
        b3DisconnectSharedMemory(__hPhysicsClient)
    }

    var canSubmitCommand: Bool {
        b3CanSubmitCommand(__hPhysicsClient) == 1
    }

    @discardableResult
    func submitClientCommandAndWaitStatus(_ command: b3SharedMemoryCommandHandle) throws -> (b3SharedMemoryStatusHandle, EnumSharedMemoryServerStatus) {
        let statusHandle: b3SharedMemoryStatusHandle = b3SubmitClientCommandAndWaitStatus(hPhysicsClient, command)
        let enumStatus = getStatus(enum: statusHandle)
        switch enumStatus {
        case CMD_ACTUAL_STATE_UPDATE_FAILED,
             CMD_ADD_USER_DATA_FAILED,
             CMD_BODY_INFO_FAILED,
             CMD_BULLET_DATA_STREAM_RECEIVED_FAILED,
             CMD_BULLET_LOADING_FAILED,
             CMD_BULLET_SAVING_FAILED,
             CMD_CALCULATE_INVERSE_KINEMATICS_FAILED,
             CMD_CALCULATED_INVERSE_DYNAMICS_FAILED,
             CMD_CALCULATED_JACOBIAN_FAILED,
             CMD_CALCULATED_MASS_MATRIX_FAILED,
             CMD_CAMERA_IMAGE_FAILED,
             CMD_CHANGE_TEXTURE_COMMAND_FAILED,
             CMD_CHANGE_USER_CONSTRAINT_FAILED,
             CMD_COLLISION_SHAPE_INFO_FAILED,
             CMD_CONTACT_POINT_INFORMATION_FAILED,
             CMD_CREATE_COLLISION_SHAPE_FAILED,
             CMD_CREATE_MULTI_BODY_FAILED,
             CMD_CREATE_VISUAL_SHAPE_FAILED,
             CMD_CUSTOM_COMMAND_FAILED,
             CMD_DEBUG_LINES_OVERFLOW_FAILED,
             CMD_GET_DYNAMICS_INFO_FAILED,
             CMD_LOAD_SOFT_BODY_FAILED,
             CMD_LOAD_TEXTURE_FAILED,
             CMD_MJCF_LOADING_FAILED,
             CMD_REMOVE_BODY_FAILED,
             CMD_REMOVE_USER_CONSTRAINT_FAILED,
             CMD_REMOVE_USER_DATA_FAILED,
             CMD_REQUEST_AABB_OVERLAP_FAILED,
             CMD_REQUEST_COLLISION_INFO_FAILED,
             CMD_REQUEST_INTERNAL_DATA_FAILED,
             CMD_REQUEST_KEYBOARD_EVENTS_DATA_FAILED,
             CMD_REQUEST_OPENGL_VISUALIZER_CAMERA_FAILED,
             CMD_REQUEST_USER_DATA_FAILED,
             CMD_RESTORE_STATE_FAILED,
             CMD_SAVE_STATE_FAILED,
             CMD_SAVE_WORLD_FAILED,
             CMD_SDF_LOADING_FAILED,
             CMD_STATE_LOGGING_FAILED,
             CMD_SYNC_BODY_INFO_FAILED,
             CMD_SYNC_USER_DATA_FAILED,
             CMD_URDF_LOADING_FAILED,
             CMD_USER_CONSTRAINT_FAILED,
             CMD_USER_DEBUG_DRAW_FAILED,
             CMD_VISUAL_SHAPE_INFO_FAILED,
             CMD_VISUAL_SHAPE_UPDATE_FAILED:
            throw Error.commandFailedWithStatus(enumStatus)

        default:
            return (statusHandle, enumStatus)
        }
    }

    func createBoxShapeCommand() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreateBoxShapeCommandInit(hPhysicsClient) }
    }
    func createCollisionShapeCommand() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreateCollisionShapeCommandInit(hPhysicsClient) }
    }

    func createCustomCommand() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreateCustomCommand(hPhysicsClient) }
    }

    func createMultiBodyCommand() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreateMultiBodyCommandInit(hPhysicsClient) }
    }

    func createVisualShapeCommand() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreateVisualShapeCommandInit(hPhysicsClient) }
    }

    func createPoseCommand(_ bodyUniqueId: Int32) throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreatePoseCommandInit(hPhysicsClient, bodyUniqueId) }
    }

    func createPoseCommand2(_ commandHandle: b3SharedMemoryCommandHandle, bodyUniqueId: Int32) throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreatePoseCommandInit2(commandHandle, bodyUniqueId) }
    }

    func createRaycastCommand(rayFromWorld: Vector3, rayToWorld: Vector3) throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreateRaycastCommandInit(hPhysicsClient, rayFromWorld.x, rayFromWorld.y, rayFromWorld.z, rayToWorld.x, rayToWorld.y, rayToWorld.z) }
    }

    func createRaycastBatchCommand() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreateRaycastBatchCommandInit(hPhysicsClient) }
    }

    func createSensorCommand(_ bodyUniqueId: Int32) throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3CreateSensorCommandInit(hPhysicsClient, bodyUniqueId) }
    }

    func getDynamicsInfoCommand(_ bodyUniqueId: Int32, _ linkIndex: Int32) throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3GetDynamicsInfoCommandInit(hPhysicsClient, bodyUniqueId, linkIndex) }
    }

    // b3RequestCollisionInfoCommandInit
    func requestCollisionInfoCommand(_ bodyUniqueId: Int32) throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3RequestCollisionInfoCommandInit(hPhysicsClient, bodyUniqueId) }
    }

    func initStepSimulationCommand() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3InitStepSimulationCommand(hPhysicsClient) }
    }

    func initPhysicsParamCommand() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3InitPhysicsParamCommand(hPhysicsClient) }
    }

    func changeDynamicsInfo() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3InitChangeDynamicsInfo(hPhysicsClient) }
    }

    func requestActualStateCommand(_ bodyUniqueId: Int32) throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3RequestActualStateCommandInit(hPhysicsClient, bodyUniqueId) }
    }

    /// Apply external force at the body (or link) center of mass, in world space/Cartesian coordinates.
    func applyExternalForceCommandInit() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3ApplyExternalForceCommandInit(hPhysicsClient) }
    }

    /// b3InitRemoveCollisionShapeCommand
    func removeCollisionShapeCommand(_ collisionShapeId: Int32) throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3InitRemoveCollisionShapeCommand(hPhysicsClient, collisionShapeId) }
    }

    /// b3InitRemoveBodyCommand
    func removeBodyCommand(_ bodyUniqueId: Int32) throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3InitRemoveBodyCommand(hPhysicsClient, bodyUniqueId) }
    }

    // int b3PhysicsParamSetGravity(b3SharedMemoryCommandHandle commandHandle, double gravx, double gravy, double gravz);
    func setGravity(_ commandHandle: b3SharedMemoryCommandHandle, gravity: Vector3) throws {
        try __checkSuccess { b3PhysicsParamSetGravity(commandHandle, gravity.x, gravity.y, gravity.z) }
    }

    /// int b3PhysicsParamSetRealTimeSimulation(b3SharedMemoryCommandHandle commandHandle, int enableRealTimeSimulation);
    func setRealTimeSimulation(_ commandHandle: b3SharedMemoryCommandHandle, enableRealTimeSimulation: Bool) throws {
        try __checkSuccess { b3PhysicsParamSetRealTimeSimulation(commandHandle, enableRealTimeSimulation ? 1 : 0) }
    }

    /// int b3PhysicsParamSetTimeStep(b3SharedMemoryCommandHandle commandHandle, double timeStep);
    func setTimeStep(_ commandHandle: b3SharedMemoryCommandHandle, timeStep: Double) throws {
        try __checkSuccess { b3PhysicsParamSetTimeStep(commandHandle, timeStep) }
    }

    func getStatus(enum statusHandle: b3SharedMemoryStatusHandle) -> EnumSharedMemoryServerStatus {
        EnumSharedMemoryServerStatus(rawValue: UInt32(b3GetStatusType(statusHandle)))
    }

    /// b3GetStatusBodyIndex
    func getStatusBodyIndex(_ status: b3SharedMemoryStatusHandle) -> Int32 {
        b3GetStatusBodyIndex(status)
    }

    /// b3CreateCollisionShapeAddBox
    func createCollisionShapeAddBox(_ commandHandle: b3SharedMemoryCommandHandle, halfExtends: Vector3) throws -> Int32 {
        var halfExtendsPtr = [Double](halfExtends)
        return b3CreateCollisionShapeAddBox(commandHandle, &halfExtendsPtr)
    }

    /// b3CreateCollisionShapeAddSphere
    func createCollisionShapeAddSphere(_ commandHandle: b3SharedMemoryCommandHandle, radius: Double) throws -> Int32 {
        b3CreateCollisionShapeAddSphere(commandHandle, radius)
    }

    /// b3CreateBoxCommandSetStartPosition
    func createBoxCommandSetStartPosition(_ commandHandle: b3SharedMemoryCommandHandle, startPosition pos: Vector3) throws {
        try __checkSuccess { b3CreateBoxCommandSetStartPosition(commandHandle, pos.x, pos.y, pos.z) }
    }

    /// b3CreateBoxCommandSetStartOrientation
    func createBoxCommandSetStartOrientation(_ commandHandle: b3SharedMemoryCommandHandle, startOrientation ori: Vector4) throws {
        try __checkSuccess { b3CreateBoxCommandSetStartOrientation(commandHandle, ori.x, ori.y, ori.z, ori.w) }
    }

    /// b3CreateBoxCommandSetHalfExtents
    func createBoxCommandSetHalfExtents(_ commandHandle: b3SharedMemoryCommandHandle, halfExtents: Vector3) throws {
        try __checkSuccess { b3CreateBoxCommandSetHalfExtents(commandHandle, halfExtents.x, halfExtents.y, halfExtents.z) }
    }

    /// b3GetDynamicsInfo
    func getDynamicsInfo(_ status: b3SharedMemoryStatusHandle, _ info: inout b3DynamicsInfo) throws {
        try __checkSuccess { b3GetDynamicsInfo(status, &info) }
    }

    /// b3GetStatusAABB
    func getStatusAABB(_ status: b3SharedMemoryStatusHandle, _ linkIndex: Int32, aabbMin: inout [Double] /*3*/, aabbMax: inout [Double] /*3*/) throws {
        try __checkSuccess { b3GetStatusAABB(status, linkIndex, &aabbMin, &aabbMax) }
    }

    /// b3ChangeDynamicsInfoSetMass
    func changeDynamicsInfoSetMass(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, mass: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetMass(commandHandle, bodyUniqueId, linkIndex, mass) }
    }

    /// b3ChangeDynamicsInfoSetLocalInertiaDiagonal
    func changeDynamicsInfoSetLocalInertiaDiagonal(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, localInertiaDiagonal: inout Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetLocalInertiaDiagonal(commandHandle, bodyUniqueId, linkIndex, &localInertiaDiagonal) }
    }

    /// b3ChangeDynamicsInfoSetLateralFriction
    func changeDynamicsInfoSetLateralFriction(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, lateralFriction: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetLateralFriction(commandHandle, bodyUniqueId, linkIndex, lateralFriction) }
    }

    /// b3ChangeDynamicsInfoSetSpinningFriction
    func changeDynamicsInfoSetSpinningFriction(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, friction: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetSpinningFriction(commandHandle, bodyUniqueId, linkIndex, friction) }
    }

    /// b3ChangeDynamicsInfoSetRollingFriction
    func changeDynamicsInfoSetRollingFriction(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, friction: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetRollingFriction(commandHandle, bodyUniqueId, linkIndex, friction) }
    }

    /// b3ChangeDynamicsInfoSetLinearDamping
    func changeDynamicsInfoSetLinearDamping(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, linearDamping: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetLinearDamping(commandHandle, bodyUniqueId, linearDamping) }
    }

    /// b3ChangeDynamicsInfoSetAngularDamping
    func changeDynamicsInfoSetAngularDamping(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, angularDamping: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetAngularDamping(commandHandle, bodyUniqueId, angularDamping) }
    }

    /// b3ChangeDynamicsInfoSetJointDamping
    /*func changeDynamicsInfoSetJointDamping() throws {
     try __checkSuccess { b3ChangeDynamicsInfoSet }
     }*/

    /// b3ChangeDynamicsInfoSetRestitution
    func changeDynamicsInfoSetRestitution(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, restitution: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetRestitution(commandHandle, bodyUniqueId, linkIndex, restitution) }
    }

    /// b3ChangeDynamicsInfoSetContactStiffnessAndDamping
    func changeDynamicsInfoSetContactStiffnessAndDamping(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, contactStiffness: Double, contactDamping: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetContactStiffnessAndDamping(commandHandle, bodyUniqueId, linkIndex, contactStiffness, contactDamping) }
    }

    /// b3ChangeDynamicsInfoSetFrictionAnchor
    func changeDynamicsInfoSetFrictionAnchor(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, frictionAnchor: Int32) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetFrictionAnchor(commandHandle, bodyUniqueId, linkIndex, frictionAnchor) }
    }

    /// b3ChangeDynamicsInfoSetCcdSweptSphereRadius
    func changeDynamicsInfoSetCcdSweptSphereRadius(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, ccdSweptSphereRadius: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetCcdSweptSphereRadius(commandHandle, bodyUniqueId, linkIndex, ccdSweptSphereRadius) }
    }

    /// b3ChangeDynamicsInfoSetActivationState
    func changeDynamicsInfoSetActivationState(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, activationState: Int32) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetActivationState(commandHandle, bodyUniqueId, activationState) }
    }

    /// b3ChangeDynamicsInfoSetContactProcessingThreshold
    func changeDynamicsInfoSetContactProcessingThreshold(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, contactProcessingThreshold: Double) throws {
        try __checkSuccess { b3ChangeDynamicsInfoSetContactProcessingThreshold(commandHandle, bodyUniqueId, linkIndex, contactProcessingThreshold) }
    }

    func applyExternalForce(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, force: inout [Double], position: inout [Double], flag: Int32) {
        b3ApplyExternalForce(commandHandle, bodyUniqueId, linkIndex, &force, &position, flag)
    }

    func applyExternalTorque(_ commandHandle: b3SharedMemoryCommandHandle, _ bodyUniqueId: Int32, _ linkIndex: Int32, torque: inout [Double], flag: Int32) {
        b3ApplyExternalTorque(commandHandle, bodyUniqueId, linkIndex, &torque, flag)
    }

    /// b3GetStatusActualState
    func getStatusActualState(_ status: b3SharedMemoryStatusHandle, bodyUniqueId: inout Int32) throws -> (position: Vector3, orientation: Vector4) {
        var numDegreeOfFreedomQ: Int32 = -1
        var actualStateQPtr = UnsafeMutablePointer<UnsafePointer<Double>?>.allocate(capacity: 7)
        defer { actualStateQPtr.deallocate() }

        let result = b3GetStatusActualState(status,
                                            &bodyUniqueId,
                                            &numDegreeOfFreedomQ,
                                            nil,
                                            nil,
                                            actualStateQPtr,
                                            nil,
                                            nil)

        guard result == 1,
            numDegreeOfFreedomQ == 7,
            let actualStateQ = actualStateQPtr.pointee else {
                throw Error.commandFailed(result)
        }

        let position = Vector3(actualStateQ[0],
                               actualStateQ[1],
                               actualStateQ[2])

        let orientation = Vector4(actualStateQ[3],
                                  actualStateQ[4],
                                  actualStateQ[5],
                                  actualStateQ[6])

        return (position: position, orientation: orientation)
    }

    /// b3CreateCollisionShapeSetChildTransform
    func createCollisionShapeSetChildTransform(_ commandHandle: b3SharedMemoryCommandHandle, shapeIndex: Int32, childPosition: Vector3, childOrientation: Vector4) {
        var childPosPtr = [Double](childPosition)
        var childOriPtr = [Double](childOrientation)
        b3CreateCollisionShapeSetChildTransform(commandHandle, shapeIndex, &childPosPtr, &childOriPtr)
    }

    /// b3GetStatusCollisionShapeUniqueId
    func getStatusCollisionShapeUniqueId(_ status: b3SharedMemoryStatusHandle) -> Int32 {
        b3GetStatusCollisionShapeUniqueId(status)
    }

    /// b3GetRaycastInformation
    func getRaycastInformation() -> [RayHitInfo] {
        var raycastInfo = b3RaycastInformation()
        b3GetRaycastInformation(hPhysicsClient, &raycastInfo)

        let numRayHits = Int(raycastInfo.m_numRayHits)

        var info: [RayHitInfo] = [RayHitInfo]()
        info.reserveCapacity(numRayHits)
        for idx in 0..<numRayHits {
            let hitInfo = raycastInfo.m_rayHits[idx]
            info.append(RayHitInfo(hitInfo))
        }
        return info
    }

    /// b3RaycastBatchSetNumThreads
    func raycastBatchSetNumThreads(_ commandHandle: b3SharedMemoryCommandHandle, numThreads: Int32) {
        b3RaycastBatchSetNumThreads(commandHandle, numThreads)
    }

    func raycastBatchAddRays(_ commandHandle: b3SharedMemoryCommandHandle,
                             from raysFromWorld: [Vector3],
                             to raysToWorld: [Vector3]) throws {
        guard raysToWorld.count == raysFromWorld.count else {
            throw Error.usageFailure("Count of raysFromWorld need to be equal to count of raysToWorld.")
        }

        let flatRaysFromWorld: [Double] = raysFromWorld.reduce([]) { $0 + [Double]($1) }
        let numRays = Int32(flatRaysFromWorld.count)
        try flatRaysFromWorld.withUnsafeBufferPointer { rayFromWorldPtr in
            guard let rfrom = rayFromWorldPtr.baseAddress else {
                throw Error.pointerNil
            }

            let flatRaysToWorld: [Double] = raysToWorld.reduce([]) { $0 + [Double]($1) }

            try flatRaysToWorld.withUnsafeBufferPointer { rayToWorldPtr in
                guard let rto = rayToWorldPtr.baseAddress else {
                    throw Error.pointerNil
                }

                b3RaycastBatchAddRays(hPhysicsClient,
                                      commandHandle,
                                      rfrom,
                                      rto,
                                      numRays)
            }
        }
    }

    /// b3RaycastBatchSetParentObject
    func raycastBatchSetParentObject(_ commandHandle: b3SharedMemoryCommandHandle,
                                     parentUniqueId: Int32,
                                     parentLinkIndex: Int32) {
        b3RaycastBatchSetParentObject(commandHandle,
                                      parentUniqueId,
                                      parentLinkIndex)
    }

    /// b3GetNumBodies
    func getNumBodies() -> Int32 {
        b3GetNumBodies(hPhysicsClient)
    }

    /// b3InitResetSimulationCommand
    func resetSimulationCommand() throws -> b3SharedMemoryCommandHandle {
        try __createCommand { b3InitResetSimulationCommand(hPhysicsClient) }
    }
}

public struct RayHitInfo {
    public let objectUniqueId: Int32
    public let objectLinkIndex: Int32
    public let fraction: Double
    public let positionWorld: Vector3
    public let normalWorld: Vector3

    internal init(_ info: b3RayHitInfo) {
        objectUniqueId = info.m_hitObjectUniqueId
        objectLinkIndex = info.m_hitObjectLinkIndex
        fraction = info.m_hitFraction
        positionWorld = Vector3(info.m_hitPositionWorld.0,
                                info.m_hitPositionWorld.1,
                                info.m_hitPositionWorld.2)
        normalWorld = Vector3(info.m_hitNormalWorld.0,
                              info.m_hitNormalWorld.1,
                              info.m_hitNormalWorld.2)
    }
}

extension B3PhysicsClient {
    private func __createCommand(_ closure: () -> b3SharedMemoryCommandHandle?) throws -> b3SharedMemoryCommandHandle {
        guard let handle: b3SharedMemoryCommandHandle = closure() else {
            throw Error.couldNotCreateCommand
        }
        return handle
    }

    private func __checkSuccess(_ closure: () -> Int32) throws {
        let status = closure()
        guard status == 0 else {
            throw Error.commandFailed(status)
        }
    }
}
