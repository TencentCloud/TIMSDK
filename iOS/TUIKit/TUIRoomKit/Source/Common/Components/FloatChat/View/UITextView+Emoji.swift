//
//  UITextView+Emotion.swift
//  TUILiveKit
//
//  Created by krabyu on 2024/4/3.
//

import UIKit

extension UITextView {
    func insertEmotionAttributedString(emotionAttributedString: NSAttributedString) {
        guard let content = attributedText.mutableCopy() as? NSMutableAttributedString
        else {
            return
        }
        let location = selectedRange.location
        content.insert(emotionAttributedString, at: location)
        content.addAttributes([.font: font ?? UIFont.systemFont(ofSize: 14),
                               .foregroundColor: textColor ?? .black,],
                              range: NSRange(location: location, length: emotionAttributedString.length))
        attributedText = content
        let newRange = NSRange(location: location + emotionAttributedString.length, length: 0)
        selectedRange = newRange
    }

    func insertEmotionKey(emotionKey: String) {
        guard let content: NSMutableAttributedString = attributedText.copy() as? NSMutableAttributedString else { return }
        let location = selectedRange.location
        content.insert(NSAttributedString(string: emotionKey, attributes: [.font: font ?? UIFont.systemFont(ofSize: 14),
                                                                           .foregroundColor: textColor ?? .black,]), at: location)
        attributedText = content
        let newRange = NSRange(location: location + emotionKey.count, length: 0)
        selectedRange = newRange
    }

    func deleteEmotion() -> Bool {
        let location = selectedRange.location
        if location == 0 { return false }

        let headSubstring = text.prefix(location)
        if headSubstring.hasSuffix("]") {
            for i in stride(from: headSubstring.count, to: 0 - 1, by: -1) {
                let index = headSubstring.index(headSubstring.startIndex, offsetBy: i - 1)
                let tempString = headSubstring[index]
                if tempString == "[" {
                    guard let content: NSMutableAttributedString = attributedText.copy() as? NSMutableAttributedString else { return false }
                    content.deleteCharacters(in: NSRange(location: i - 1, length: headSubstring.count - (i - 1)))
                    attributedText = content
                    let newRange = NSRange(location: headSubstring.count, length: 0)
                    selectedRange = newRange
                    return true
                }
            }
        }
        return false
    }

    var normalText: String {
        guard let attributedText = attributedText else { return "" }
        var normalText = ""
        attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { attributes, range, _ in
            if let attachment = attributes[.attachment] as? EmotionAttachment {
                let emotionAttachment = attachment
                normalText += emotionAttachment.displayText
            } else {
                let substring = (attributedText.string as NSString).substring(with: range)
                normalText += substring
            }
        }
        return normalText
    }
}
