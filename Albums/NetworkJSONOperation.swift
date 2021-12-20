//
//  NetworkJSONOperation.swift
//  Albums
//
//  Created by Noel C Perez on 12/17/21.
//

import Foundation

protocol NetworkJSONOperationSession {
    static func data(for: URLRequest) async throws -> (Data, URLResponse)
}

extension NetworkSession: NetworkJSONOperationSession where URLSession == Foundation.URLSession { }

protocol NetworkJSONOperationJSONHandler {
    associatedtype JSON
    
    static func json(with: Data, response: URLResponse) throws -> JSON
}

extension NetworkJSONHandler: NetworkJSONOperationJSONHandler where DataHandler == NetworkDataHandler, JSONSerialization == Foundation.JSONSerialization { }

struct NetworkJSONOperation<Session: NetworkJSONOperationSession, JSONHandler: NetworkJSONOperationJSONHandler> {
    struct Error : Swift.Error {
        enum Code {
          case sessionError
          case jsonHandlerError
        }
        
        let code: Self.Code
        let underlying: Swift.Error?
        
        init(
          _ code: Self.Code,
          underlying: Swift.Error? = nil
        ) {
          self.code = code
          self.underlying = underlying
        }
      }
    
    static func json(for request: URLRequest) async throws -> JSONHandler.JSON {
        let (data, response) = try await { () -> (Data, URLResponse) in
            do {
              return try await Session.data(for: request)
            } catch {
              throw Self.Error(.sessionError, underlying: error)
            }
          }()
        
        do {
            return try JSONHandler.json(with: data, response: response)
        } catch {
            throw Self.Error(.jsonHandlerError, underlying: error)
        }
    }
}
