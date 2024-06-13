//
//  EmotionHelper.swift
//  TUILiveKit
//
//  Created by krabyu on 2024/4/3.
//

import UIKit

class EmotionHelper {
    static let shared = {
        EmotionHelper()
    }()

    private init() {
        useDefaultEmotions()
    }

    var emotions: [Emotion] = []
    private var cacheTotalImageDictionary: [String: UIImage] = [:]
    private var cacheAttributedDictionary: [String: NSAttributedString] = [:]
    private var regularExpression: NSRegularExpression = try! NSRegularExpression(pattern: "\\[[a-zA-Z0-9_\\u4e00-\\u9fa5]+\\]", options: [])

    func useDefaultEmotions() {
        createTotalEmotions()
        cacheTotalImage()
    }

    func setEmotions(emotions: [Emotion]) {
        self.emotions = emotions
        cacheTotalImageDictionary = [:]
        cacheTotalImage()
    }

    func cacheTotalImage() {
        if cacheTotalImageDictionary.count == 0 {
            var emotionImageDictionary: [String: UIImage] = [:]
            for emotion in emotions {
                if emotion.image.size.width != 0 {
                    emotion.image = UIImage(named: emotion.identifier, in: tuiRoomKitBundle(), compatibleWith: nil) ?? UIImage()
                }
                emotionImageDictionary[emotion.displayName] = emotion.image
            }
            cacheTotalImageDictionary = emotionImageDictionary
        }
    }

    func obtainImagesAttributedString(byText text: String, font: UIFont) -> NSMutableAttributedString {
        let matches = regularExpression.matches(in: text, range: NSRange(location: 0, length: text.count))
        let intactAttributedString = NSMutableAttributedString(string: text)
        for match in matches.reversed() {
            guard let emojiRange = Range(match.range, in: text) else { return NSMutableAttributedString(string: "") }
            let emojiKey = String(text[emojiRange])

            var useCache = true
            if #available(iOS 15.0, *) {
                // Cached NSAttributedString cannot be used on ios15, only one expression will appear, but it can be used on ios14 and before.
                useCache = false
            }
            let imageAttributedString = obtainImageAttributedString(byImageKey: emojiKey, font: font, useCache: useCache)
            intactAttributedString.replaceCharacters(in: match.range, with: imageAttributedString)
        }
        // Fixed an issue where font changed due to inserting AttributeString;
        // Prevents the textView font from getting smaller after inserting an expression
        intactAttributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: intactAttributedString.length))
        return intactAttributedString
    }

    func obtainImageAttributedString(byImageKey imageKey: String, font: UIFont, useCache: Bool) -> NSAttributedString {
        if !useCache {
            let image = cacheTotalImageDictionary[imageKey]
            if image == nil {
                return NSAttributedString(string: "")
            }
            let emotionAttachment = EmotionAttachment()
            emotionAttachment.displayText = imageKey
            emotionAttachment.image = image
            emotionAttachment.bounds = CGRect(x: 0, y: font.descender, width: font.lineHeight, height: font.lineHeight)
            let imageAttributedString = NSAttributedString(attachment: emotionAttachment)
            return imageAttributedString
        }

        let keyFont = String(format: "%@%.1f", imageKey, font.pointSize)
        if let result = cacheAttributedDictionary[keyFont] {
            return result
        }
        guard let image = cacheTotalImageDictionary[imageKey] else {
            return NSAttributedString(string: "")
        }

        let emotionAttachment = EmotionAttachment()
        emotionAttachment.displayText = imageKey
        emotionAttachment.image = image
        emotionAttachment.bounds = CGRect(x: 0, y: font.descender, width: font.lineHeight, height: font.lineHeight)
        let result = NSAttributedString(attachment: emotionAttachment)
        cacheAttributedDictionary[keyFont] = result
        return result
    }

    private func createTotalEmotions() {
        emotions = []
        emotions.append(Emotion(identifier: "room_floatChat_emoji_0", displayName: "[TUIEmoji_Smile]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_1", displayName: "[TUIEmoji_Expect]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_2", displayName: "[TUIEmoji_Blink]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_3", displayName: "[TUIEmoji_Guffaw]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_4", displayName: "[TUIEmoji_KindSmile]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_5", displayName: "[TUIEmoji_Haha]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_6", displayName: "[TUIEmoji_Cheerful]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_7", displayName: "[TUIEmoji_Speechless]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_8", displayName: "[TUIEmoji_Amazed]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_9", displayName: "[TUIEmoji_Sorrow]"))

        emotions.append(Emotion(identifier: "room_floatChat_emoji_10", displayName: "[TUIEmoji_Complacent]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_11", displayName: "[TUIEmoji_Silly]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_12", displayName: "[TUIEmoji_Lustful]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_13", displayName: "[TUIEmoji_Giggle]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_14", displayName: "[TUIEmoji_Kiss]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_15", displayName: "[TUIEmoji_Wail]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_16", displayName: "[TUIEmoji_TearsLaugh]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_17", displayName: "[TUIEmoji_Trapped]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_18", displayName: "[TUIEmoji_Mask]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_19", displayName: "[TUIEmoji_Fear]"))

        emotions.append(Emotion(identifier: "room_floatChat_emoji_20", displayName: "[TUIEmoji_BareTeeth]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_21", displayName: "[TUIEmoji_FlareUp]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_22", displayName: "[TUIEmoji_Yawn]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_23", displayName: "[TUIEmoji_Tact]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_24", displayName: "[TUIEmoji_Stareyes]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_25", displayName: "[TUIEmoji_ShutUp]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_26", displayName: "[TUIEmoji_Sigh]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_27", displayName: "[TUIEmoji_Hehe]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_28", displayName: "[TUIEmoji_Silent]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_29", displayName: "[TUIEmoji_Surprised]"))

        emotions.append(Emotion(identifier: "room_floatChat_emoji_30", displayName: "[TUIEmoji_Askance]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_31", displayName: "[TUIEmoji_Ok]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_32", displayName: "[TUIEmoji_Shit]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_33", displayName: "[TUIEmoji_Monster]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_34", displayName: "[TUIEmoji_Daemon]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_35", displayName: "[TUIEmoji_Rage]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_36", displayName: "[TUIEmoji_Fool]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_37", displayName: "[TUIEmoji_Pig]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_38", displayName: "[TUIEmoji_Cow]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_39", displayName: "[TUIEmoji_Ai]"))

        emotions.append(Emotion(identifier: "room_floatChat_emoji_40", displayName: "[TUIEmoji_Skull]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_41", displayName: "[TUIEmoji_Bombs]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_42", displayName: "[TUIEmoji_Coffee]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_43", displayName: "[TUIEmoji_Cake]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_44", displayName: "[TUIEmoji_Beer]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_45", displayName: "[TUIEmoji_Flower]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_46", displayName: "[TUIEmoji_Watermelon]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_47", displayName: "[TUIEmoji_Rich]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_48", displayName: "[TUIEmoji_Heart]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_49", displayName: "[TUIEmoji_Moon]"))

        emotions.append(Emotion(identifier: "room_floatChat_emoji_50", displayName: "[TUIEmoji_Sun]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_51", displayName: "[TUIEmoji_Star]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_52", displayName: "[TUIEmoji_RedPacket]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_53", displayName: "[TUIEmoji_Celebrate]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_54", displayName: "[TUIEmoji_Bless]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_55", displayName: "[TUIEmoji_Fortune]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_56", displayName: "[TUIEmoji_Convinced]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_57", displayName: "[TUIEmoji_Prohibit]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_58", displayName: "[TUIEmoji_666]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_59", displayName: "[TUIEmoji_857]"))

        emotions.append(Emotion(identifier: "room_floatChat_emoji_60", displayName: "[TUIEmoji_Knife]"))
        emotions.append(Emotion(identifier: "room_floatChat_emoji_61", displayName: "[TUIEmoji_Like]"))

        for emotion in emotions {
            emotion.image = UIImage(named: emotion.identifier, in: tuiRoomKitBundle(), compatibleWith: nil) ?? UIImage()
        }
    }
}

