//
//  PhysicsParameter.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

import CBullet

public struct PhysicsParameter {
    let closure: SettableClosure

    init(_ closure: @escaping SettableClosure) {
        self.closure = closure
    }
}

extension PhysicsParameter {
    // b3PhysicsParamSetGravity(_ commandHandle: b3SharedMemoryCommandHandle!, _ gravx: Double, _ gravy: Double, _ gravz: Double) -> Int32
    public static func gravity(_ gravity: Vector3) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetGravity($0, gravity.x, gravity.y, gravity.z) } }
    }

    // b3PhysicsParamSetTimeStep(_ commandHandle: b3SharedMemoryCommandHandle!, _ timeStep: Double) -> Int32
    public static func timeStep(_ timeStep: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetTimeStep($0, timeStep) } }
    }

    // b3PhysicsParamSetRealTimeSimulation(_ commandHandle: b3SharedMemoryCommandHandle!, _ enableRealTimeSimulation: Int32) -> Int32
    public static func realTimeSimulation(_ enabled: Bool) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetRealTimeSimulation($0, enabled ? 1 : 0) } }
    }

    // b3PhysicsParamSetNumSolverIterations(_ commandHandle: b3SharedMemoryCommandHandle!, _ numSolverIterations: Int32) -> Int32
    public static func numSolverIterations(_ numSolverIterations: Int) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetNumSolverIterations($0, Int32(numSolverIterations)) } }
    }

    // b3PhysicsParamSetNumSubSteps(_ commandHandle: b3SharedMemoryCommandHandle!, _ numSubSteps: Int32) -> Int32
    public static func numSubSteps(_ numSubSteps: Int) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetNumSubSteps($0, Int32(numSubSteps)) } }
    }

    // b3PhysicsParamSetMaxNumCommandsPer1ms(_ commandHandle: b3SharedMemoryCommandHandle!, _ maxNumCmdPer1ms: Int32) -> Int32
    public static func maxNumCommandsPer1ms(_ maxNumCmdPer1ms: Int) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetMaxNumCommandsPer1ms($0, Int32(maxNumCmdPer1ms)) } }
    }

    // TODO: more parameters
    // b3PhysicsParameterSetAllowedCcdPenetration(_ commandHandle: b3SharedMemoryCommandHandle!, _ allowedCcdPenetration: Double) -> Int32
    // b3PhysicsParameterSetConstraintSolverType(_ commandHandle: b3SharedMemoryCommandHandle!, _ constraintSolverType: Int32) -> Int32
    // b3PhysicsParameterSetDeterministicOverlappingPairs(_ commandHandle: b3SharedMemoryCommandHandle!, _ deterministicOverlappingPairs: Int32) -> Int32
    // b3PhysicsParameterSetEnableSAT(_ commandHandle: b3SharedMemoryCommandHandle!, _ enableSAT: Int32) -> Int32
    // b3PhysicsParameterSetJointFeedbackMode(_ commandHandle: b3SharedMemoryCommandHandle!, _ jointFeedbackMode: Int32) -> Int32
    // b3PhysicsParameterSetMinimumSolverIslandSize(_ commandHandle: b3SharedMemoryCommandHandle!, _ minimumSolverIslandSize: Int32) -> Int32
    // b3PhysicsParamSetCollisionFilterMode(_ commandHandle: b3SharedMemoryCommandHandle!, _ filterMode: Int32) -> Int32
    // b3PhysicsParamSetContactBreakingThreshold(_ commandHandle: b3SharedMemoryCommandHandle!, _ contactBreakingThreshold: Double) -> Int32
    // b3PhysicsParamSetContactSlop(_ commandHandle: b3SharedMemoryCommandHandle!, _ contactSlop: Double) -> Int32
    // b3PhysicsParamSetDefaultContactERP(_ commandHandle: b3SharedMemoryCommandHandle!, _ defaultContactERP: Double) -> Int32
    // b3PhysicsParamSetDefaultFrictionCFM(_ commandHandle: b3SharedMemoryCommandHandle!, _ frictionCFM: Double) -> Int32
    // b3PhysicsParamSetDefaultFrictionERP(_ commandHandle: b3SharedMemoryCommandHandle!, _ frictionERP: Double) -> Int32
    // b3PhysicsParamSetDefaultGlobalCFM(_ commandHandle: b3SharedMemoryCommandHandle!, _ defaultGlobalCFM: Double) -> Int32
    // b3PhysicsParamSetDefaultNonContactERP(_ commandHandle: b3SharedMemoryCommandHandle!, _ defaultNonContactERP: Double) -> Int32
    // b3PhysicsParamSetEnableConeFriction(_ commandHandle: b3SharedMemoryCommandHandle!, _ enableConeFriction: Int32) -> Int32
    // b3PhysicsParamSetEnableFileCaching(_ commandHandle: b3SharedMemoryCommandHandle!, _ enableFileCaching: Int32) -> Int32
    // b3PhysicsParamSetRestitutionVelocityThreshold(_ commandHandle: b3SharedMemoryCommandHandle!, _ restitutionVelocityThreshold: Double) -> Int32
    // b3PhysicsParamSetSolverResidualThreshold(_ commandHandle: b3SharedMemoryCommandHandle!, _ solverResidualThreshold: Double) -> Int32
    // b3PhysicsParamSetSplitImpulsePenetrationThreshold(_ commandHandle: b3SharedMemoryCommandHandle!, _ splitImpulsePenetrationThreshold: Double) -> Int32
    // b3PhysicsParamSetUseSplitImpulse(_ commandHandle: b3SharedMemoryCommandHandle!, _ useSplitImpulse: Int32) -> Int32
}
