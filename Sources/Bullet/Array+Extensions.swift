//
//  Array+Extensions.swift
//
//
//  Created by Christian Treffs on 12.02.20.
//

extension Array {
    public mutating func unsafeMutableElementPointer<R>(_ body: (UnsafeMutablePointer<UnsafePointer<Element>?>) throws -> R ) rethrows -> R {
        try self.withUnsafeBufferPointer { outerPtr in
            var baseAddress = outerPtr.baseAddress
            return try withUnsafeMutablePointer(to: &baseAddress) { innerPtr in
                try body(innerPtr)
            }
        }
    }

    public func unsafeElementPointer<R>(_ body: (UnsafePointer<UnsafePointer<Element>?>) throws -> R ) rethrows -> R {
        try self.withUnsafeBufferPointer { outerPtr in
            try withUnsafePointer(to: outerPtr.baseAddress) { innerPtr in
                try body(innerPtr)
            }
        }
    }
}
