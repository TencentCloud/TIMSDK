//
//  String+Extension.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/26.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation

extension String {
    func addIntervalSpace(intervalStr: String, interval: Int) -> String {
        var output = ""
        enumerated().forEach { index, c in
            if (index % interval == 0) && index > 0 {
                output += intervalStr
            }
            output.append(c)
        }
        return output
    }
    
    func convertToDic() -> [String : Any]?{
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        if let dict = try? JSONSerialization.jsonObject(with: data,
                                                        options: .mutableContainers) as? [String : Any] {
            return dict
        }
        return nil
    }
    
    func isStringOnlyDigits() -> Bool {
        let regex = "^[0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
