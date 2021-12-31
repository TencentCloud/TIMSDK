//
//  TUILiveRoomListViewController.m
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveRoomListViewController.h"
#import "TUILiveRoomListCell.h"
#import "TUILiveRoomInfo.h"
#import "TUILiveRoomManager.h"
#import <Masonry/Masonry.h>
#import "TUILiveRoomListView.h"
#import "TRTCLiveRoom.h"
#import "GenerateTestUserSig.h"
#import "TUIDarkModel.h"
#import "TUIKit.h"
#import "TUIKitLive.h"

@interface TUILiveRoomListViewController ()<TUILiveRoomListDelegate, TUILiveRoomAudienceDelegate>

@property(nonatomic, nonnull, strong)NSMutableArray *roomList;
@property(nonatomic, nonnull, strong)TUILiveRoomListView *rootView;
@property(nonatomic, strong) NSArray *roomInfoList;

@property(nonatomic, copy)TUICreateActionCallback createRoomCallback;

@end

@implementation TUILiveRoomListViewController

-(NSMutableArray *)roomList {
    if (!_roomList) {
        _roomList = [NSMutableArray array];
    }
    return _roomList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getRoomList];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getRoomList];
}

- (void)setCreateRoomAction:(TUICreateActionCallback)callback {
    self.createRoomCallback = callback;
}

- (void)loadView {
    TUILiveRoomListView* rootView = [[TUILiveRoomListView alloc] init];
    rootView.delegate = self;
    rootView.backgroundColor = [UIColor d_colorWithColorLight:UIColor.whiteColor dark:TController_Background_Color_Dark];
    
    self.rootView = rootView; // 这里引用下rootview方便调用刷新方法
    self.view = rootView;
}

- (void)getRoomIDList:(RoomIDListCallback)callback {
    [[TUILiveRoomManager sharedManager] getRoomList:SDKAPPID type:@"liveRoom" success:^(NSArray<NSString *> * _Nonnull roomIds) {
        callback(roomIds);
    } failed:^(int code, NSString * _Nonnull errorMsg) {
        callback(@[]);
    }];
}

- (void)getRoomList {
    [[TUILiveRoomManager sharedManager] getRoomList:SDKAPPID type:@"liveRoom" success:^(NSArray<NSString *> * _Nonnull roomIds) {
        NSMutableArray<NSNumber *> *roomIDNumberValues = [[NSMutableArray alloc] init];
        [roomIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj intValue]) {
                [roomIDNumberValues addObject:@([obj intValue])];
            }
        }];
        [[TRTCLiveRoom sharedInstance] getRoomInfosWithRoomIDs:roomIDNumberValues callback:^(int code, NSString * _Nullable message, NSArray<TRTCLiveRoomInfo *> * _Nonnull roomList) {
            self.roomInfoList = roomList;
            NSMutableArray* tempArr = [NSMutableArray arrayWithCapacity:2];
            [roomList enumerateObjectsUsingBlock:^(TRTCLiveRoomInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TUILiveRoomInfo *info = [[TUILiveRoomInfo alloc] init];
                info.roomID = [obj.roomId intValue];
                info.roomName = obj.roomName;
                info.ownerId = obj.ownerId;
                info.memberCount = obj.memberCount;
                info.ownerName = obj.ownerName;
                info.coverUrl = obj.coverUrl;
                [tempArr addObject:info];
            }];
            self.roomList = [tempArr mutableCopy];
            [self.rootView refreshList];
        }];
        [self.rootView endRefreshState];
    } failed:^(int code, NSString * _Nonnull errorMsg) {
        NSLog(@"拉取房间列表失败");
    }];
    
}

#pragma mark - TUIListdelegate
- (void)enterRoom:(TUILiveRoomInfo *)room {
    NSString *currentLoginUserID = [V2TIMManager sharedInstance].getLoginUser;
    if ([room.ownerId isEqualToString:currentLoginUserID]) {
        if (self.createRoomCallback) {
            self.createRoomCallback();
        }
        return;
    }
    // 进入房间，依赖TUIKit_Live
    TRTCLiveRoomInfo *roomInfo = nil;
    NSInteger curIndex = 0;
    for (TRTCLiveRoomInfo *info in self.roomInfoList) {
        if (info.roomId.integerValue == room.roomID) {
            roomInfo = info;
            break;
        }
        curIndex ++;
    }
    if (!roomInfo) {
        return;
    }
    BOOL useCdnPlay = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TUIKitDemo_useCdnPlay"] boolValue];
    TUILiveRoomAudienceViewController *audienceVC = nil;
    if (useCdnPlay) {
        NSString *url = [NSString stringWithFormat:@"http://tuikit.qcloud.com/live/%d_%d_%@_main.flv", SDKAPPID, (int)room.roomID, room.ownerId];
        audienceVC = [[TUILiveRoomAudienceViewController alloc] initWithRoomId:(int)room.roomID anchorId:room.ownerId useCdn:YES cdnUrl:url];
    } else {
        audienceVC = [[TUILiveRoomAudienceViewController alloc] initWithRoomId:(int)room.roomID anchorId:room.ownerId useCdn:NO cdnUrl:@""];
    }
    audienceVC.modalPresentationStyle = UIModalPresentationFullScreen;
    audienceVC.delegate = self;
    [self presentViewController:audienceVC animated:YES completion:nil];
}

- (void)refreshRoomListData {
    [self getRoomList];
}

#pragma mark - TUILiveRoomAudienceDelegate
- (void)onRoomError:(TRTCLiveRoomInfo *)roomInfo errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage
{
    NSLog(@"----> 业务层收到观众端直播间的错误信息");
}

@end
