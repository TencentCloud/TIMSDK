//
//  TUIMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageCellData.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIMessageCellData ()

@end

@implementation TUIMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    return nil;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return nil;
}

- (Class)getReplyQuoteViewDataClass {
    return nil;
}

- (Class)getReplyQuoteViewClass {
    return nil;
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super init];
    if (self) {
        _direction = direction;
        _status = Msg_Status_Init;
        _source = Msg_Source_Unkown;
        _showReadReceipt = YES;
        _sameToNextMsgSender = NO;
        _showAvatar = YES;
        _cellLayout = [self cellLayout:direction];
        _additionalUserInfoResult = @{};
    }
    return self;
}

- (TUIMessageCellLayout *)cellLayout:(TMsgDirection)direction {
    if (direction == MsgDirectionIncoming) {
        return [TUIMessageCellLayout incommingMessageLayout];
    } else {
        return [TUIMessageCellLayout outgoingMessageLayout];
    }
}

- (BOOL)canForward {
    return YES;
}

- (BOOL)canLongPress {
    return YES;
}

- (BOOL)shouldHide {
    return NO;
}

- (BOOL)customReloadCellWithNewMsg:(V2TIMMessage *)newMessage {
    return NO;
}

- (CGSize)msgStatusSize {
    if (self.direction == MsgDirectionOutgoing) {
        return CGSizeMake(54, 14);
    } else {
        return CGSizeMake(38, 14);
    }
}

- (NSDictionary *)messageModifyUserInfos {
  return self.additionalUserInfoResult;
}

- (NSArray<NSString *> *)requestForAdditionalUserInfo {
  return @[];
}

@end
