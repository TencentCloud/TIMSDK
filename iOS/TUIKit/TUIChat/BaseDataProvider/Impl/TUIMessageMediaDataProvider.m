//
//  TUIMessageSearchDataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageMediaDataProvider.h"
#import "TUIImageMessageCellData.h"
#import "TUIMessageBaseDataProvider+ProtectedAPI.h"
#import "TUIVideoMessageCellData.h"

@implementation TUIMessageMediaDataProvider

+ (TUIMessageCellData *)getMediaCellData:(V2TIMMessage *)message {
    if (message.status == V2TIM_MSG_STATUS_HAS_DELETED || message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        return nil;
    }
    TUIMessageCellData *data = nil;
    if (message.elemType == V2TIM_ELEM_TYPE_IMAGE) {
        data = [TUIImageMessageCellData getCellData:message];
    } else if (message.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        data = [TUIVideoMessageCellData getCellData:message];
    }
    if (data) {
        data.innerMessage = message;
    }
    return data;
}

@end
