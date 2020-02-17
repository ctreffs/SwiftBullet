//
//  Threads.swift
//
//
//  Created by Christian Treffs on 17.02.20.
//

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
