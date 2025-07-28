//
//  TContactSelectViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactSelectViewDataProvider.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSString+TUIUtil.h>
#import <TIMCommon/TUIRelationUserModel.h>

@interface TUIContactSelectViewDataProvider ()
@property NSDictionary<NSString *, NSArray<TUICommonContactSelectCellData *> *> *dataDict;
@property NSArray *groupList;
@property BOOL isLoadFinished;
@end

@implementation TUIContactSelectViewDataProvider

- (void)loadContacts {
    self.isLoadFinished = NO;

    @weakify(self);
    [[V2TIMManager sharedInstance]
        getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
          @strongify(self);
          NSMutableArray *arr = [NSMutableArray new];
          for (V2TIMFriendInfo *fr in infoList) {
              if ([self filteConversation:fr]) {
                  continue;
              }
              [arr addObject:fr.userFullInfo];
          }
        
         // Insert V2TIMFriendInfo Model
         NSMutableDictionary<NSString *, TUIRelationUserModel *> *result = [NSMutableDictionary dictionary];
         for (V2TIMFriendInfo *item in infoList) {
            if (item && item.userID.length > 0) {
                TUIRelationUserModel *userInfo = [[TUIRelationUserModel alloc] init];
                userInfo.userID = item.userID;
                userInfo.nickName = item.userFullInfo.nickName;
                userInfo.friendRemark = item.friendRemark;
                userInfo.faceURL = item.userFullInfo.faceURL;
                [result setObject:userInfo forKey:userInfo.userID];
            }
         }
        
         [self fillList:arr friendsInfo:result displayNames:nil];
        
        }
     fail:nil];
}

- (BOOL)filteConversation:(V2TIMFriendInfo *)fr {
    if ([fr.userID  containsString:@"@RBT#"]) {
        return YES;
    }
    return NO;
}

- (void)setSourceIds:(NSArray<NSString *> *)ids {
    [self setSourceIds:ids displayNames:nil];
}

- (void)setSourceIds:(NSArray<NSString *> *)ids displayNames:(NSDictionary *__nullable)displayNames {
    [[V2TIMManager sharedInstance] getUsersInfo:ids
                                           succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSMutableDictionary<NSString *, TUIRelationUserModel *> *result = [NSMutableDictionary dictionary];
        [V2TIMManager.sharedInstance getFriendsInfo:ids
                                               succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
            for (V2TIMFriendInfoResult *item in resultList) {
                if (item.friendInfo && item.friendInfo.userID.length > 0) {
                    TUIRelationUserModel *userInfo = [[TUIRelationUserModel alloc] init];
                    userInfo.userID = item.friendInfo.userID;
                    userInfo.nickName = item.friendInfo.userFullInfo.nickName;
                    userInfo.friendRemark = item.friendInfo.friendRemark;
                    userInfo.faceURL = item.friendInfo.userFullInfo.faceURL;
                    [result setObject:userInfo forKey:userInfo.userID];
                }
            }
            [self fillList:infoList friendsInfo:result displayNames:displayNames];
        }
                                               fail:^(int code, NSString *desc) {
        }];
   
    }
        fail:nil];
}

- (void)fillList:(NSArray<V2TIMUserFullInfo *> *)profiles
     friendsInfo:(NSMutableDictionary<NSString *, TUIRelationUserModel *>*)result
        displayNames:(NSDictionary *__nullable)displayNames {
    NSMutableDictionary *dataDict = @{}.mutableCopy;
    NSMutableArray *groupList = @[].mutableCopy;
    NSMutableArray *nonameList = @[].mutableCopy;

    for (V2TIMUserFullInfo *profile in profiles) {
        TUICommonContactSelectCellData *data = [[TUICommonContactSelectCellData alloc] init];
        NSString *showName = @"";
        if (displayNames && [displayNames.allKeys containsObject:profile.userID]) {
            showName = [displayNames objectForKey:profile.userID];
        }
        if (showName.length == 0) {
            showName = profile.showName;
        }
        
        if (result.count > 0 && result[profile.userID]) {
            TUIRelationUserModel *userInfo = result[profile.userID];
            showName = userInfo.getDisplayName;
        }
        
        data.title = showName;
        if (profile.faceURL.length) {
            data.avatarUrl = [NSURL URLWithString:profile.faceURL];
        }
        data.identifier = profile.userID;

        if (self.avaliableFilter && !self.avaliableFilter(data)) {
            continue;
        }
        if (self.disableFilter) {
            data.enabled = !self.disableFilter(data);
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
    for (NSMutableArray *list in [self.dataDict allValues]) {
        [list sortUsingSelector:@selector(compare:)];
    }

    self.groupList = groupList;
    self.dataDict = dataDict;
    self.isLoadFinished = YES;
}

@end
