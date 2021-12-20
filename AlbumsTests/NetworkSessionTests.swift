//
//  NetworkSessionTests.swift
//  AlbumsTests
//
//  Created by Noel C Perez on 12/17/21.
//

import Foundation
import XCTest

final class NetworkSessionTestCase: XCTestCase {
    private typealias NetworkSessionTestDouble = NetworkSession<URLSessionTestDouble>
    
    override func tearDown() {
        URLSessionTestDouble.shared.parameterRequest = nil
        URLSessionTestDouble.shared.parameterDelegate = nil
        URLSessionTestDouble.shared.returnData = nil
        URLSessionTestDouble.shared.returnResponse = nil
      }
    
    func testError() async {
        URLSessionTestDouble.shared.returnData = nil
        URLSessionTestDouble.shared.returnResponse = nil
        
        do {
            _ = try await NetworkSessionTestDouble.data(for: URLRequestTestDouble())
            XCTFail()
        } catch {
            XCTAssertEqual(URLSessionTestDouble.shared.parameterRequest, URLRequestTestDouble())
            XCTAssertNil(URLSessionTestDouble.shared.parameterDelegate)
            
            if let error = try? XCTUnwrap(error as NSError?) {
                XCTAssertIdentical(error, URLSessionTestDouble.shared.returnError)
            }
        }
    }
    
    func testSuccess() async {
        URLSessionTestDouble.shared.returnData = DataTestDouble()
        URLSessionTestDouble.shared.returnResponse = URLResponseTestDouble()
        
        do {
            let (data, response) = try await NetworkSessionTestDouble.data(for: URLRequestTestDouble())
            
            XCTAssertEqual(URLSessionTestDouble.shared.parameterRequest, URLRequestTestDouble())
            XCTAssertNil(URLSessionTestDouble.shared.parameterDelegate)
            XCTAssertEqual(URLSessionTestDouble.shared.returnData, data)
            XCTAssertEqual(URLSessionTestDouble.shared.returnResponse, response)
        } catch {
            XCTFail()
        }
    }
}

extension NetworkSessionTestCase {
    final private class URLSessionTestDouble: NetworkSessionURLSession {
        static let shared = URLSessionTestDouble()
        
        var parameterRequest: URLRequest?
        var parameterDelegate: URLSessionTaskDelegate?
        var returnData: Data?
        var returnResponse: URLResponse?
        let returnError = NSErrorTestDouble()
        
        func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
              self.parameterRequest = request
              self.parameterDelegate = delegate
              guard
                let returnData = self.returnData,
                let returnResponse = self.returnResponse
              else {
                throw self.returnError
              }
              return (returnData, returnResponse)
        }
    }
}
