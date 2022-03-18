//
//  TRTCLog.swift
//  TRTCVoiceRoomDemo
//
//  Created by abyyxwang on 2020/6/10.
//  Copyright © 2020 tencent. All rights reserved.
//

import Foundation

import Foundation
import os

/// subsystem for current project.
///  - setup it when start a new project.
//private let subsystem = "com.slideart.photo2videomaker"
private let subSystemIdentifier: String = Bundle.main.bundleIdentifier ?? "com.tencent.trtc"
private let subsystem: String = "TRTC"
/// Custom log system.
public class TRTCLog {
    public struct Output: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let info = Output(rawValue: 1 << 0)
        public static let debug = Output(rawValue: 1 << 1)
        public static let warning = Output(rawValue: 1 << 2)
        public static let error = Output(rawValue: 1 << 3)
        public static let print = Output(rawValue: 1 << 4)

        public static let all: Output = [.print, .info, .debug, .warning, .error]
    }
    
    /// setup log level and when does the log work.
    public static var output: Output = [.debug, .warning, .error, .print]
    
    @available(iOS 10.0, *)
    /// level info
    static let infoLog = OSLog(subsystem: subsystem, category: "INFO")
    /// info level
    ///
    /// - Parameters:
    ///   - string: log info description
    ///   - fileName: file name
    ///   - methodName: method name
    ///   - lineNumber: line number
    public static func info(_ string: String, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
        #if DEBUG
        let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
        let log = "\(file):line \(lineNumber) method:\(methodName):\(string)"
        if output.contains(.info) {
            if #available(iOS 10.0, *) {
                os_log("%@", log: infoLog, type: .info, log)
            } else {
                print("<INFO>: %@", log)
            }
        }
        #endif
    }

    @available(iOS 10.0, *)
    /// level debug
    static let debugLog = OSLog(subsystem: subsystem, category: "DEBUG")
    /// debug level
    ///
    /// - Parameters:
    ///   - string: log info description
    ///   - fileName: file name
    ///   - methodName: method name
    ///   - lineNumber: line number
    public static func debug(_ string: String, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
        #if DEBUG
            let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
            let log = "\(file):line \(lineNumber) method:\(methodName):\(string)"
            if output.contains(.debug) {
                if #available(iOS 10.0, *) {
                    os_log("%@", log: debugLog, type: .debug, log)
                } else {
                    print("<DEBUG>: %@", log)
                }
            }
        #endif
    }

    @available(iOS 10.0, *)
    /// level warning
    static let warningLog = OSLog(subsystem: subsystem, category: "WARNING")
    public static func warning(_ string: String, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
        if output.contains(.warning) {
            let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
            let log = "\(file):line \(lineNumber) method:\(methodName):\(string)"
            if #available(iOS 10.0, *) {
                os_log("%@", log: warningLog, type: .fault, log)
            } else {
                print("<WARNING>: %@", string)
            }
        }
    }

    @available(iOS 10.0, *)
    /// level error
    static let errorLog = OSLog(subsystem: subsystem, category: "ERROR")
    
    /// log error
    ///
    /// - Parameters:
    ///   - string: message
    ///   - fileName: filename
    ///   - methodName: method
    ///   - lineNumber: lineNumber
    public static func error(_ string: String, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
        if output.contains(.error) {
            let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
            let log = "\(file):line \(lineNumber) method:\(methodName):\n\(string)"
            if #available(iOS 10.0, *) {
                os_log("%@", log: errorLog, type: .error, log)
            } else {
                print("<ERROR>: %@", string)
            }
            #if DEBUG
//            assert(false, log)
            #endif
        }
    }
    
    /// just output in console.
    ///
    /// - Parameters:
    ///   - message: output message.
    ///   - fileName: file name.
    ///   - methodName: method name.
    ///   - lineNumber: line number.
    public static func out<N>(message: N, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
        #if DEBUG
            if output.contains(.print) {
                let file = (fileName as NSString).lastPathComponent.replacingOccurrences(of: ".Swift", with: "")
                print("[PRINT]\(file):\(lineNumber) \(methodName):\(message)")
            }
        #endif
    }
    
    public static func out<N>(_ message: N, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
        TRTCLog.out(message: message, fileName: fileName, methodName: methodName, lineNumber: lineNumber)
    }
}
