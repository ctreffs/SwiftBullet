//
//  UnsafelyAccessible.swift
//
//
//  Created by Christian Treffs on 11.02.20.
//

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
