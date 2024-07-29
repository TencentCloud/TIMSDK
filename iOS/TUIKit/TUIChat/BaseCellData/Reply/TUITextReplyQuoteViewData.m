//
//  TUITextReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextReplyQuoteViewData.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import "TUITextMessageCellData.h"

@implementation TUITextReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TUITextMessageCellData.class]) {
        return nil;
    }

    TUITextReplyQuoteViewData *myData = [[TUITextReplyQuoteViewData alloc] init];
    myData.text = [(TUITextMessageCellData *)originCellData content];
    myData.originCellData = originCellData;
    return myData;
}

- (CGSize)contentSize:(CGFloat)maxWidth {
    NSAttributedString *attributeString = nil;
    BOOL showRevokeStr = (self.originCellData.innerMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) &&
                            !self.showRevokedOriginMessage;
    if (showRevokeStr) {
        NSString * revokeStr = self.supportForReply?
        TIMCommonLocalizableString(TUIKitRepliesOriginMessageRevoke):
        TIMCommonLocalizableString(TUIKitReferenceOriginMessageRevoke);
        attributeString = [revokeStr getFormatEmojiStringWithFont:[UIFont systemFontOfSize:10.0] emojiLocations:nil];
    } else {
        attributeString = [self.text getFormatEmojiStringWithFont:[UIFont systemFontOfSize:10.0] emojiLocations:nil];
    }
    
    CGSize size = [@"0" sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0]}];
    CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(maxWidth, size.height * 2)
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                context:nil];
    CGFloat h = rect.size.height < size.height * 2 ? rect.size.height : size.height * 2;
    if (showRevokeStr && self.supportForReply) {
        h = size.height *2;
    }
    return CGSizeMake(rect.size.width, h);
}

@end
