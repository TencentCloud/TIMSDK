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
}
