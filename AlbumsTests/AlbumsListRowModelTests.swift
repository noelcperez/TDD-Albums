//
//  AlbumsListRowModelTests.swift
//  AlbumsTests
//
//  Created by Noel C Perez on 12/20/21.
//

import Foundation
import XCTest

final class AlbumsListRowModelTestCase: XCTestCase {
    private typealias AlbumsListRowModelTestDouble = AlbumsListRowModel<ImageOperationTestDouble>
    
    private static var album: Album { Album(id: "id", artist: "artist", name: "name", image: "image") }
    
    override func tearDown() {
        ImageOperationTestDouble.parameterRequest = nil
        ImageOperationTestDouble.returnImage = nil
      }
    
    @MainActor func testError() async {
        ImageOperationTestDouble.returnImage = nil
        
        let model = AlbumsListRowModelTestDouble(album: Self.album)
        XCTAssertEqual(model.artist, Self.album.artist)
        XCTAssertEqual(model.name, Self.album.name)
        
        do {
            try await model.requestImage()
            XCTFail()
        } catch {
            XCTAssertEqual(ImageOperationTestDouble.parameterRequest, URLRequest(url: URL(string: Self.album.image)!))
            XCTAssertNil(model.image)
            
            if let error = try? XCTUnwrap(error as NSError?) {
                XCTAssertIdentical(error, ImageOperationTestDouble.returnError)
              }
        }
    }
    
    @MainActor func testSuccess() async {
        ImageOperationTestDouble.returnImage = NSObject()
        
        let model = AlbumsListRowModelTestDouble(album: Self.album)
        
        var modelDidChange = false
        let modelWillChange = model.objectWillChange.sink { _ in modelDidChange = true }
        
        var imageDidChange = false
        let imageWillChange = model.$image.sink { _ in
            if modelDidChange {
                imageDidChange = true
            }
        }
        XCTAssertEqual(model.artist, Self.album.artist)
        XCTAssertEqual(model.name, Self.album.name)
        
        do {
            try await model.requestImage()
            
            XCTAssertTrue(imageDidChange)
            XCTAssertEqual(ImageOperationTestDouble.parameterRequest, URLRequest(url: URL(string: Self.album.image)!))
            XCTAssertIdentical(ImageOperationTestDouble.returnImage, model.image)
            
        } catch {
            XCTFail()
        }
        
        modelWillChange.cancel()
        imageWillChange.cancel()
    }
}

extension AlbumsListRowModelTestCase {
    private struct ImageOperationTestDouble: AlbumsListRowModelImageOperation {
        static var parameterRequest: URLRequest?
        static var returnImage: NSObject?
        static let returnError = NSErrorTestDouble()
        
        static func image(for request: URLRequest) async throws -> NSObject {
            self.parameterRequest = request
            guard let returnImage = returnImage else { throw returnError }
            return returnImage
        }
    }
}
