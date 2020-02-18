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
    // b3ChangeDynamicsInfoSetCcdSweptSphereRadius
    public static func ccdSweptSphereRadius(_ ccdSweptSphereRadius: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetCcdSweptSphereRadius($0, bodyId, linkId, ccdSweptSphereRadius) } }
    }

    // b3ChangeDynamicsInfoSetContactProcessingThreshold
    public static func contactProcessingThreshold(_ contactProcessingThreshold: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetContactProcessingThreshold($0, bodyId, linkId, contactProcessingThreshold) } }
    }

    public static func contactStiffnessAndDamping (_ contactStiffness: Double, _ contactDamping: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetContactStiffnessAndDamping($0, bodyId, linkId, contactStiffness, contactDamping) } }
    }

    public static func frictionAnchor (_ frictionAnchor: Int32) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetFrictionAnchor($0, bodyId, linkId, frictionAnchor) } }
    }

    public static func lateralFriction (_ lateralFriction: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetLateralFriction($0, bodyId, linkId, lateralFriction) } }
    }

    public static func linearDamping (_ linearDamping: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetLinearDamping($0, bodyId, linearDamping) } }
    }

    public static func localInertiaDiagonal (_ localInertiaDiagonal: Vector3) -> ChangeDynamicsInfo {
        localInertiaDiagonal.unsafeScalars { vecPtr in
            .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetLocalInertiaDiagonal($0, bodyId, linkId, vecPtr) } }
        }
    }

    public static func restitution(_ restitution: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetRestitution($0, bodyId, linkId, restitution) } }
    }

    public static func rollingFriction (_ friction: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetRollingFriction($0, bodyId, linkId, friction) } }
    }

    public static func spinningFriction (_ friction: Double) -> ChangeDynamicsInfo {
        .init { build, bodyId, linkId in build.set { b3ChangeDynamicsInfoSetSpinningFriction($0, bodyId, linkId, friction) } }
    }
}
