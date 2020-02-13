//
//  SIMD+Extensions.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

extension SIMD4 where Scalar == Double {
    public static let identity = SIMD4<Double>(x: 0, y: 0, z: 0, w: 1)
}
