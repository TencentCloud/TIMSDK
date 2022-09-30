//
//  NSString+emoji.m
//  TUIChat
//
//  Created by harvy on 2021/11/15.
//

#import "NSString+emoji.h"
#import "TUIConfig.h"

@implementation NSString (emoji)

- (NSString *)getLocalizableStringWithFaceContent
{
    NSString *content = self;
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; // match emoji
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (re) {
        NSArray *resultArray = [re matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        TUIFaceGroup *group = [TUIConfig defaultConfig].faceGroups[0];
        NSMutableArray *waitingReplaceM = [NSMutableArray array];
        for(NSTextCheckingResult *match in resultArray) {
            NSRange range = [match range];
            NSString *subStr = [content substringWithRange:range];
            for (TUIFaceCellData *face in group.faces) {
                if ([face.name isEqualToString:subStr]) {
                    [waitingReplaceM addObject:@{
                        @"range":NSStringFromRange(range),
                        @"localizableStr": face.localizableName.length?face.localizableName:face.name
                    }];
                    break;
                }
            }
        }
        
        if (waitingReplaceM.count) {
            /**
             * 从后往前替换，否则会引起位置问题
             * Replace from back to front, otherwise it will cause positional problems
             */
            for (int i = (int)waitingReplaceM.count -1; i >= 0; i--) {
                NSRange range = NSRangeFromString(waitingReplaceM[i][@"range"]);
                NSString *localizableStr = waitingReplaceM[i][@"localizableStr"];
                content = [content stringByReplacingCharactersInRange:range withString:localizableStr];
            }
        }
    }
    return content;
}

- (NSString *)getInternationalStringWithfaceContent
{
    NSString *content = self;
    NSString *regex_emoji = @"\\[[a-z\\s*A-Z\\s*0-9!-@\\/\\u4e00-\\u9fa5]+\\]"; // match emoji
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (re) {
        NSMutableDictionary *faceDict = [NSMutableDictionary dictionary];
        TUIFaceGroup *group = [TUIConfig defaultConfig].faceGroups[0];
        for (TUIFaceCellData *face in group.faces) {
            NSString *key = face.localizableName?:face.name;
            NSString *value = face.name?:@"";
            faceDict[key] = value;
        }
        
        NSArray *resultArray = [re matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        NSMutableArray *waitingReplaceM = [NSMutableArray array];
        for(NSTextCheckingResult *match in resultArray) {
            NSRange range = [match range];
            NSString *subStr = [content substringWithRange:range];
            [waitingReplaceM addObject:@{
                @"range":NSStringFromRange(range),
                @"localizableStr": faceDict[subStr]?:subStr
            }];
        }
        
        if (waitingReplaceM.count != 0) {
            /**
             * 从后往前替换，否则会引起位置问题
             * Replace from back to front, otherwise it will cause positional problems
             */
            for (int i = (int)waitingReplaceM.count -1; i >= 0; i--) {
                NSRange range = NSRangeFromString(waitingReplaceM[i][@"range"]);
                NSString *localizableStr = waitingReplaceM[i][@"localizableStr"];
                content = [content stringByReplacingCharactersInRange:range withString:localizableStr];
            }
        }
    }
    return content;
}




- (NSMutableAttributedString *)getFormatEmojiStringWithFont:(UIFont *)textFont emojiLocations:(nullable NSMutableArray<NSDictionary<NSValue *, NSAttributedString *> *> *)emojiLocations
{
    /**
     * 先判断 text 是否存在
     * First determine whether the text exists
     */
    if (self.length == 0) {
        NSLog(@"getFormatEmojiStringWithFont failed , current text is nil");
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    /**
     * 1. 创建一个可变的属性字符串
     * Create a mutable attributed string
     */
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    if([TUIConfig defaultConfig].faceGroups.count == 0){
        [attributeString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributeString.length)];
        return attributeString;
    }

    /**
     * 2. 通过正则表达式来匹配字符串
     * Match strings with regular expressions
     */
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; // match emoji

    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }

    NSArray *resultArray = [re matchesInString:self options:0 range:NSMakeRange(0, self.length)];

    TUIFaceGroup *group = [TUIConfig defaultConfig].faceGroups[0];

    /**
     * 3. 获取所有的表情以及位置
     * - 用来存放字典，字典中存储的是图片和图片对应的位置
     *
     * Getting all emotes and locations
     * - Used to store the dictionary, the dictionary stores the image and the corresponding location of the image
     */
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    /**
     * 根据匹配范围来用图片进行相应的替换
     * Replace the image with the corresponding image according to the matching range
     */
    for(NSTextCheckingResult *match in resultArray) {
        /**
         * 获取数组元素中得到range
         * Get the range in the array element
         */
        NSRange range = [match range];
        /**
         * 获取原字符串中对应的值
         * Get the corresponding value in the original string
         */
        NSString *subStr = [self substringWithRange:range];

        for (TUIFaceCellData *face in group.faces) {
            if ([face.name isEqualToString:subStr]) {
                /**
                 * face[i][@"png"]就是我们要加载的图片
                 * face[i][@"png"] is the image we want to load
                 */
                
                /**
                 * - 新建 NSTextAttachment 来存放我们的图片
                 * - Create a new NSTextAttachment to store our image
                 */
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                /**
                 * - 给附件添加图片
                 * - Add pictures to attachments
                 */
                textAttachment.image = [[TUIImageCache sharedInstance] getFaceFromCache:face.path];
                /**
                 * - 调整一下图片的位置,如果你的图片偏上或者偏下，调整一下 bounds 的 y 值即可
                 * - Adjust the position of the picture. If your picture is up or down, adjust the y value of bounds
                 */
                textAttachment.bounds = CGRectMake(0, -(textFont.lineHeight-textFont.pointSize)/2, textFont.pointSize, textFont.pointSize);
                /**
                 * - 把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                 * - Convert attachments to mutable strings to replace emoji text in source strings
                 */
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                /**
                 * - 把图片和图片对应的位置存入字典中
                 * - Save the picture and the corresponding position of the picture into the dictionary
                 */
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                /**
                 * - 把字典存入数组中
                 * - Store dictionary in array
                 */
                [imageArray addObject:imageDic];
                break;
            }
        }
    }

    /**
     * 4. 从后往前替换，否则会引起位置问题
     * Replace from back to front, otherwise it will cause positional problems
     */
    NSMutableArray *locations = [NSMutableArray array];
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange originRange;
        [imageArray[i][@"range"] getValue:&originRange];
        
        /**
         * 存储位置信息
         * Store location information
         */
        NSAttributedString *originStr = [attributeString attributedSubstringFromRange:originRange];
        NSAttributedString *currentStr = imageArray[i][@"image"];
        [locations insertObject:@[[NSValue valueWithRange:originRange], originStr, currentStr] atIndex:0];
        
        // Replace
        [attributeString replaceCharactersInRange:originRange withAttributedString:currentStr];
    }
    
    /**
     * 5. 获取 emoji 转换后字符串的位置信息
     * Getting the position information of the converted string of emoji
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
    TUIFaceGroup *group = [TUIConfig defaultConfig].faceGroups[0];

    NSString *loaclName = [self getLocalizableStringWithFaceContent];
    for (TUIFaceCellData *face in group.faces) {
        if ([face.localizableName isEqualToString:loaclName]) {
            return face.path;
        }
    }
    return nil;
    
}

- (UIImage *)getEmojiImage {
    TUIFaceGroup *group = [TUIConfig defaultConfig].faceGroups[0];

    for (TUIFaceCellData *face in group.faces) {
        if ([face.name isEqualToString:self]) {
            return [[TUIImageCache sharedInstance] getFaceFromCache:face.path];
        }
    }
    return nil;
    
}

- (NSMutableAttributedString *)getAdvancedFormatEmojiStringWithFont:(UIFont *)textFont
                                                          textColor:(UIColor *)textColor
                                                     emojiLocations:(nullable NSMutableArray<NSDictionary<NSValue *, NSAttributedString *> *> *)emojiLocations
{
    if (self.length == 0) {
        NSLog(@"getAdvancedFormatEmojiStringWithFont failed , current text is nil");
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    if([TUIConfig defaultConfig].faceGroups.count == 0){
        [attributeString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributeString.length)];
        return attributeString;
    }

    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //match emoji

    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }

    NSArray *resultArray = [re matchesInString:self options:0 range:NSMakeRange(0, self.length)];

    TUIFaceGroup *group = [TUIConfig defaultConfig].faceGroups[0];

    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];

    for(NSTextCheckingResult *match in resultArray) {
 
        NSRange range = [match range];
 
        NSString *subStr = [self substringWithRange:range];

        for (TUIFaceCellData *face in group.faces) {
            if ([face.name isEqualToString:subStr] ||[face.localizableName isEqualToString:subStr]) {
                TUIEmojiTextAttachment *emojiTextAttachment = [[TUIEmojiTextAttachment alloc] init];
                emojiTextAttachment.faceCellData = face;

                NSString *localizableFaceName = face.localizableName.length ? face.localizableName : face.name;

                //Set tag and image
                emojiTextAttachment.emojiTag = localizableFaceName;
                emojiTextAttachment.image =  [[TUIImageCache sharedInstance] getFaceFromCache:face.path];
                
                //Set emoji size
                emojiTextAttachment.emojiSize = kChatDefaultEmojiSize;
                
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
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange originRange;
        [imageArray[i][@"range"] getValue:&originRange];
        
        NSAttributedString *originStr = [attributeString attributedSubstringFromRange:originRange];
        NSAttributedString *currentStr = imageArray[i][@"image"];
        [locations insertObject:@[[NSValue valueWithRange:originRange], originStr, currentStr] atIndex:0];
        
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


@end

@implementation NSAttributedString (EmojiExtension)

- (NSString *)getPlainString {
    NSMutableString *plainString = [NSMutableString stringWithString:self.string];
    __block NSUInteger base = 0;
    
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                      if (value && [value isKindOfClass:[TUIEmojiTextAttachment class]]) {
                          [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                                     withString:((TUIEmojiTextAttachment *) value).emojiTag];
                          base += ((TUIEmojiTextAttachment *) value).emojiTag.length - 1;
                      }
                  }];
    
    return plainString;
}

@end

