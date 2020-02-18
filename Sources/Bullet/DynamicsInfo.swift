//
//  DynamicsInfo.swift
//
//
//  Created by Christian Treffs on 17.02.20.
//

import CBullet

public struct DynamicsInfo {
    public let activationState: Int
    public let angularDamping: Double
    public let ccdSweptSphereRadius: Double
    public let contactDamping: Double
    public let contactProcessingThreshold: Double
    public let contactStiffness: Double
    public let frictionAnchor: Int
    public let lateralFrictionCoeff: Double
    public let linearDamping: Double
    public let localInertialDiagonal: Vector3
    // swiftlint:disable:next large_tuple
    public let localInertialFrame: (Double, Double, Double, Double, Double, Double, Double)
    public let mass: Double
    public let restitution: Double
    public let rollingFrictionCoeff: Double
    public let spinningFrictionCoeff: Double
}

extension DynamicsInfo {
    init(_ info: b3DynamicsInfo) {
        self.activationState = Int(info.m_activationState)
        self.angularDamping = info.m_angularDamping
        self.ccdSweptSphereRadius = info.m_ccdSweptSphereRadius
        self.contactDamping = info.m_contactDamping
        self.contactProcessingThreshold = info.m_contactProcessingThreshold
        self.contactStiffness = info.m_contactStiffness
        self.frictionAnchor = Int(info.m_frictionAnchor)
        self.lateralFrictionCoeff = info.m_lateralFrictionCoeff
        self.linearDamping = info.m_linearDamping
        self.localInertialDiagonal = Vector3(info.m_localInertialDiagonal.0, info.m_localInertialDiagonal.1, info.m_localInertialDiagonal.2)
        self.localInertialFrame = info.m_localInertialFrame
        self.mass = info.m_mass
        self.restitution = info.m_restitution
        self.rollingFrictionCoeff = info.m_rollingFrictionCoeff
        self.spinningFrictionCoeff = info.m_spinningFrictionCoeff
    }
}
