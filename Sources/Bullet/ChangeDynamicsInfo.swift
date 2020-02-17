//
//  ChangeDynamicsInfo.swift
//
//
//  Created by Christian Treffs on 17.02.20.
//

import CBullet

public struct ChangeDynamicsInfo {
    let closure: SettableBodyIndexClosure

    init(_ closure: @escaping SettableBodyIndexClosure) {
        self.closure = closure
    }
}
extension ChangeDynamicsInfo {
    // b3ChangeDynamicsInfoSetMass
    public static func mass(_ mass: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetMass($0, bodyId, linkId, mass) } }
    }

    // b3ChangeDynamicsInfoSetActivationState
    public static func activationState(_ activationState: Int32) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetActivationState($0, bodyId, activationState) } }
    }

    // b3ChangeDynamicsInfoSetAngularDamping
    public static func angularDamping(_ angularDamping: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetAngularDamping($0, bodyId, angularDamping) } }
    }

    // TODO: more change dynamic infos
    // b3ChangeDynamicsInfoSetCcdSweptSphereRadius
    // b3ChangeDynamicsInfoSetContactProcessingThreshold
    // b3ChangeDynamicsInfoSetContactStiffnessAndDamping
    // b3ChangeDynamicsInfoSetFrictionAnchor
    // b3ChangeDynamicsInfoSetLateralFriction
    // b3ChangeDynamicsInfoSetLinearDamping
    // b3ChangeDynamicsInfoSetLocalInertiaDiagonal
    // b3ChangeDynamicsInfoSetRestitution
    // b3ChangeDynamicsInfoSetRollingFriction
    // b3ChangeDynamicsInfoSetSpinningFriction
}
