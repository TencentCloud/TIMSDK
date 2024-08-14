//
//  TUIBotStreamTextCellData.m
//  TUICustomerServicePlugin
//
//  Created by lynx on 2023/10/30.
//

#import "TUIBotStreamTextCellData.h"
#import <TUICore/TUICore.h>

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@implementation TUIBotStreamTextCellData
+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    TUIBotStreamTextCellData *cellData = [[TUIBotStreamTextCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.innerMessage = message;
    cellData.content = [self getDisplayString:message];
    cellData.displayedContentLength = 0;
    cellData.reuseId = TTextMessageCell_ReuseId;
    cellData.status = Msg_Status_Init;
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return @"";
    }
    NSMutableString *displyString = [NSMutableString string];
    NSArray *chunks = param[@"chunks"];
    for (NSString *chunk in chunks) {
        [displyString appendString:chunk];
    }
    return [displyString copy];
}

- (BOOL)customReloadCellWithNewMsg:(V2TIMMessage *)newMessage {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:newMessage.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return YES;
    }
    NSString *newContent = [self.class getDisplayString:newMessage];
    if (newContent.length <= self.content.length) {
        return YES;
    }
    self.innerMessage = newMessage;
    self.content = [self.class getDisplayString:newMessage];
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey
                  object:nil
                   param:@{TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data : self}];
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
