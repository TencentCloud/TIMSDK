//
//  TUIConversationCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
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

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TConversationCell_Height;
}

- (BOOL)isEqual:(TUIConversationCellData *)object
{
    return [self.conversationID isEqual:object.conversationID];
}


@end
