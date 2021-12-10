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
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情
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
            // 从后往前替换，否则会引起位置问题
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
    NSString *regex_emoji = @"\\[[a-z\\s*A-Z\\s*0-9!-@\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情
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
            // 从后往前替换，否则会引起位置问题
            for (int i = (int)waitingReplaceM.count -1; i >= 0; i--) {
                NSRange range = NSRangeFromString(waitingReplaceM[i][@"range"]);
                NSString *localizableStr = waitingReplaceM[i][@"localizableStr"];
                content = [content stringByReplacingCharactersInRange:range withString:localizableStr];
            }
        }
    }
    return content;
}




- (NSAttributedString *)getFormatEmojiStringWithFont:(UIFont *)textFont
{
    //先判断text是否存在
    if (self.length == 0) {
        NSLog(@"getFormatEmojiStringWithFont failed , current text is nil");
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    if([TUIConfig defaultConfig].faceGroups.count == 0){
        [attributeString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributeString.length)];
        return attributeString;
    }

    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情

    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }

    NSArray *resultArray = [re matchesInString:self options:0 range:NSMakeRange(0, self.length)];

    TUIFaceGroup *group = [TUIConfig defaultConfig].faceGroups[0];

    //3、获取所有的表情以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [self substringWithRange:range];

        for (TUIFaceCellData *face in group.faces) {
            if ([face.name isEqualToString:subStr]) {
                //face[i][@"png"]就是我们要加载的图片
                //新建文字附件来存放我们的图片,iOS7才新加的对象
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                //给附件添加图片
                textAttachment.image = [[TUIImageCache sharedInstance] getFaceFromCache:face.path];
                //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
                textAttachment.bounds = CGRectMake(0, -(textFont.lineHeight-textFont.pointSize)/2, textFont.pointSize, textFont.pointSize);
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //把字典存入数组中
                [imageArray addObject:imageDic];
                break;
            }
        }
    }

    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }


    [attributeString addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, attributeString.length)];

    return attributeString;
}


@end
