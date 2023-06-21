//
//  TUIMessageSearchDataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageMediaDataProvider_Minimalist.h"
#import "TUIImageMessageCellData_Minimalist.h"
#import "TUIMessageBaseDataProvider+ProtectedAPI.h"
#import "TUIVideoMessageCellData_Minimalist.h"

@implementation TUIMessageMediaDataProvider_Minimalist

+ (TUIMessageCellData *)getMediaCellData:(V2TIMMessage *)message {
    if (message.status == V2TIM_MSG_STATUS_HAS_DELETED || message.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
        return nil;
    }
    TUIMessageCellData *data = nil;
    if (message.elemType == V2TIM_ELEM_TYPE_IMAGE) {
        data = [TUIImageMessageCellData_Minimalist getCellData:message];
    } else if (message.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        data = [TUIVideoMessageCellData_Minimalist getCellData:message];
    }
    if (data) {
        data.innerMessage = message;
    }
    return data;
}

@end
