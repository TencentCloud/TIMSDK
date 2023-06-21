//
//  TUIContactConversationCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactConversationCellData_Minimalist.h"
#import "TUIDefine.h"

@implementation TUIContactConversationCellData_Minimalist

@synthesize title;
@synthesize userID;
@synthesize groupID;
@synthesize groupType;
@synthesize avatarImage;
@synthesize conversationID;
@synthesize draftText;
@synthesize faceUrl;

- (CGFloat)heightOfWidth:(CGFloat)width {
    return TConversationCell_Height;
}

- (BOOL)isEqual:(TUIContactConversationCellData_Minimalist *)object {
    return [self.conversationID isEqual:object.conversationID];
}

@end
