//
//  SIMD+Extensions.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

public typealias Vector3 = SIMD3<Double>
public typealias Vector4 = SIMD4<Double>

extension SIMD4 where Scalar == Double {
    public static let identity = SIMD4<Double>(x: 0, y: 0, z: 0, w: 1)
}

extension SIMD3: Sequence {
    @inlinable public __consuming func makeIterator() -> IndexingIterator<[Scalar]> {
        [x, y, z].makeIterator()
    }
}

extension SIMD4: Sequence {
    @inlinable public __consuming func makeIterator() -> IndexingIterator<[Scalar]> {
        [x, y, z, w].makeIterator()
    }
}

public protocol SIMDUnsafeScalarAccessible: SIMD {
    func unsafeScalars<Result>(_ body: (UnsafePointer<Scalar>) throws -> Result) rethrows -> Result
    mutating func unsafeMutableScalars<Result>(_ body: (UnsafeMutablePointer<Scalar>) throws -> Result) rethrows -> Result
}

extension SIMD2: SIMDUnsafeScalarAccessible {
    public func unsafeScalars<Result>(_ body: (UnsafePointer<Scalar>) throws -> Result) rethrows -> Result {
        try withUnsafePointer(to: self) {
            try $0.withMemoryRebound(to: Scalar.self, capacity: 2) {
                try body($0)
            }
        }
    }

    public mutating func unsafeMutableScalars<Result>(_ body: (UnsafeMutablePointer<Scalar>) throws -> Result) rethrows -> Result {
        try withUnsafeMutablePointer(to: &self) {
            try $0.withMemoryRebound(to: Scalar.self, capacity: 2) {
                try body($0)
            }
        }
    }
}

extension SIMD3: SIMDUnsafeScalarAccessible {
    public func unsafeScalars<Result>(_ body: (UnsafePointer<Scalar>) throws -> Result) rethrows -> Result {
        try withUnsafePointer(to: self) {
            try $0.withMemoryRebound(to: Scalar.self, capacity: 3) {
                try body($0)
            }
        }
    }

    public mutating func unsafeMutableScalars<Result>(_ body: (UnsafeMutablePointer<Scalar>) throws -> Result) rethrows -> Result {
        try withUnsafeMutablePointer(to: &self) {
            try $0.withMemoryRebound(to: Scalar.self, capacity: 3) {
                try body($0)
            }
        }
    }
}

extension SIMD4: SIMDUnsafeScalarAccessible {
    public func unsafeScalars<Result>(_ body: (UnsafePointer<Scalar>) throws -> Result) rethrows -> Result {
        try withUnsafePointer(to: self) {
            try $0.withMemoryRebound(to: Scalar.self, capacity: 4) {
                try body($0)
            }
        }
    }

    public mutating func unsafeMutableScalars<Result>(_ body: (UnsafeMutablePointer<Scalar>) throws -> Result) rethrows -> Result {
        try withUnsafeMutablePointer(to: &self) {
            try $0.withMemoryRebound(to: Scalar.self, capacity: 4) {
                try body($0)
            }
        }
    }
}
