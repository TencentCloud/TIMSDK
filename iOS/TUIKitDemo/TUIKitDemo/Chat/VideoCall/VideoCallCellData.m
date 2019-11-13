//
//  VideoCallCellData.m
//  TUIKitDemo
//
//  Created by xcoderliu on 9/29/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "VideoCallCellData.h"
#import "VideoCallManager.h"

@implementation VideoCallCellData

- (CGSize)contentSize {
    NSString *result = @"已结束";
    BOOL isOutGoing = [self isOutGoingResult];
    if (isOutGoing) {
        if (_videoState == VIDEOCALL_USER_CANCEL) {
            result = @"已取消";
        } else if (_videoState == VIDEOCALL_USER_REJECT) {
            result = @"对方已拒绝";
        } else if (_videoState == VIDEOCALL_USER_NO_RESP) {
            result = @"对方无应答";
        } else if (_videoState == VIDEOCALL_USER_HANUGUP) {
            result = [NSString stringWithFormat:@"已结束 %@",[self getMMSSFromSS:_duration]];
        }
    } else {
        if (_videoState == VIDEOCALL_USER_CANCEL) {
            result = @"未接通";
        } else if (_videoState == VIDEOCALL_USER_REJECT) {
            result = @"未接通";
        } else if (_videoState == VIDEOCALL_USER_NO_RESP) {
            result = @"未接通";
        } else if (_videoState == VIDEOCALL_USER_HANUGUP) {
            result = [NSString stringWithFormat:@"已结束 %@",[self getMMSSFromSS:_duration]];
        }
    }
    NSString *content = isOutGoing ?
    [NSString stringWithFormat:@"%@  [videoCallOut]",result] :
    [NSString stringWithFormat:@"[videoCall]  %@",result];
    self.content = content;
   return [super contentSize];
}

- (NSAttributedString *)formatMessageString:(NSString *)text
{
    //先判断text是否存在
    if (text == nil || text.length == 0) {
        NSLog(@"TTextMessageCell formatMessageString failed , current text is nil");
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];

    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情

    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }

    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    //3、获取所有的表情以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [text substringWithRange:range];
        
        if ([subStr hasPrefix:@"[videoCall"]) {
            //新建文字附件来存放我们的图片,iOS7才新加的对象
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            //给附件添加图片
            textAttachment.image = [UIImage imageNamed: [subStr hasPrefix:@"[videoCallOut"] ? @"videocall_out" : @"videocall"];
            //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
            textAttachment.bounds = CGRectMake(0, -(self.textFont.lineHeight-self.textFont.pointSize*0.3)/2, self.textFont.pointSize*1.6, self.textFont.pointSize*1.6);
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

    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }

    [attributeString addAttribute:NSFontAttributeName value:self.textFont range:NSMakeRange(0, attributeString.length)];

    return attributeString;
}

/// 当前的结果是对方请求视频还是己方
- (BOOL)isOutGoingResult {
   BOOL isOutGoing = self.isSelf;
    UInt32 state = self.videoState;
    if (state == VIDEOCALL_USER_REJECT || state == VIDEOCALL_USER_ONCALLING) { //由我发起请求，对方发送结果
         isOutGoing = !isOutGoing;
    }
    
    if (self.requestUser != nil) {
        NSString *currentUser = [[VideoCallManager shareInstance] currentUserIdentifier];
        isOutGoing = (self.requestUser == currentUser);
    }
    return isOutGoing;
}

-(NSString *)getMMSSFromSS:(UInt32)seconds {
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02d",seconds / 60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02d",seconds % 60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}
@end
