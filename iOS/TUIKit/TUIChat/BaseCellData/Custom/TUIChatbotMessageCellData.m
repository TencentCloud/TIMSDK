//
//  TUIChatbotMessageCellData.m
//  TUIChat
//
//  Created by Yiliang Wang on 2025/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatbotMessageCellData.h"
#import <TUICore/TUICore.h>

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@implementation TUIChatbotMessageCellData
+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    TUIChatbotMessageCellData *cellData = [[TUIChatbotMessageCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    cellData.content = [self getDisplayString:message];
    cellData.displayedContentLength = 0;
    cellData.reuseId = TTextMessageCell_ReuseId;
    cellData.status = Msg_Status_Init;
    cellData.isFinished = [self getFinishedStatus:message];
    cellData.src = [param[@"src"] doubleValue];
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return @"";
    }
    if ([param[@"src"] doubleValue] == 23) {
        NSString *errorInfo = param[@"errorInfo"];
        return errorInfo.length >0 ? errorInfo : @"";
    }
    NSMutableString *displyString = [NSMutableString string];
    NSArray *chunks = param[@"chunks"];
    for (NSString *chunk in chunks) {
        [displyString appendString:chunk];
    }
    return [displyString copy];
}

+ (BOOL)getFinishedStatus:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return NO;
    }
    
    if ([param[@"src"] doubleValue] == 23) {
        return YES;
    }
    
    BOOL result = NO;
    double isFinishedValue = [param[@"isFinished"] doubleValue];
    result = fabs(isFinishedValue - 1.0) < 0.00001;

    return result;
}
- (BOOL)customReloadCellWithNewMsg:(V2TIMMessage *)newMessage {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:newMessage.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return YES;
    }
    self.innerMessage = newMessage;
    self.content = [self.class getDisplayString:newMessage];
    self.isFinished = [self.class getFinishedStatus:newMessage];
    
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                  object:nil
                   param:@{TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data : self,
                           @"isFinished": self.isFinished ? @"1": @"0"}];
    return YES;
}

- (NSAttributedString *)getContentAttributedString:(UIFont *)textFont {
    self.contentFont = textFont;
    self.contentString = [super getContentAttributedString:textFont];
    if (Msg_Source_OnlinePush == self.source) {
        if (self.displayedContentLength < self.contentString.length) {
            return [self.contentString attributedSubstringFromRange:NSMakeRange(0, self.displayedContentLength + 1)];
        }
    }
    return self.contentString;
}

- (CGSize)getContentAttributedStringSize:(NSAttributedString *)attributeString maxTextSize:(CGSize)maxTextSize {
    CGSize size = [super getContentAttributedStringSize:attributeString maxTextSize:maxTextSize];
    if (size.height > CGFLOAT_CEIL(self.contentFont.lineHeight)) {
        return CGSizeMake(TTextMessageCell_Text_Width_Max, size.height);
    } else {
        return size;
    }
}
@end
