//
//  TRTCCall.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/2.
//

#import "TUICall.h"
#import "TUICallUtils.h"
#import "TUICall+TRTC.h"
#import "TUICall+Signal.h"

@implementation TUICall {
    BOOL _isOnCalling;
    NSString *_curCallID;
}

+(TUICall *)shareInstance {
    static dispatch_once_t onceToken;
    static TUICall * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUICall alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.curLastModel = [[CallModel alloc] init];
        self.curLastModel.invitedList = [NSMutableArray array];
        self.curRespList = [NSMutableArray array];
        self.curRoomList = [NSMutableArray array];
        [self addSignalListener];
    }
    return self;
}

- (void)dealloc {
    [self removeSignalListener];
}

- (void)call:(NSArray *)userIDs groupID:(NSString *)groupID type:(CallType)type {
    if (!self.isOnCalling) {
        self.curLastModel.inviter = [TUICallUtils loginUser];
        self.curLastModel.action = CallAction_Call;
        self.curLastModel.calltype = type;
        self.curRoomID = [TUICallUtils generateRoomID];
        self.curGroupID = groupID;
        self.curType = type;
        self.isOnCalling = YES;
        [self enterRoom];
    }
    // 不在当前邀请列表，新增加的邀请
    NSMutableArray *newInviteList = [NSMutableArray array];
    for (NSString *userID in userIDs) {
        if (![self.curInvitingList containsObject:userID]) {
            [newInviteList addObject:userID];
        }
    }
    [self.curInvitingList addObjectsFromArray:newInviteList];
    
    // 更新已经回复的列表，移除正在邀请的人
    NSMutableArray *rmRespList = [NSMutableArray array];
    for (NSString *userID in self.curRespList) {
        if ([self.curInvitingList containsObject:userID]) {
            [rmRespList addObject:userID];
        }
    }
    [self.curRespList removeObjectsInArray:rmRespList];
    
    //通话邀请
    if (self.curGroupID.length > 0 && newInviteList.count > 0) {
        self.curCallID = [self invite:self.curGroupID action:CallAction_Call model:nil];
    } else {
        for (NSString *userID in newInviteList) {
            self.curCallID = [self invite:userID action:CallAction_Call model:nil];
        }
    }
}

// 接受当前通话
- (void)accept {
    [self enterRoom];
    [self invite:self.curGroupID.length > 0 ? self.curGroupID : self.curSponsorForMe action:CallAction_Accept model:nil];
    [self.curInvitingList removeObject:[TUICallUtils loginUser]];
}

// 拒绝当前通话
- (void)reject {
    [self invite:self.curGroupID.length > 0 ? self.curGroupID : self.curSponsorForMe action:CallAction_Reject model:nil];
    self.isOnCalling = NO;
}

// 主动挂断通话
- (void)hangup {
    if (!self.isOnCalling) {
        return;
    }
    if (!self.isInRoom) {
        [self reject];
        return;
    }
    // 没人在通话，取消通话
    // 这个函数供界面主动挂断使用，主动挂断的群通话，不能发 end 事件，end 事件由最后一名成员发出(记录通话时长)
    if (self.curRoomList.count == 0 && self.curInvitingList.count > 0) {
        if (self.curGroupID.length > 0) {
            [self invite:self.curGroupID action:CallAction_Cancel model:nil];
        } else {
            [self invite:self.curInvitingList.firstObject action:CallAction_Cancel model:nil];
        }
    }
    [self quitRoom];
    self.isOnCalling = NO;
}

#pragma mark data
- (void)setIsOnCalling:(BOOL)isOnCalling {
    if (isOnCalling && _isOnCalling != isOnCalling) {
        //开始通话
    } else if (!isOnCalling && _isOnCalling != isOnCalling) { //退出通话
        self.curCallID = @"";
        self.curRoomID = 0;
        self.curType = CallAction_Unknown;
        self.curSponsorForMe = @"";
        self.isInRoom = NO;
        self.startCallTS = 0;
        self.curLastModel = [[CallModel alloc] init];
        self.curInvitingList = [NSMutableArray array];
        self.curRespList = [NSMutableArray array];
        self.curRoomList = [NSMutableArray array];
    }
    _isOnCalling = isOnCalling;
}

- (BOOL)isOnCalling {
    return _isOnCalling;
}

- (void)setCurCallID:(NSString *)curCallID {
    self.curLastModel.callid = curCallID;
}

- (NSString *)curCallID {
    return self.curLastModel.callid;
}

- (void)setCurInvitingList:(NSMutableArray *)curInvitingList {
    self.curLastModel.invitedList = curInvitingList;
}

- (NSMutableArray *)curInvitingList {
    return self.curLastModel.invitedList;
}

- (void)setCurRoomID:(UInt32)curRoomID {
    self.curLastModel.roomid = curRoomID;
}

- (UInt32)curRoomID {
    return self.curLastModel.roomid;
}

- (void)setCurType:(CallType)curType {
    self.curLastModel.calltype = curType;
}

- (CallType)curType {
    return self.curLastModel.calltype;
}

- (void)setCurGroupID:(NSString *)curGroupID {
    self.curLastModel.groupid = curGroupID;
}

- (NSString *)curGroupID {
    return self.curLastModel.groupid;
}

@end
