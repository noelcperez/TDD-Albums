//
//  AlbumsListRowModel.swift
//  Albums
//
//  Created by Noel C Perez on 12/20/21.
//

import Foundation

protocol AlbumsListRowModelImageOperation {
    associatedtype Image
    
    static func image(for: URLRequest) async throws -> Image
}

extension NetworkImageOperation: AlbumsListRowModelImageOperation where Session == NetworkSession<Foundation.URLSession>,
                                                                        ImageHandler == NetworkImageHandler<NetworkDataHandler, NetworkImageSerialization<NetworkImageSource>> { }


@MainActor final class AlbumsListRowModel<ImageOperation: AlbumsListRowModelImageOperation>: ObservableObject {
    @Published private(set) var image: ImageOperation.Image?
    
    private let album: Album
    
    var artist: String { album.artist }
    var name: String { album.name }
    
    init(album: Album) {
        self.album = album
    }
    
    func requestImage() async throws {
        if let url = URL(string: album.image) {
            let urlRequest = URLRequest(url: url)
            image = try await ImageOperation.image(for: urlRequest)
        }
    }
}
