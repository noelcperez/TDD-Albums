//
//  NetworkImageOperation.swift
//  Albums
//
//  Created by Noel C Perez on 12/18/21.
//

import Foundation

protocol NetworkImageOperationSession {
    static func data(for: URLRequest) async throws -> (Data, URLResponse)
}

extension NetworkSession: NetworkImageOperationSession where URLSession == Foundation.URLSession { }

protocol NetworkImageOperationImageHandler {
    associatedtype Image
    
    static func image(with: Data, response: URLResponse) throws -> Image
}

extension NetworkImageHandler: NetworkImageOperationImageHandler where DataHandler == NetworkDataHandler, ImageSerialization == NetworkImageSerialization<NetworkImageSource> { }

struct NetworkImageOperation<Session: NetworkImageOperationSession, ImageHandler: NetworkImageOperationImageHandler> {
    struct Error : Swift.Error {
        enum Code {
          case sessionError
          case imageHandlerError
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
    
    static func image(for request: URLRequest) async throws -> ImageHandler.Image {
        let (data, response) = try await { () -> (Data, URLResponse) in
          do {
            return try await Session.data(for: request)
          } catch {
            throw Self.Error(.sessionError, underlying: error)
          }
        }()
            
        do {
          return try ImageHandler.image(with: data, response: response)
        } catch {
          throw Self.Error(.imageHandlerError, underlying: error)
        }
    }
}
