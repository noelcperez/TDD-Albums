//
//  NetworkDataHandlerTests.swift
//  AlbumsTests
//
//  Created by Noel C Perez on 12/4/21.
//

import XCTest
import Albums

final class NetworkDataHandlerTestCase : XCTestCase {
  
}
extension NetworkDataHandlerTestCase {
    private static var errorCodes: Array<Int> {
        return Array(100...199) + Array(300...599)
    }
    
    private static var successCodes: Array<Int> {
        return Array(200...299)
    }
}

extension NetworkDataHandlerTestCase {
    func testErrorWithStatusCode() {
      for statusCode in Self.errorCodes {
        XCTAssertThrowsError(
          try NetworkDataHandler.data(
            with: DataTestDouble(),
            response: HTTPURLResponseTestDouble(statusCode: statusCode)
          ),
          "Status Code \(statusCode)"
        ) { error in
          if let error = try? XCTUnwrap(
            error as? NetworkDataHandler.Error,
            "Status Code \(statusCode)"
          ) {
            XCTAssertEqual(
              error.code,
              .statusCodeError,
              "Status Code \(statusCode)"
            )
            XCTAssertNil(
              error.underlying,
              "Status Code \(statusCode)"
            )
          }
        }
      }
    }
    
    func testSuccess() {
        for statusCode in Self.successCodes {
            XCTAssertNoThrow(
                try {
                    let data = try NetworkDataHandler.data(
                        with: DataTestDouble(),
                        response: HTTPURLResponseTestDouble(statusCode: statusCode)
                    )
                    XCTAssertEqual(data, DataTestDouble())
                }()
            )
        }
    }
}
