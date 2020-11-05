//
//  TUILiveGroupLiveMessageHandle.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by coddyliu on 2020/9/28.
//

#import "TUILiveGroupLiveMessageHandle.h"
#import "TUILiveUserProfile.h"
#import "TUILiveRoomAnchorViewController.h"
#import "TUILiveRoomAudienceViewController.h"

@protocol TUIKitMessageSenderProtocol <NSObject>
- (void)sendMessageDict:(NSDictionary *)msgDict;
@end

@interface TUILiveGroupLiveMessageHandle () <TUILiveRoomAnchorDelegate>
@property(nonatomic, weak) id<TUIKitMessageSenderProtocol> msgSender;
@end

@implementation TUILiveGroupLiveMessageHandle

+ (instancetype)shareInstance {
    static TUILiveGroupLiveMessageHandle *__groupLiveMsgHandle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __groupLiveMsgHandle = [[TUILiveGroupLiveMessageHandle alloc] init];
    });
    return __groupLiveMsgHandle;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)startObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyGroupLiveSelectMessage:) name:@"kTUINotifyGroupLiveOnSelectMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyGroupLiveSelectMoreCell:) name:@"kTUINotifyGroupLiveOnSelectMoreCell" object:nil];
}

- (void)stopObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onNotifyGroupLiveSelectMessage:(NSNotification *)notify {
    NSDictionary *info = notify.userInfo;
    NSDictionary *roomInfo = info[@"roomInfo"];
    NSString *groupID = info[@"groupID"];
    // 默认处理流程
    NSString *anchorId = roomInfo[@"anchorId"];
    if (roomInfo[@"roomId"] && anchorId.length > 0) {
        NSString *curUserId = [TUILiveUserProfile getLoginUserInfo].userID;
        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        if ([anchorId isEqual:curUserId]) {
            /// 主播
            self.msgSender = info[@"msgSender"];
            NSString *hashStr = [NSString stringWithFormat:@"%@_%@_liveRoom", groupID, curUserId];
            int roomId = (hashStr.hash & 0x7FFFFFFF);
            TUILiveRoomAnchorViewController *anchorVC = [[TUILiveRoomAnchorViewController alloc] initWithRoomId:roomId];
            [anchorVC enablePK:NO];
            anchorVC.delegate = self;
            [anchorVC setHidesBottomBarWhenPushed:YES];
            [rootVC presentViewController:anchorVC animated:YES completion:nil];
        } else {
            /// 观众
            TUILiveRoomAudienceViewController *audienceVC = [[TUILiveRoomAudienceViewController alloc] initWithRoomId:[roomInfo[@"roomId"] intValue] anchorId:anchorId useCdn:NO cdnUrl:@""];
            [rootVC presentViewController:audienceVC animated:YES completion:nil];
        }
    }
}

- (void)onNotifyGroupLiveSelectMoreCell:(NSNotification *)notify {
    NSDictionary *info = notify.userInfo;
    NSString *groupID = info[@"groupID"];
    self.msgSender = info[@"msgSender"];
    NSString *curUserId = [TUILiveUserProfile getLoginUserInfo].userID;
    NSString *hashStr = [NSString stringWithFormat:@"%@_%@_liveRoom", groupID, curUserId];
    int roomId = (hashStr.hash & 0x7FFFFFFF);
    TUILiveRoomAnchorViewController *anchorVC = [[TUILiveRoomAnchorViewController alloc] initWithRoomId:roomId];
    [anchorVC enablePK:NO];
    anchorVC.delegate = self;
    [anchorVC setHidesBottomBarWhenPushed:YES];
    UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootVC presentViewController:anchorVC animated:YES completion:nil];
}

#pragma mark - TUILiveRoomAnchorDelegate
- (void)onRoomCreate:(TRTCLiveRoomInfo *)roomInfo {
    NSDictionary *msgDict = @{
        @"roomId":roomInfo.roomId?:@"",
        @"roomName":roomInfo.roomName?:@"",
        @"roomCover":roomInfo.coverUrl?:@"",
        @"roomType":@"liveRoom",
        @"roomStatus":@(1),
        @"anchorId":roomInfo.ownerId?:@"",
        @"anchorName":roomInfo.ownerName?:@"",
        @"cellStatus":@(0),
        @"className":@"TUIGroupLiveMessageCellData"
    };
    if (self.msgSender && [self.msgSender respondsToSelector:@selector(sendMessageDict:)]) {
        [self.msgSender sendMessageDict:msgDict];
    }
}

- (void)onRoomDestroy:(TRTCLiveRoomInfo *)roomInfo {
    NSDictionary *msgDict = @{
        @"roomId":roomInfo.roomId?:@"",
        @"roomName":roomInfo.roomName?:@"",
        @"roomCover":roomInfo.coverUrl?:@"",
        @"roomType":@"liveRoom",
        @"roomStatus":@(0),
        @"anchorId":roomInfo.ownerId?:@"",
        @"anchorName":roomInfo.ownerName?:@"",
        @"cellStatus":@(0),
        @"className":@"TUIGroupLiveMessageCellData"
    };
    if (self.msgSender && [self.msgSender respondsToSelector:@selector(sendMessageDict:)]) {
        [self.msgSender sendMessageDict:msgDict];
    }
}

- (void)onRoomError:(TRTCLiveRoomInfo *)roomInfo errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage {
    NSLog(@"TUILiveKit# onRoomError：%d,%@", errorCode, errorMessage);
}

@end
