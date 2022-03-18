//
//  String+byteLength.swift
//  Alamofire
//
//  Created by gg on 2021/8/3.
//

import Foundation

public let createRoomTextMaxByteLength = 30

extension String {
    public func byteLength() -> Int {
        guard let data = data(using: .utf8) else {
            return 0
        }
        return data.count
    }
    public func subString(toByteLength: Int) -> String {
        guard let data = data(using: .utf8) else {
            return ""
        }
        if data.count > toByteLength {
            var offset = 0
            while offset < toByteLength {
                if let str = String(data: data[0..<(toByteLength - offset)], encoding: .utf8) {
                    return str
                }
                offset += 1
            }
            return ""
        }
        else {
            return self
        }
    }
}
