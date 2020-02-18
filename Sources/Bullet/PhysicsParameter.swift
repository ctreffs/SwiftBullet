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

    public static func allowedCcdPenetration(_ allowedCcdPenetration: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParameterSetAllowedCcdPenetration($0, allowedCcdPenetration) } }
    }

    public static func constraintSolverType(_ constraintSolverType: Int32) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParameterSetConstraintSolverType($0, constraintSolverType) } }
    }

    public static func deterministicOverlappingPairs(_ deterministicOverlappingPairs: Int32) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParameterSetDeterministicOverlappingPairs($0, deterministicOverlappingPairs) } }
    }

    public static func enableSAT(_ enableSAT: Bool) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParameterSetEnableSAT($0, enableSAT ? 1 : 0) } }
    }

    public static func jointFeedbackMode(_ jointFeedbackMode: Int32) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParameterSetJointFeedbackMode($0, jointFeedbackMode) } }
    }

    public static func minimumSolverIslandSize( _ minimumSolverIslandSize: Int32) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParameterSetMinimumSolverIslandSize($0, minimumSolverIslandSize) } }
    }

    public static func collisionFilterMode(_ filterMode: Int32) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetCollisionFilterMode($0, filterMode) } }
    }

    public static func contactBreakingThreshold(_ contactBreakingThreshold: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetContactBreakingThreshold($0, contactBreakingThreshold) } }
    }

    public static func contactSlop(_ contactSlop: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetContactSlop($0, contactSlop) } }
    }

    public static func defaultContactERP(_ defaultContactERP: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetDefaultContactERP($0, defaultContactERP) } }
    }

    public static func defaultFrictionCFM(_ frictionCFM: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetDefaultFrictionCFM($0, frictionCFM) } }
    }

    public static func defaultFrictionERP(_ frictionERP: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetDefaultFrictionERP($0, frictionERP) } }
    }

    public static func defaultGlobalCFM(_ defaultGlobalCFM: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetDefaultGlobalCFM($0, defaultGlobalCFM) } }
    }

    public static func defaultNonContactERP(_ defaultNonContactERP: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetDefaultNonContactERP($0, defaultNonContactERP) } }
    }

    public static func enableConeFriction(_ enableConeFriction: Int32) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetEnableConeFriction($0, enableConeFriction) } }
    }

    public static func enableFileCaching(_ enableFileCaching: Bool) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetEnableFileCaching($0, enableFileCaching ? 1 : 0) } }
    }

    public static func restitutionVelocityThreshold(_ restitutionVelocityThreshold: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetRestitutionVelocityThreshold($0, restitutionVelocityThreshold) } }
    }

    public static func solverResidualThreshold(_ solverResidualThreshold: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetSolverResidualThreshold($0, solverResidualThreshold) } }
    }

    public static func splitImpulsePenetrationThreshold(_ splitImpulsePenetrationThreshold: Double) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetSplitImpulsePenetrationThreshold($0, splitImpulsePenetrationThreshold) } }
    }

    public static func useSplitImpulse(_ useSplitImpulse: Bool) -> PhysicsParameter {
        .init { $0.set { b3PhysicsParamSetUseSplitImpulse($0, useSplitImpulse ? 1 : 0) } }
    }
}
