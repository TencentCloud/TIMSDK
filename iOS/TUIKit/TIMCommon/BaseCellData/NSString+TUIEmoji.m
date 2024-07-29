//
//  NSString+TUIEmoji.m
//  TUIChat
//
//  Created by harvy on 2021/11/15.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "NSString+TUIEmoji.h"
#import "TIMConfig.h"

@implementation NSString (TUIEmoji)

+ (NSString *)getRegex_emoji {
    
    NSString *regex_emoji = @"\\[[a-zA-Z0-9_\\u4e00-\\u9fa5]+\\]";  // match emoji

    return regex_emoji;
}
- (NSString *)getLocalizableStringWithFaceContent {
    NSString *content = self;
    NSString *regex_emoji = [self.class getRegex_emoji];  // match emoji
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (re) {
        NSArray *resultArray = [re matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        TUIFaceGroup *group = [TIMConfig defaultConfig].faceGroups[0];
        NSMutableArray *waitingReplaceM = [NSMutableArray array];
        for (NSTextCheckingResult *match in resultArray) {
            NSRange range = [match range];
            NSString *subStr = [content substringWithRange:range];
            for (TUIFaceCellData *face in group.faces) {
                if ([face.name isEqualToString:subStr]) {
                    [waitingReplaceM
                        addObject:@{@"range" : NSStringFromRange(range), @"localizableStr" : face.localizableName.length ? face.localizableName : face.name}];
                    break;
                }
            }
        }

        if (waitingReplaceM.count) {
            /**
             * Replace from back to front, otherwise it will cause positional problems
             */
            for (int i = (int)waitingReplaceM.count - 1; i >= 0; i--) {
                NSRange range = NSRangeFromString(waitingReplaceM[i][@"range"]);
                NSString *localizableStr = waitingReplaceM[i][@"localizableStr"];
                content = [content stringByReplacingCharactersInRange:range withString:localizableStr];
            }
        }
    }
    return content;
}

- (NSString *)getInternationalStringWithfaceContent {
    NSString *content = self;
    NSString *regex_emoji = [self.class getRegex_emoji];
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (re) {
        NSMutableDictionary *faceDict = [NSMutableDictionary dictionary];
        TUIFaceGroup *group = [TIMConfig defaultConfig].faceGroups[0];
        for (TUIFaceCellData *face in group.faces) {
            NSString *key = face.localizableName ?: face.name;
            NSString *value = face.name ?: @"";
            faceDict[key] = value;
        }

        NSArray *resultArray = [re matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        NSMutableArray *waitingReplaceM = [NSMutableArray array];
        for (NSTextCheckingResult *match in resultArray) {
            NSRange range = [match range];
            NSString *subStr = [content substringWithRange:range];
            [waitingReplaceM addObject:@{@"range" : NSStringFromRange(range), @"localizableStr" : faceDict[subStr] ?: subStr}];
        }

        if (waitingReplaceM.count != 0) {
            /**
             * Replace from back to front, otherwise it will cause positional problems
             */
            for (int i = (int)waitingReplaceM.count - 1; i >= 0; i--) {
                NSRange range = NSRangeFromString(waitingReplaceM[i][@"range"]);
                NSString *localizableStr = waitingReplaceM[i][@"localizableStr"];
                content = [content stringByReplacingCharactersInRange:range withString:localizableStr];
            }
        }
    }
    return content;
}

- (NSMutableAttributedString *)getFormatEmojiStringWithFont:(UIFont *)textFont
                                             emojiLocations:(nullable NSMutableArray<NSDictionary<NSValue *, NSAttributedString *> *> *)emojiLocations {
    /**
     * First determine whether the text exists
     */
    if (self.length == 0) {
        NSLog(@"getFormatEmojiStringWithFont failed , current text is nil");
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    /**
     * 1. Create a mutable attributed string
     */
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    if ([TIMConfig defaultConfig].faceGroups.count == 0) {
        [attributeString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributeString.length)];
        return attributeString;
    }

    /**
     * 2.Match strings with regular expressions
     */
    NSError *error = nil;
    static NSRegularExpression *re = nil;
    if (re == nil) {
        NSString *regex_emoji = [self.class getRegex_emoji];
        re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    }
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }

    NSArray *resultArray = [re matchesInString:self options:0 range:NSMakeRange(0, self.length)];

    TUIFaceGroup *group = [TIMConfig defaultConfig].faceGroups[0];

    /**
     * 3.Getting all emotes and locations
     * - Used to store the dictionary, the dictionary stores the image and the corresponding location of the image
     */
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    /**
     * Replace the image with the corresponding image according to the matching range
     */
    for (NSTextCheckingResult *match in resultArray) {
        /**
         * Get the range in the array element
         */
        NSRange range = [match range];
        /**
         * Get the corresponding value in the original string
         */
        NSString *subStr = [self substringWithRange:range];

        for (TUIFaceCellData *face in group.faces) {
            if ([face.name isEqualToString:subStr]) {
                /**
                 * - Create a new NSTextAttachment to store our image
                 */
                TUIEmojiTextAttachment *emojiTextAttachment = [[TUIEmojiTextAttachment alloc] init];
                emojiTextAttachment.faceCellData = face;

                NSString *localizableFaceName =  face.name;

                // Set tag and image
                emojiTextAttachment.emojiTag = localizableFaceName;
                emojiTextAttachment.image = [[TUIImageCache sharedInstance] getFaceFromCache:face.path];
                
                // Set emoji size
                emojiTextAttachment.emojiSize = kTIMDefaultEmojiSize;
                NSAttributedString *str = [NSAttributedString attributedStringWithAttachment:emojiTextAttachment];

                /**
                 * - Convert attachments to mutable strings to replace emoji text in source strings
                 */
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:emojiTextAttachment];
                /**
                 * - Save the picture and the corresponding position of the picture into the dictionary
                 */
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                /**
                 * - Store dictionary in array
                 */
                [imageArray addObject:imageDic];
                break;
            }
        }
    }

    /**
     * 4.Replace from back to front, otherwise it will cause positional problems
     */
    NSMutableArray *locations = [NSMutableArray array];
    for (int i = (int)imageArray.count - 1; i >= 0; i--) {
        NSRange originRange;
        [imageArray[i][@"range"] getValue:&originRange];

        /**
         * Store location information
         */
        NSAttributedString *originStr = [attributeString attributedSubstringFromRange:originRange];
        NSAttributedString *currentStr = imageArray[i][@"image"];
        [locations insertObject:@[ [NSValue valueWithRange:originRange], originStr, currentStr ] atIndex:0];

        // Replace
        [attributeString replaceCharactersInRange:originRange withAttributedString:currentStr];
    }

    /**
     * 5.Getting the position information of the converted string of emoji
     */
    NSInteger offsetLocation = 0;
    for (NSArray *obj in locations) {
        NSArray *location = (NSArray *)obj;
        NSRange originRange = [(NSValue *)location[0] rangeValue];
        NSAttributedString *originStr = location[1];
        NSAttributedString *currentStr = location[2];
        NSRange currentRange;
        currentRange.location = originRange.location + offsetLocation;
        currentRange.length = currentStr.length;
        offsetLocation += currentStr.length - originStr.length;
        [emojiLocations addObject:@{[NSValue valueWithRange:currentRange] : originStr}];
    }

    [attributeString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributeString.length)];

    return attributeString;
}

- (NSString *)getEmojiImagePath {
    TUIFaceGroup *group = [TIMConfig defaultConfig].faceGroups[0];

    NSString *loaclName = [self getLocalizableStringWithFaceContent];
    for (TUIFaceCellData *face in group.faces) {
        if ([face.localizableName isEqualToString:loaclName]) {
            return face.path;
        }
    }
    return nil;
}

- (UIImage *)getEmojiImage {
    TUIFaceGroup *group = [TIMConfig defaultConfig].faceGroups[0];

    for (TUIFaceCellData *face in group.faces) {
        if ([face.name isEqualToString:self]) {
            return [[TUIImageCache sharedInstance] getFaceFromCache:face.path];
        }
    }
    return nil;
}

- (NSMutableAttributedString *)getAdvancedFormatEmojiStringWithFont:(UIFont *)textFont
                                                          textColor:(UIColor *)textColor
                                                     emojiLocations:(nullable NSMutableArray<NSDictionary<NSValue *, NSAttributedString *> *> *)emojiLocations {
    if (self.length == 0) {
        NSLog(@"getAdvancedFormatEmojiStringWithFont failed , current text is nil");
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    if ([TIMConfig defaultConfig].faceGroups.count == 0) {
        [attributeString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributeString.length)];
        return attributeString;
    }

    NSString *regex_emoji = [self.class getRegex_emoji];

    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }

    NSArray *resultArray = [re matchesInString:self options:0 range:NSMakeRange(0, self.length)];

    TUIFaceGroup *group = [TIMConfig defaultConfig].faceGroups[0];

    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];

    for (NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];

        NSString *subStr = [self substringWithRange:range];

        for (TUIFaceCellData *face in group.faces) {
            if ([face.name isEqualToString:subStr] || [face.localizableName isEqualToString:subStr]) {
                TUIEmojiTextAttachment *emojiTextAttachment = [[TUIEmojiTextAttachment alloc] init];
                emojiTextAttachment.faceCellData = face;

                // Set tag and image
                emojiTextAttachment.emojiTag = face.name;
                emojiTextAttachment.image = [[TUIImageCache sharedInstance] getFaceFromCache:face.path];

                // Set emoji size
                emojiTextAttachment.emojiSize = kTIMDefaultEmojiSize;

                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:emojiTextAttachment];

                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];

                [imageArray addObject:imageDic];
                break;
            }
        }
    }

    NSMutableArray *locations = [NSMutableArray array];
    for (int i = (int)imageArray.count - 1; i >= 0; i--) {
        NSRange originRange;
        [imageArray[i][@"range"] getValue:&originRange];

        NSAttributedString *originStr = [attributeString attributedSubstringFromRange:originRange];
        NSAttributedString *currentStr = imageArray[i][@"image"];
        [locations insertObject:@[ [NSValue valueWithRange:originRange], originStr, currentStr ] atIndex:0];

        [attributeString replaceCharactersInRange:originRange withAttributedString:currentStr];
    }

    NSInteger offsetLocation = 0;
    for (NSArray *obj in locations) {
        NSArray *location = (NSArray *)obj;
        NSRange originRange = [(NSValue *)location[0] rangeValue];
        NSAttributedString *originStr = location[1];
        NSAttributedString *currentStr = location[2];
        NSRange currentRange;
        currentRange.location = originRange.location + offsetLocation;
        currentRange.length = currentStr.length;
        offsetLocation += currentStr.length - originStr.length;
        [emojiLocations addObject:@{[NSValue valueWithRange:currentRange] : originStr}];
    }

    [attributeString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributeString.length)];
    [attributeString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, attributeString.length)];

    return attributeString;
}

/**
 * Steps:
 * 1. Match @user infos in string.
 * 2. Split origin string into array(A) by @user info's ranges.
 * 3. Iterate the array(A) to match emoji one by one.
 * 4. Add all parsed elements(emoji, @user, pure text) into result.
 * 5. Process the text and textIndex by the way.
 * 6. Encapsulate all arrays in a dict and return it.
 */
- (NSDictionary *)splitTextByEmojiAndAtUsers:(NSArray *_Nullable)users {
    if (self.length == 0) {
        return nil;
    }
    NSMutableArray *result = [NSMutableArray new];

    /// Find @user info's ranges in string.
    NSMutableArray *atUsers = [NSMutableArray new];
    for (NSString *user in users) {
        /// Add an whitespace after the user's name due to the special format of @ content.
        NSString *atUser = [NSString stringWithFormat:@"@%@ ", user];
        [atUsers addObject:atUser];
    }
    NSArray *atUserRanges = [self rangeOfAtUsers:atUsers inString:self];

    /// Split text using @user info's ranges.
    NSArray *splitResult = [self splitArrayWithRanges:atUserRanges inString:self];
    NSMutableArray *splitArrayByAtUser = splitResult.firstObject;
    NSSet *atUserIndex = splitResult.lastObject;

    /// Iterate the split array after finding @user, aimed to match emoji.
    NSInteger k = -1;
    NSMutableArray *textIndexArray = [NSMutableArray new];
    for (int i = 0; i < splitArrayByAtUser.count; i++) {
        NSString *str = splitArrayByAtUser[i];
        if ([atUserIndex containsObject:@(i)]) {
            /// str is @user info.
            [result addObject:str];
            k += 1;
        } else {
            /// str is not @user info, try to parse emoji in the same way as above.
            NSArray *emojiRanges = [self matchTextByEmoji:str];
            splitResult = [self splitArrayWithRanges:emojiRanges inString:str];
            NSMutableArray *splitArrayByEmoji = splitResult.firstObject;
            NSSet *emojiIndex = splitResult.lastObject;
            for (int j = 0; j < splitArrayByEmoji.count; j++) {
                NSString *tmp = splitArrayByEmoji[j];
                [result addObject:tmp];
                k += 1;
                if (![emojiIndex containsObject:@(j)]) {
                    /// str is text.
                    [textIndexArray addObject:@(k)];
                }
            }
        }
    }

    NSMutableArray *textArray = [NSMutableArray new];
    for (NSNumber *n in textIndexArray) {
        [textArray addObject:result[[n integerValue]]];
    }

    NSDictionary *dict = @{kSplitStringResultKey : result, kSplitStringTextKey : textArray, kSplitStringTextIndexKey : textIndexArray};
    return dict;
}

/// Find all ranges of @user in string.
- (NSArray *)rangeOfAtUsers:(NSArray *)atUsers inString:(NSString *)string {
    /// Find all positions of character "@".
    NSString *tmp = nil;
    NSMutableIndexSet *atIndex = [NSMutableIndexSet new];
    for (int i = 0; i < [string length]; i++) {
        tmp = [string substringWithRange:NSMakeRange(i, 1)];
        if ([tmp isEqualToString:@"@"]) {
            [atIndex addIndex:i];
        }
    }

    /// Match @user with "@" position.
    NSMutableArray *result = [NSMutableArray new];
    for (NSString *user in atUsers) {
        [atIndex enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
          if (string.length >= user.length && idx <= string.length - user.length) {
              NSRange range = NSMakeRange(idx, user.length);
              if ([[string substringWithRange:range] isEqualToString:user]) {
                  [result addObject:[NSValue valueWithRange:range]];
                  [atIndex removeIndex:idx];
                  *stop = YES;
              }
          }
        }];
    }
    return result;
}

/// Split string into multi substrings by given ranges.
/// Return value's structure is [result, indexes], in which indexs means position of content within ranges located in result after spliting.
- (NSArray *)splitArrayWithRanges:(NSArray *)ranges inString:(NSString *)string {
    if (ranges.count == 0) {
        return @[ @[ string ], @[] ];
    }
    if (string.length == 0) {
        return nil;
    }

    /// Ascending sort.
    NSArray *sortedRanges = [ranges sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
      NSRange range1 = [obj1 rangeValue];
      NSRange range2 = [obj2 rangeValue];
      if (range1.location < range2.location) {
          return (NSComparisonResult)NSOrderedAscending;
      } else if (range1.location > range2.location) {
          return (NSComparisonResult)NSOrderedDescending;
      } else {
          return (NSComparisonResult)NSOrderedSame;
      }
    }];

    NSMutableArray *result = [NSMutableArray new];
    NSMutableSet *indexes = [NSMutableSet new];
    NSInteger prev = 0;
    NSInteger i = 0;
    NSInteger j = -1;
    while (i < sortedRanges.count) {
        NSRange cur = [sortedRanges[i] rangeValue];
        NSString *str = nil;
        if (cur.location > prev) {
            /// Add the str in [prev, cur.location).
            str = [string substringWithRange:NSMakeRange(prev, cur.location - prev)];
            [result addObject:str];
            j += 1;
        }

        /// Add the str in cur range.
        str = [string substringWithRange:cur];
        [result addObject:str];
        j += 1;
        [indexes addObject:@(j)];

        /// Update prev to support calculation of next round.
        prev = cur.location + cur.length;

        /// Text exists after the last emoji.
        if (i == sortedRanges.count - 1 && prev < string.length - 1) {
            NSString *last = [string substringWithRange:NSMakeRange(prev, string.length - prev)];
            [result addObject:last];
        }

        i++;
    }

    return @[ result, indexes ];
}

/// Match text by emoji, return the matched ranges
- (NSArray *)matchTextByEmoji:(NSString *)text {
    NSMutableArray *result = [NSMutableArray new];

    /// TUIKit qq emoji.
    NSString *regexOfCustomEmoji = [self.class getRegex_emoji];
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regexOfCustomEmoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"re match custom emoji failed, error: %@", [error localizedDescription]);
        return nil;
    }
    NSArray *matchResult = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    for (NSTextCheckingResult *match in matchResult) {
        NSString *substring = [text substringWithRange:match.range];
        TUIFaceGroup *group = [TIMConfig defaultConfig].faceGroups[0];
        for (TUIFaceCellData *face in group.faces) {
            if ([face.name isEqualToString:substring] || [face.localizableName isEqualToString:substring]) {
                [result addObject:[NSValue valueWithRange:match.range]];
                break;
            }
        }
    }

    /// Unicode emoji.
    NSString *regexOfUnicodeEmoji = [NSString unicodeEmojiReString];
    re = [NSRegularExpression regularExpressionWithPattern:regexOfUnicodeEmoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"re match universal emoji failed, error: %@", [error localizedDescription]);
        return [result copy];
    }
    matchResult = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    for (NSTextCheckingResult *match in matchResult) {
        [result addObject:[NSValue valueWithRange:match.range]];
    }

    return [result copy];
}

+ (NSString *)replacedStringWithArray:(NSArray *)array index:(NSArray *)indexArray replaceDict:(NSDictionary *)replaceDict {
    if (replaceDict == nil) {
        return nil;
    }
    NSMutableArray *mutableArray = [array mutableCopy];
    for (NSNumber *value in indexArray) {
        NSInteger i = [value integerValue];
        if (i < 0 || i > mutableArray.count - 1) {
            continue;
        }
        if (replaceDict[mutableArray[i]]) {
            mutableArray[i] = replaceDict[mutableArray[i]];
        }
    }
    return [mutableArray componentsJoinedByString:@""];
}

/**
 * Regex of unicode emoji, refer to https://unicode.org/reports/tr51/#EBNF_and_Regex
 * Regex exression is like:
 \p{ri} \p{ri}
 | \p{Emoji}
   ( \p{EMod}
   | \x{FE0F} \x{20E3}?
   | [\x{E0020}-\x{E007E}]+ \x{E007F}
   )?
   (\x{200D}
     ( \p{ri} \p{ri}
     | \p{Emoji}
       ( \p{EMod}
       | \x{FE0F} \x{20E3}?
       | [\x{E0020}-\x{E007E}]+ \x{E007F}
       )?
     )
   )*
 */
+ (NSString *)unicodeEmojiReString {
    NSString *ri = @"[\U0001F1E6-\U0001F1FF]";

    /// \u0023(#), \u002A(*), \u0030(keycap 0), \u0039(keycap 9), \u00A9(©), \u00AE(®) couldn't be added to NSString directly, need to transform a little bit.
    NSString *unsupport = [NSString stringWithFormat:@"%C|%C|[%C-%C]|", 0x0023, 0x002A, 0x0030, 0x0039];
    NSString *support =
        @"\U000000A9|\U000000AE|\u203C|\u2049|\u2122|\u2139|[\u2194-\u2199]|[\u21A9-\u21AA]|[\u231A-\u231B]|\u2328|\u23CF|[\u23E9-\u23EF]|[\u23F0-\u23F3]|["
        @"\u23F8-\u23FA]|\u24C2|[\u25AA-\u25AB]|\u25B6|\u25C0|[\u25FB-\u25FE]|[\u2600-\u2604]|\u260E|\u2611|[\u2614-\u2615]|\u2618|\u261D|\u2620|[\u2622-"
        @"\u2623]|\u2626|\u262A|[\u262E-\u262F]|[\u2638-\u263A]|\u2640|\u2642|[\u2648-\u264F]|[\u2650-\u2653]|\u265F|\u2660|\u2663|[\u2665-\u2666]|\u2668|"
        @"\u267B|[\u267E-\u267F]|[\u2692-\u2697]|\u2699|[\u269B-\u269C]|[\u26A0-\u26A1]|\u26A7|[\u26AA-\u26AB]|[\u26B0-\u26B1]|[\u26BD-\u26BE]|[\u26C4-\u26C5]|"
        @"\u26C8|[\u26CE-\u26CF]|\u26D1|[\u26D3-\u26D4]|[\u26E9-\u26EA]|[\u26F0-\u26F5]|[\u26F7-\u26FA]|\u26FD|\u2702|\u2705|[\u2708-\u270D]|\u270F|\u2712|"
        @"\u2714|\u2716|\u271D|\u2721|\u2728|[\u2733-\u2734]|\u2744|\u2747|\u274C|\u274E|[\u2753-\u2755]|\u2757|[\u2763-\u2764]|[\u2795-\u2797]|\u27A1|\u27B0|"
        @"\u27BF|[\u2934-\u2935]|[\u2B05-\u2B07]|[\u2B1B-\u2B1C]|\u2B50|\u2B55|\u3030|\u303D|\u3297|\u3299|\U0001F004|\U0001F0CF|[\U0001F170-\U0001F171]|["
        @"\U0001F17E-\U0001F17F]|\U0001F18E|[\U0001F191-\U0001F19A]|[\U0001F1E6-\U0001F1FF]|[\U0001F201-\U0001F202]|\U0001F21A|\U0001F22F|[\U0001F232-"
        @"\U0001F23A]|[\U0001F250-\U0001F251]|[\U0001F300-\U0001F30F]|[\U0001F310-\U0001F31F]|[\U0001F320-\U0001F321]|[\U0001F324-\U0001F32F]|[\U0001F330-"
        @"\U0001F33F]|[\U0001F340-\U0001F34F]|[\U0001F350-\U0001F35F]|[\U0001F360-\U0001F36F]|[\U0001F370-\U0001F37F]|[\U0001F380-\U0001F38F]|[\U0001F390-"
        @"\U0001F393]|[\U0001F396-\U0001F397]|[\U0001F399-\U0001F39B]|[\U0001F39E-\U0001F39F]|[\U0001F3A0-\U0001F3AF]|[\U0001F3B0-\U0001F3BF]|[\U0001F3C0-"
        @"\U0001F3CF]|[\U0001F3D0-\U0001F3DF]|[\U0001F3E0-\U0001F3EF]|\U0001F3F0|[\U0001F3F3-\U0001F3F5]|[\U0001F3F7-\U0001F3FF]|[\U0001F400-\U0001F40F]|["
        @"\U0001F410-\U0001F41F]|[\U0001F420-\U0001F42F]|[\U0001F430-\U0001F43F]|[\U0001F440-\U0001F44F]|[\U0001F450-\U0001F45F]|[\U0001F460-\U0001F46F]|["
        @"\U0001F470-\U0001F47F]|[\U0001F480-\U0001F48F]|[\U0001F490-\U0001F49F]|[\U0001F4A0-\U0001F4AF]|[\U0001F4B0-\U0001F4BF]|[\U0001F4C0-\U0001F4CF]|["
        @"\U0001F4D0-\U0001F4DF]|[\U0001F4E0-\U0001F4EF]|[\U0001F4F0-\U0001F4FF]|[\U0001F500-\U0001F50F]|[\U0001F510-\U0001F51F]|[\U0001F520-\U0001F52F]|["
        @"\U0001F530-\U0001F53D]|[\U0001F549-\U0001F54E]|[\U0001F550-\U0001F55F]|[\U0001F560-\U0001F567]|\U0001F56F|\U0001F570|[\U0001F573-\U0001F57A]|"
        @"\U0001F587|[\U0001F58A-\U0001F58D]|\U0001F590|[\U0001F595-\U0001F596]|[\U0001F5A4-\U0001F5A5]|\U0001F5A8|[\U0001F5B1-\U0001F5B2]|\U0001F5BC|["
        @"\U0001F5C2-\U0001F5C4]|[\U0001F5D1-\U0001F5D3]|[\U0001F5DC-\U0001F5DE]|\U0001F5E1|\U0001F5E3|\U0001F5E8|\U0001F5EF|\U0001F5F3|[\U0001F5FA-\U0001F5FF]"
        @"|[\U0001F600-\U0001F60F]|[\U0001F610-\U0001F61F]|[\U0001F620-\U0001F62F]|[\U0001F630-\U0001F63F]|[\U0001F640-\U0001F64F]|[\U0001F650-\U0001F65F]|["
        @"\U0001F660-\U0001F66F]|[\U0001F670-\U0001F67F]|[\U0001F680-\U0001F68F]|[\U0001F690-\U0001F69F]|[\U0001F6A0-\U0001F6AF]|[\U0001F6B0-\U0001F6BF]|["
        @"\U0001F6C0-\U0001F6C5]|[\U0001F6CB-\U0001F6CF]|[\U0001F6D0-\U0001F6D2]|[\U0001F6D5-\U0001F6D7]|[\U0001F6DD-\U0001F6DF]|[\U0001F6E0-\U0001F6E5]|"
        @"\U0001F6E9|[\U0001F6EB-\U0001F6EC]|\U0001F6F0|[\U0001F6F3-\U0001F6FC]|[\U0001F7E0-\U0001F7EB]|\U0001F7F0|[\U0001F90C-\U0001F90F]|[\U0001F910-"
        @"\U0001F91F]|[\U0001F920-\U0001F92F]|[\U0001F930-\U0001F93A]|[\U0001F93C-\U0001F93F]|[\U0001F940-\U0001F945]|[\U0001F947-\U0001F94C]|[\U0001F94D-"
        @"\U0001F94F]|[\U0001F950-\U0001F95F]|[\U0001F960-\U0001F96F]|[\U0001F970-\U0001F97F]|[\U0001F980-\U0001F98F]|[\U0001F990-\U0001F99F]|[\U0001F9A0-"
        @"\U0001F9AF]|[\U0001F9B0-\U0001F9BF]|[\U0001F9C0-\U0001F9CF]|[\U0001F9D0-\U0001F9DF]|[\U0001F9E0-\U0001F9EF]|[\U0001F9F0-\U0001F9FF]|[\U0001FA70-"
        @"\U0001FA74]|[\U0001FA78-\U0001FA7C]|[\U0001FA80-\U0001FA86]|[\U0001FA90-\U0001FA9F]|[\U0001FAA0-\U0001FAAC]|[\U0001FAB0-\U0001FABA]|[\U0001FAC0-"
        @"\U0001FAC5]|[\U0001FAD0-\U0001FAD9]|[\U0001FAE0-\U0001FAE7]|[\U0001FAF0-\U0001FAF6]";
    NSString *emoji = [NSString stringWithFormat:@"[%@%@]", unsupport, support];

    /// Construct regex of emoji by the rules above.
    NSString *eMod = @"[\U0001F3FB-\U0001F3FF]";

    NSString *variationSelector = @"\uFE0F";
    NSString *keycap = @"\u20E3";
    NSString *tags = @"[\U000E0020-\U000E007E]";
    NSString *termTag = @"\U000E007F";
    NSString *zwj = @"\u200D";

    NSString *riSequence = [NSString stringWithFormat:@"[%@][%@]", ri, ri];
    NSString *element = [NSString stringWithFormat:@"[%@]([%@]|%@%@?|[%@]+%@)?", emoji, eMod, variationSelector, keycap, tags, termTag];

    NSString *regexEmoji = [NSString stringWithFormat:@"%@|%@(%@(%@|%@))*", riSequence, element, zwj, riSequence, element];
    return regexEmoji;
}

@end

@implementation NSAttributedString (EmojiExtension)

- (NSString *)tui_getPlainString {
    NSMutableString *plainString = [NSMutableString stringWithString:self.string];
    __block NSUInteger base = 0;

    [self enumerateAttribute:NSAttachmentAttributeName
                     inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                    if (value && [value isKindOfClass:[TUIEmojiTextAttachment class]]) {
                        [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                                   withString:((TUIEmojiTextAttachment *)value).emojiTag];
                        base += ((TUIEmojiTextAttachment *)value).emojiTag.length - 1;
                    }
                  }];

    return plainString;
}

@end
