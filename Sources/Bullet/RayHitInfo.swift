//
//  RayHitInfo.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

import CBullet

public struct RayHitInfo {
    public let objectUniqueId: Int32
    public let objectLinkIndex: Int32
    public let fraction: Double
    public let positionWorld: Vector3
    public let normalWorld: Vector3
}

extension RayHitInfo: Equatable { }

extension RayHitInfo {
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
