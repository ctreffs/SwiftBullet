//
//  SIMDUnsafeTests.swift
//
//
//  Created by Christian Treffs on 12.02.20.
//

@testable import Bullet
import XCTest

public final class SIMDUnsafeTests: XCTestCase {
    func testSIMD2UnsafePointer() {
        var vec2 = SIMD2<Double>(x: 1, y: 2)
        XCTAssertEqual(vec2.x, 1)
        XCTAssertEqual(vec2.y, 2)

        vec2.unsafeScalars { ptr in
            XCTAssertEqual(ptr[0], 1)
            XCTAssertEqual(ptr[1], 2)
        }

        vec2.unsafeMutableScalars { ptr in
            ptr[0] = 4
            ptr[1] = 5
        }

        XCTAssertEqual(vec2.x, 4)
        XCTAssertEqual(vec2.y, 5)
    }

    func testSIMD3UnsafePointer() {
        var vec3 = SIMD3<Double>(x: 1, y: 2, z: 3)
        XCTAssertEqual(vec3.x, 1)
        XCTAssertEqual(vec3.y, 2)
        XCTAssertEqual(vec3.z, 3)

        vec3.unsafeScalars { ptr in
            XCTAssertEqual(ptr[0], 1)
            XCTAssertEqual(ptr[1], 2)
            XCTAssertEqual(ptr[2], 3)
        }

        vec3.unsafeMutableScalars { ptr in
            ptr[0] = 4
            ptr[1] = 5
            ptr[2] = 6
        }

        XCTAssertEqual(vec3.x, 4)
        XCTAssertEqual(vec3.y, 5)
        XCTAssertEqual(vec3.z, 6)
    }

    func testSIMD4UnsafePointer() {
        var vec4 = SIMD4<Double>(x: 1, y: 2, z: 3, w: 4)
        XCTAssertEqual(vec4.x, 1)
        XCTAssertEqual(vec4.y, 2)
        XCTAssertEqual(vec4.z, 3)
        XCTAssertEqual(vec4.w, 4)

        vec4.unsafeScalars { ptr in
            XCTAssertEqual(ptr[0], 1)
            XCTAssertEqual(ptr[1], 2)
            XCTAssertEqual(ptr[2], 3)
            XCTAssertEqual(ptr[3], 4)
        }

        vec4.unsafeMutableScalars { ptr in
            ptr[0] = 5
            ptr[1] = 6
            ptr[2] = 7
            ptr[3] = 8
        }

        XCTAssertEqual(vec4.x, 5)
        XCTAssertEqual(vec4.y, 6)
        XCTAssertEqual(vec4.z, 7)
        XCTAssertEqual(vec4.w, 8)
    }
}
