//
//  NetworkDataHandler.swift
//  Albums
//
//  Created by Noel C Perez on 12/4/21.
//

import Foundation

public struct NetworkDataHandler {
  
}

extension NetworkDataHandler {
    public struct Error: Swift.Error {
        public enum Code {
            case statusCodeError
        }
        public let code: Self.Code
        public let underlying: Swift.Error?
        
        public init(
          _ code: Self.Code,
          underlying: Swift.Error? = nil
        ) {
          self.code = code
          self.underlying = underlying
        }
    }
}

extension NetworkDataHandler: NetworkJSONHandlerDataHandler {
    public static func data(with data: Data, response: URLResponse) throws -> Data {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200...299 ~= statusCode else {
          throw Self.Error(.statusCodeError)
        }
        return data
    }
}
