//
//  NetworkSession.swift
//  Albums
//
//  Created by Noel C Perez on 12/17/21.
//

import Foundation

protocol NetworkSessionURLSession {
    associatedtype URLSession: NetworkSessionURLSession
    
    static var shared: URLSession { get }
    
    func data(for: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSessionURLSession { }

struct NetworkSession<URLSession: NetworkSessionURLSession> {
    static func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request, delegate: nil)
    }
}
