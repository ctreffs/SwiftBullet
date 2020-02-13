//
//  Utils.swift
//
//
//  Created by Christian Treffs on 13.02.20.
//

import XCTest

func XCTAssertResultIsSuccess<Value, Error>(_ result: Result<Value, Error>) where Error: Swift.Error {
    switch result {
    case let .failure(error):
        XCTFail("Result is failure: \(error)")

    default:
        XCTAssertTrue(true)
    }
}

func XCTAssertResultIsFailure<Value, Error>(_ result: Result<Value, Error>) where Error: Swift.Error {
    switch result {
    case let .success(value):
        XCTFail("Result is success: \(value)")

    default:
        XCTAssertTrue(true)
    }
}

func XCTAssertResultEquals<Value, Error>(_ result: Result<Value, Error>, _ expectedResult: Result<Value, Error>) where Error: Swift.Error & Equatable, Value: Equatable {
    switch (result, expectedResult) {
    case let (.success(value), .success(expectedValue)):
        XCTAssertEqual(value, expectedValue)

    case let (.failure(error), .failure(expectedError)):
        XCTAssertEqual(error, expectedError)

    default:
        XCTFail("Unexpected result \(result) != \(expectedResult)")
    }
}
