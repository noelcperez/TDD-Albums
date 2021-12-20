//
//  NetworkImageHandler.swift
//  Albums
//
//  Created by Noel C Perez on 12/16/21.
//

import Foundation

protocol NetworkImageHandlerDataHandler {
    static func data(with: Data, response: URLResponse) throws -> Data
}

extension NetworkDataHandler: NetworkImageHandlerDataHandler { }

protocol NetworkImageHandlerImageSerialization {
    associatedtype Image
    
    static func image(with: Data) throws -> Image
}

extension NetworkImageSerialization: NetworkImageHandlerImageSerialization where ImageSource == NetworkImageSource {
    
}

struct NetworkImageHandler<DataHandler: NetworkImageHandlerDataHandler, ImageSerialization: NetworkImageHandlerImageSerialization> {
    struct Error : Swift.Error {
        enum Code {
          case mimeTypeError
          case dataHandlerError
          case imageSerializationError
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
    
    static func image(with data: Data, response: URLResponse) throws -> ImageSerialization.Image {
        guard let mimeType = response.mimeType?.lowercased(), mimeType == "image/png" else {
         throw Self.Error(.mimeTypeError)
        }
        
        let data = try { () -> Data in
          do {
            return try DataHandler.data(with: data,response: response)
          } catch {
            throw Self.Error(.dataHandlerError, underlying: error)
          }
        }()
        
        do {
          return try ImageSerialization.image(with: data)
        } catch {
          throw Self.Error(.imageSerializationError, underlying: error)
        }
    }
}
