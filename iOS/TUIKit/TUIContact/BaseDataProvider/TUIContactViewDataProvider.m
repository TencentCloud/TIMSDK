//
//  TContactViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactViewDataProvider.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSString+TUIUtil.h>

#define kGetUserStatusPageCount 500

@interface TUIContactViewDataProvider () <V2TIMFriendshipListener, V2TIMSDKListener>
@property NSDictionary<NSString *, NSArray<TUICommonContactCellData *> *> *dataDict;
@property NSArray *groupList;
@property BOOL isLoadFinished;
@property NSUInteger pendencyCnt;

@property(nonatomic, strong) NSDictionary *contactMap;

@end

@implementation TUIContactViewDataProvider

- (instancetype)init {
    if (self = [super init]) {
        [[V2TIMManager sharedInstance] addFriendListener:self];
        [[V2TIMManager sharedInstance] addIMSDKListener:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadContacts {
    self.isLoadFinished = NO;
    @weakify(self);
    [[V2TIMManager sharedInstance]
        getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
          @strongify(self);
          NSMutableDictionary *dataDict = @{}.mutableCopy;
          NSMutableArray *groupList = @[].mutableCopy;
          NSMutableArray *nonameList = @[].mutableCopy;

          NSMutableDictionary *contactMap = [NSMutableDictionary dictionary];
          NSMutableArray *userIDList = [NSMutableArray array];

          for (V2TIMFriendInfo *friend in infoList) {
              TUICommonContactCellData *data = [[TUICommonContactCellData alloc] initWithFriend:friend];
              // for online status
              data.onlineStatus = TUIContactOnlineStatusUnknown;
              if (data.identifier) {
                  [contactMap setObject:data forKey:data.identifier];
                  [userIDList addObject:data.identifier];
              }

              NSString *group = [[data.title firstPinYin] uppercaseString];
              if (group.length == 0 || !isalpha([group characterAtIndex:0])) {
                  [nonameList addObject:data];
                  continue;
              }
              NSMutableArray *list = [dataDict objectForKey:group];
              if (!list) {
                  list = @[].mutableCopy;
                  dataDict[group] = list;
                  [groupList addObject:group];
              }
              [list addObject:data];
          }

          [groupList sortUsingSelector:@selector(localizedStandardCompare:)];
          if (nonameList.count) {
              [groupList addObject:@"#"];
              dataDict[@"#"] = nonameList;
          }
          for (NSMutableArray *list in [dataDict allValues]) {
              [list sortUsingSelector:@selector(compare:)];
          }
          self.groupList = groupList;
          self.dataDict = dataDict;
          self.contactMap = [NSDictionary dictionaryWithDictionary:contactMap];
          self.isLoadFinished = YES;

          // refresh online status async
          [self asyncGetOnlineStatus:userIDList];
        }
        fail:^(int code, NSString *desc) {
          NSLog(@"getFriendList failed, code:%d desc:%@", code, desc);
        }];

    [self loadFriendApplication];
}

- (void)loadFriendApplication {
    @weakify(self);
    [[V2TIMManager sharedInstance]
        getFriendApplicationList:^(V2TIMFriendApplicationResult *result) {
          @strongify(self);
          self.pendencyCnt = result.unreadCount;
        }
                            fail:nil];
}

- (void)asyncGetOnlineStatus:(NSArray *)userIDList {
    if (NSThread.isMainThread) {
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
          @strongify(self);
          [self asyncGetOnlineStatus:userIDList];
        });
        return;
    }

    if (userIDList.count == 0) {
        return;
    }

    @weakify(self);
    void (^getUserStatus)(NSArray *userIDList) = ^(NSArray *userIDList) {
      @strongify(self);
      @weakify(self);
      [V2TIMManager.sharedInstance getUserStatus:userIDList
          succ:^(NSArray<V2TIMUserStatus *> *result) {
            @strongify(self);
            [self handleOnlineStatus:result];
          }
          fail:^(int code, NSString *desc) {
#if DEBUG
            if (code == ERR_SDK_INTERFACE_NOT_SUPPORT && TUIConfig.defaultConfig.displayOnlineStatusIcon) {
                [TUITool makeToast:desc];
            }
#endif
          }];
    };

    NSInteger count = kGetUserStatusPageCount;
    if (userIDList.count > count) {
        NSArray *subUserIDList = [userIDList subarrayWithRange:NSMakeRange(0, count)];
        NSArray *pendingUserIDList = [userIDList subarrayWithRange:NSMakeRange(count, userIDList.count - count)];
        getUserStatus(subUserIDList);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          @strongify(self);
          [self asyncGetOnlineStatus:pendingUserIDList];
        });
    } else {
        getUserStatus(userIDList);
    }
}

- (void)asyncUpdateOnlineStatus {
    if (NSThread.isMainThread) {
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
          @strongify(self);
          [self asyncUpdateOnlineStatus];
        });
        return;
    }

    // reset
    NSMutableArray *userIDList = [NSMutableArray array];
    for (TUICommonContactCellData *contact in self.contactMap.allValues) {
        contact.onlineStatus = TUIContactOnlineStatusOffline;
        if (contact.identifier) {
            [userIDList addObject:contact.identifier];
        }
    }

    // refresh table view on the main thread
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
      @strongify(self);
      self.isLoadFinished = YES;

      // fetch
      [self asyncGetOnlineStatus:userIDList];
    });
}

- (void)handleOnlineStatus:(NSArray<V2TIMUserStatus *> *)userStatusList {
    NSInteger changed = 0;
    for (V2TIMUserStatus *userStatus in userStatusList) {
        if ([self.contactMap.allKeys containsObject:userStatus.userID]) {
            changed++;
            TUICommonContactCellData *contact = [self.contactMap objectForKey:userStatus.userID];
            contact.onlineStatus = (userStatus.statusType == V2TIM_USER_STATUS_ONLINE) ? TUIContactOnlineStatusOnline : TUIContactOnlineStatusOffline;
        }
    }
    if (changed == 0) {
        return;
    }

    // refresh table view on the main thread
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
      @strongify(self);
      self.isLoadFinished = YES;
    });
}

- (void)clearApplicationCnt {
    @weakify(self);
    [[V2TIMManager sharedInstance]
        setFriendApplicationRead:^{
          @strongify(self);
          (self).pendencyCnt = 0;
        }
                            fail:nil];
}

#pragma mark - V2TIMSDKListener
- (void)onUserStatusChanged:(NSArray<V2TIMUserStatus *> *)userStatusList {
    [self handleOnlineStatus:userStatusList];
}

- (void)onConnectFailed:(int)code err:(NSString *)err {
    NSLog(@"%s", __func__);
}

- (void)onConnectSuccess {
    NSLog(@"%s", __func__);
    [self asyncUpdateOnlineStatus];
}

#pragma mark - V2TIMFriendshipListener
- (void)onFriendApplicationListAdded:(NSArray<V2TIMFriendApplication *> *)applicationList {
    [self loadFriendApplication];
}

- (void)onFriendApplicationListDeleted:(NSArray *)userIDList {
    [self loadFriendApplication];
}

- (void)onFriendApplicationListRead {
    [self loadFriendApplication];
}

- (void)onFriendListAdded:(NSArray<V2TIMFriendInfo *> *)infoList {
    [self loadContacts];
}

- (void)onFriendListDeleted:(NSArray *)userIDList {
    [self loadContacts];
}

- (void)onFriendProfileChanged:(NSArray<V2TIMFriendInfo *> *)infoList {
    [self loadContacts];
}

@end
