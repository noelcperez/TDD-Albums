//
//  AlbumsTests.swift
//  AlbumsTests
//
//  Created by Noel C Perez on 12/4/21.
//

import Foundation

func DataTestDouble() -> Data {
    Data(UInt8.min...UInt8.max)
}

func HTTPURLResponseTestDouble(
  statusCode: Int = 200,
  headerFields: Dictionary<String, String>? = nil
) -> HTTPURLResponse {
  return HTTPURLResponse(
    url: URLTestDouble(),
    statusCode: statusCode,
    httpVersion: "HTTP/1.1",
    headerFields: headerFields
  )!
}

func NSErrorTestDouble() -> NSError {
  return NSError(
    domain: "",
    code: 0
  )
}

func URLRequestTestDouble() -> URLRequest {
  return URLRequest(url: URLTestDouble())
}

func URLResponseTestDouble() -> URLResponse {
  return URLResponse(
    url: URLTestDouble(),
    mimeType: nil,
    expectedContentLength: 0,
    textEncodingName: nil
  )
}

func URLTestDouble() -> URL {
  return URL(string: "http://localhost/")!
}
