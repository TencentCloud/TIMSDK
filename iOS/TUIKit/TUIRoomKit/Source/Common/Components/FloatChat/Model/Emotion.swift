//
//  Emotion.swift
//  TUILiveKit
//
//  Created by krabyu on 2024/4/3.
//

import UIKit

class Emotion: Equatable {
    let identifier: String
    let displayName: String
    var image: UIImage = UIImage()

    init(identifier: String, displayName: String) {
        self.identifier = identifier
        self.displayName = displayName
    }

    static func == (left: Emotion, right: Emotion) -> Bool {
        return left.identifier == right.identifier
    }

    var description: String {
        return "identifier:\(identifier), displayName:\(displayName)"
    }
}

class EmotionAttachment: NSTextAttachment {
    var displayText: String = ""
}

