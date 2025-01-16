//
//  Logger.swift
//  Pods
//
//  Created by vincepzhang on 2024/11/22.
//

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

class Logger {
    
    static func info(_ message: String) {
        log(message, level: 0)
    }
    
    static func warning(_ message: String) {
        log(message, level: 1)
    }

    static func error(_ message: String) {
        log(message, level: 2)
    }
    
    private static func log(_ message: String, level: Int = 0) {
        let dictionary: [String : Any] = ["api": "TuikitLog",
                                                  "params" : ["level": level,
                                                             "message": "TUICallKit - \(message)",
                                                              "file": "/some_path/.../foo.c",
                                                              "line": 90]]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
            TRTCCloud.sharedInstance().callExperimentalAPI(jsonString)
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
        }
    }
}
