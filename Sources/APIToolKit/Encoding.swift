//
//  Encoding.swift
//  
//
//  Created by Artur Shinkevich on 2022-09-13.
//

import Foundation

public protocol ParameterEncoder {
  associatedtype T
  associatedtype D
  var params: T { get }
  var encoded: D { get }
}

public struct QueryParameters: ParameterEncoder {
  public let params: [String: Any]
  public let encoded: [URLQueryItem]

  public init(params: [String: Any]) {
    self.params = params
    encoded = self.params.queryItems
  }
}

public struct MultipartParameters: ParameterEncoder {
  public struct MultipartData {
    let header: String
    let data: Data
  }

  public let params: [String: Data]
  public var encoded: MultipartData

  public init(params: [String: Data]) {
    self.params = params

    let boundary: String = UUID().uuidString
    let data = NSMutableData()

    self.params.forEach { (key, value) in
      data.append("--\(boundary)\r\n")
      data.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n")
      data.append("Content-Type: \(value.mimeType)\r\n")
      data.append("\r\n")
      data.append(value)
      data.append("\r\n")
    }

    data.append("--\(boundary)--")

    encoded = MultipartData(
      header: "multipart/form-data; boundary=\(boundary)",
      data: data as Data
    )
  }
}
