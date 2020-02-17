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

public typealias CollisionShapeId = UniqueId<CollisionShape>
extension CollisionShapeId {
    public static let noId = CollisionShapeId(rawValue: -1)
}

public struct VisualShape {}
public typealias VisualShapeId = UniqueId<VisualShape>
extension VisualShapeId {
    public static let noId = VisualShapeId(rawValue: -1)
}

public struct MultiBody {}
public typealias MultiBodyId = UniqueId<MultiBody>
extension MultiBodyId {
    public static let noId = MultiBodyId(rawValue: -1)
}

public struct Link {}
public typealias LinkId = UniqueId<Link>
extension LinkId {
    public static let noId = LinkId(rawValue: -1)
}
