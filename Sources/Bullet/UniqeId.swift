//
//  UniqueId.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

public struct UniqueId<Tag>: RawRepresentable {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}

extension UniqueId: Equatable { }
extension UniqueId: Comparable {
    public static func < (lhs: UniqueId, rhs: UniqueId) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public typealias CollisionShapeId = UniqueId<CollisionShape>
extension CollisionShapeId {
    public static let noId = CollisionShapeId(rawValue: -1)
}

public typealias VisualShapeId = UniqueId<VisualShape>
extension VisualShapeId {
    public static let noId = VisualShapeId(rawValue: -1)
}
