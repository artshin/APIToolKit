//
//  Dictionary.swift
//  
//
//  Created by Artur Shinkevich on 2022-09-13.
//

import Foundation

public extension Dictionary where Key == String, Value == Any {
  var queryItems: [URLQueryItem] {
    compactMap { (key, value) -> URLQueryItem? in
      switch value {
      case let boolean as Bool:
        return URLQueryItem(name: key, value: String(boolean))
      case let integer as Int:
        return URLQueryItem(name: key, value: String(integer))
      case let string as String:
        return URLQueryItem(name: key, value: string)
      case let double as Double:
        return URLQueryItem(name: key, value: String(double))
      default:
        return nil
      }
    }
  }

  var queryString: String {
    compactMap { (key, value) -> String? in
      switch value {
      case let boolean as Bool:
        return key + "=" + String(boolean)
      case let integer as Int:
        return key + "=" + String(integer)
      case let string as String:
        return key + "=" + string
      case let double as Double:
        return key + "=" + String(double)
      default:
        return nil
      }
    }.joined(separator: "&")
  }
}
