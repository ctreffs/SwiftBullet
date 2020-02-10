//
//  Shims.swift
//  SwiftBullet
//
//  Created by Christian Treffs on 04.03.19.
//

#if canImport(simd)
import simd
public typealias Vector3 = SIMD3<Double>
public typealias Vector4 = SIMD4<Double>

extension SIMD3: Sequence {
    public __consuming func makeIterator() -> IndexingIterator<[Scalar]> {
        [x, y, z].makeIterator()
    }

    public var array: [Scalar] {
        [Scalar](self)
    }
}

extension SIMD4: Sequence {
    public __consuming func makeIterator() -> IndexingIterator<[Scalar]> {
        [x, y, z, w].makeIterator()
    }

    public var array: [Scalar] {
        [Scalar](self)
    }
}

#else
public typealias Vector3 = (x: Double, y: Double, z: Double)
public typealias Vector4 = (x: Double, y: Double, z: Double, w: Double)
#endif
