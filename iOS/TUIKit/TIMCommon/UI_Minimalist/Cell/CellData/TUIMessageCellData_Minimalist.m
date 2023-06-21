//
//  TUIBubbleMessageCellData_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageCellData_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMessageCellLayout.h"

@implementation TUIMessageCellData_Minimalist

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        self.showName = NO;
        self.showReadReceipt = NO;
    }
    return self;
}

- (CGSize)messageModifyReactsSize {
    return CGSizeZero;
}

- (CGFloat)heightOfWidth:(CGFloat)width {
    CGFloat height = [super heightOfWidth:width];

    if (self.messageModifyReacts.count > 0) {
        height += 16;
    }

    if (self.sameToNextMsgSender) {
        height -= 16;
    }

    return height;
}

- (CGSize)msgStatusSize {
    if (self.direction == MsgDirectionOutgoing) {
        return CGSizeMake(54, 14);
    } else {
        return CGSizeMake(38, 14);
    }
}

@end
