//
//  TUICallKitGroupMemberInfo.m
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/11.
//  Copyright © 2021 Tencent. All rights reserved


#import "TUICallKitGroupMemberInfo.h"
#import "TUICallKitConstants.h"

@implementation TUICallKitGroupMemberInfo

- (NSString *)avatar {
    return _avatar ?: TUI_CALL_DEFAULT_AVATAR;
}

@end
