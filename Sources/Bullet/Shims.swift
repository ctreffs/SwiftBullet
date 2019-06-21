//
//  Shims.swift
//  SwiftBullet
//
//  Created by Christian Treffs on 04.03.19.
//

#if canImport(simd)
import simd
public typealias Vector3 = simd.double3
public typealias Vector4 = simd.double4

extension SIMD3: Sequence {
    public __consuming func makeIterator() -> IndexingIterator<[Scalar]> {
        return [x, y, z].makeIterator()
    }
}

extension SIMD4: Sequence {
    public __consuming func makeIterator() -> IndexingIterator<[Scalar]> {
        return [x, y, z, w].makeIterator()
    }
}

#else
public typealias Vector3 = (x: Double, y: Double, z: Double)
public typealias Vector4 = (x: Double, y: Double, z: Double, w: Double)
#endif
