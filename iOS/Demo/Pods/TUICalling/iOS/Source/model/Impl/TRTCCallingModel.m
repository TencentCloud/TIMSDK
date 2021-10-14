//
//  TRTCCallingModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/2.
//

#import "TRTCCallingModel.h"

int SIGNALING_EXTRA_KEY_TIME_OUT = 30;

@implementation CallModel

- (id)copyWithZone:(NSZone *)zone {
    CallModel * model = [[CallModel alloc] init];
    model.version = self.version;
    model.calltype = self.calltype;
    model.groupid = self.groupid;
    model.callid = self.callid;
    model.roomid = self.roomid;
    model.action = self.action;
    model.code = self.code;
    model.invitedList = self.invitedList;
    model.inviter = self.inviter;
    return model;
}

@end


@implementation TRTCCallingUserModel

- (id)copyWithZone:(NSZone *)zone {
    TRTCCallingUserModel * model = [[TRTCCallingUserModel alloc] init];
    model.userId = self.userId;
    model.name = self.name;
    model.avatar = self.avatar;
    return model;
}

@end


@implementation CallUserModel

- (id)copyWithZone:(NSZone *)zone {
    CallUserModel * model = [[CallUserModel alloc] init];
    model.userId = self.userId;
    model.name = self.name;
    model.avatar = self.avatar;
    model.isEnter = self.isEnter;
    model.isVideoAvaliable = self.isVideoAvaliable;
    model.volume = self.volume;
    return model;
}

@end
