//
//  AlbumsListModel.swift
//  Albums
//
//  Created by Noel C Perez on 12/18/21.
//

import Foundation

protocol AlbumsListModelJSONOperation {
    associatedtype JSON
    
    static func json(for: URLRequest) async throws -> JSON
}

extension NetworkJSONOperation: AlbumsListModelJSONOperation where Session == NetworkSession<Foundation.URLSession>, JSONHandler == NetworkJSONHandler<NetworkDataHandler, Foundation.JSONSerialization> { }

struct Album: Hashable, Identifiable {
  let id: String
  let artist: String
  let name: String
  let image: String
}

@MainActor final class AlbumsListModel<JSONOperation: AlbumsListModelJSONOperation>: ObservableObject {
    @Published private(set) var albums = Array<Album>()
    
    private func Albums(_ json: Any) -> Array<Album> {
      var albums = Array<Album>()
      if let array = ((json as? Dictionary<String, Any>)?["feed"] as? Dictionary<String, Any>)?["entry"] as? Array<Dictionary<String, Any>> {
        for dictionary in array {
          if let artist = ((dictionary["im:artist"] as? Dictionary<String, Any>)?["label"] as? String),
             let name = ((dictionary["im:name"] as? Dictionary<String, Any>)?["label"] as? String),
             let image = ((dictionary["im:image"] as? Array<Dictionary<String, Any>>)?[2]["label"] as? String),
             let id = (((dictionary["id"] as? Dictionary<String, Any>)?["attributes"] as? Dictionary<String, Any>)?["im:id"] as? String) {
            let album = Album(
              id: id,
              artist: artist,
              name: name,
              image: image
            )
            albums.append(album)
          }
        }
      }
      return albums
    }
    
    func requestAlbums() async throws {
        if let url = URL(string: "https://itunes.apple.com/us/rss/topalbums/limit=100/json") {
            let json = try await JSONOperation.json(for: URLRequest(url: url))
            self.albums = Albums(json)
        }
    }
}
