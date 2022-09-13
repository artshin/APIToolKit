//
//  Data.swift
//  ipadclockin
//
//  Created by Artur Shinkevich on 2022-09-12.
//

import Foundation

extension Data {
  private static let mimeTypeSignatures: [UInt8: String] = [
    0xFF: "image/jpeg",
    0x89: "image/png",
    0x47: "image/gif",
    0x49: "image/tiff",
    0x4D: "image/tiff",
    0x25: "application/pdf",
    0xD0: "application/vnd",
    0x46: "text/plain"
  ]

  var mimeType: String {
    var container: UInt8 = 0
    copyBytes(to: &container, count: 1)
    return Data.mimeTypeSignatures[container] ?? "application/octet-stream"
  }
}

extension NSMutableData {
  func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }
}
