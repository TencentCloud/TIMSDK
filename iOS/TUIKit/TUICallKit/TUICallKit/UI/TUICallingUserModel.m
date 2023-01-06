//
//  TUICallingUserModel.m
//  TUICallKit
//
//  Created by noah on 2022/8/4.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUICallingUserModel.h"
#import "TUICallKitConstants.h"

@implementation CallingUserModel

- (id)copyWithZone:(NSZone *)zone {
    CallingUserModel * model = [[CallingUserModel alloc] init];
    model.userId = self.userId;
    model.name = self.name;
    model.avatar = self.avatar;
    model.isEnter = self.isEnter;
    model.isVideoAvailable = self.isVideoAvailable;
    model.isAudioAvailable = self.isAudioAvailable;
    model.volume = self.volume;
    return model;
}

- (NSString *)avatar {
    return _avatar ?: TUI_CALL_DEFAULT_AVATAR;
}

@end
