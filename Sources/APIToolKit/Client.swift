//
//  RestClient.swift
//  ApiToolkit
//
//  Created by Artur Shinkevich on 2022-09-12.
//

import Foundation

public enum HTTPMethod: String {
  case get
  case post
  case put
  case delete
  case options
}

public enum Parameters {
  case query(params: QueryParameters)
  case multiPart(params: MultipartParameters)
}

public protocol RestEndpoint {
  var path: String { get }
  var method: HTTPMethod { get }
  var parameters: Parameters { get }
  var headers: [String: String]? { get }
}

public protocol RestClient {
  var baseUrl: String { get }
  var headers: [String: String] { get }
}

public typealias RestResponseCallback<R: Decodable> = (R?, Error?) -> Void

public struct Rest {
  public enum Errors: Error, LocalizedError {
    case malformedUrl
    case invalidResponse(response: URLResponse?, data: Data?)
  }

  public struct Client: RestClient {
    public var baseUrl: String
    public var headers: [String : String]

    public init(baseUrl: String, headers: [String: String] = [:]) {
      self.baseUrl = baseUrl
      self.headers = headers
    }

    public func request<R: Decodable>(endpoint: RestEndpoint) async throws -> R? {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<R?, Error>) -> Void in
        restRequest(endpoint: endpoint) { (response: R?, error) in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume(returning: response)
          }
        }
      }
    }

    public func request<R: Decodable>(endpoint: RestEndpoint, callback: @escaping RestResponseCallback<R>) {
      restRequest(endpoint: endpoint, callback: callback)
    }

    private func restRequest<R: Decodable>(endpoint: RestEndpoint, callback: @escaping RestResponseCallback<R>) {
      guard var urlComponents = URLComponents(string: baseUrl) else {
        callback(nil, Errors.malformedUrl)
        return
      }

      urlComponents.path = endpoint.path

      guard let endpointUrl = urlComponents.url else {
        callback(nil, Errors.malformedUrl)
        return
      }

      var request = URLRequest(url: endpointUrl)

      var headers = headers.merging(
        endpoint.headers ?? [:],
        uniquingKeysWith: { _, last in last }
      )

      switch endpoint.parameters {
      case .query(let params):
        urlComponents.queryItems = params.encoded
        request.url = urlComponents.url ?? request.url
      case .multiPart(let params):
        headers["Content-Type"] = params.encoded.header
        request.httpBody = params.encoded.data
      }

      request.httpMethod = endpoint.method.rawValue
      request.allHTTPHeaderFields = headers

#if DEBUG
      print("#### REST call ####", "\(endpoint.path)", request.cURL(), separator: "\n")
#endif

      URLSession.shared.dataTask(with: request) { data, response, error in
#if DEBUG
        if let response = response as? HTTPURLResponse {
          print("Response statuc code: \(response.statusCode)")
        }
#endif

        if let error = error {
          callback(nil, error)
          return
        }

        do {
          if let data = data {
            let decodedResponse = try JSONDecoder().decode(R.self, from: data)
            callback(decodedResponse, nil)
          } else {
            throw Errors.invalidResponse(response: response, data: data)
          }
        } catch let decodingError {
          callback(nil, decodingError)
        }
      }.resume()
    }
  }
}
