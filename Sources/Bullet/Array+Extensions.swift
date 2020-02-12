//
//  Array+Extensions.swift
//
//
//  Created by Christian Treffs on 12.02.20.
//

extension Array where Element: Numeric {
    public mutating func unsafeMutableElementPointer<R>(_ body: (UnsafeMutablePointer<UnsafePointer<Element>?>) throws -> R ) rethrows -> R {
        try self.withUnsafeBufferPointer { outerPtr in
            var base = outerPtr.baseAddress
            return try withUnsafeMutablePointer(to: &base) { inner in
                try body(inner)
            }
        }
    }
}
