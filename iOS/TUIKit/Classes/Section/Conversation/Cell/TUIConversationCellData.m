//
//  TUIConversationCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//

#import "TUIConversationCellData.h"
#import "THeader.h"
#import "UIImage+TUIKIT.h"
#import "TIMUserProfile+DataProvider.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TIMMessage+DataProvider.h"
#import "TUIKit.h"

@implementation TUIConversationCellData

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TConversationCell_Height;
}

- (BOOL)isEqual:(TUIConversationCellData *)object
{
    return [self.conversationID isEqual:object.conversationID];
}

@end
