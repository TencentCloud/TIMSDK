//
//  TUIConversationCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationCellData.h"

@implementation TUIConversationCellData

@synthesize title;
@synthesize userID;
@synthesize groupID;
@synthesize groupType;
@synthesize avatarImage;
@synthesize conversationID;
@synthesize draftText;
@synthesize faceUrl;

- (CGFloat)heightOfWidth:(CGFloat)width {
    if (self.isLiteMode) {
        return TConversationCell_Height_LiteMode;
    } else {
        return TConversationCell_Height;
    }
}

+ (BOOL)isMarkedByHideType:(NSArray *)markList {
    for (NSNumber *num in markList) {
        if (num.unsignedLongValue == V2TIM_CONVERSATION_MARK_TYPE_HIDE) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isMarkedByUnReadType:(NSArray *)markList {
    for (NSNumber *num in markList) {
        if (num.unsignedLongValue == V2TIM_CONVERSATION_MARK_TYPE_UNREAD) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isMarkedByFoldType:(NSArray *)markList {
    for (NSNumber *num in markList) {
        if (num.unsignedLongValue == V2TIM_CONVERSATION_MARK_TYPE_FOLD) {
            return YES;
        }
    }
    return NO;
}

@end
