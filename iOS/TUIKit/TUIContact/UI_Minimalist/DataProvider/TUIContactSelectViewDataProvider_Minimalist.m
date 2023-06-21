//
//  TContactSelectViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactSelectViewDataProvider_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSString+TUIUtil.h>
#import "TUICommonContactSelectCell_Minimalist.h"

@interface TUIContactSelectViewDataProvider_Minimalist ()
@property NSDictionary<NSString *, NSArray<TUICommonContactSelectCellData_Minimalist *> *> *dataDict;
@property NSArray *groupList;
@property BOOL isLoadFinished;
@end

@implementation TUIContactSelectViewDataProvider_Minimalist

- (void)loadContacts {
    self.isLoadFinished = NO;

    @weakify(self);
    [[V2TIMManager sharedInstance]
        getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
          @strongify(self);
          NSMutableArray *arr = [NSMutableArray new];
          for (V2TIMFriendInfo *fr in infoList) {
              [arr addObject:fr.userFullInfo];
          }
          [self fillList:arr displayNames:nil];
        }
                 fail:nil];
}

- (void)setSourceIds:(NSArray<NSString *> *)ids {
    [self setSourceIds:ids displayNames:nil];
}

- (void)setSourceIds:(NSArray<NSString *> *)ids displayNames:(NSDictionary *__nullable)displayNames {
    [[V2TIMManager sharedInstance] getUsersInfo:ids
                                           succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                                             [self fillList:infoList displayNames:displayNames];
                                           }
                                           fail:nil];
}

- (void)fillList:(NSArray<V2TIMUserFullInfo *> *)profiles displayNames:(NSDictionary *__nullable)displayNames {
    NSMutableDictionary *dataDict = @{}.mutableCopy;
    NSMutableArray *groupList = @[].mutableCopy;
    NSMutableArray *nonameList = @[].mutableCopy;

    for (V2TIMUserFullInfo *profile in profiles) {
        TUICommonContactSelectCellData_Minimalist *data = [[TUICommonContactSelectCellData_Minimalist alloc] init];
        NSString *showName = @"";
        if (displayNames && [displayNames.allKeys containsObject:profile.userID]) {
            showName = [displayNames objectForKey:profile.userID];
        }
        if (showName.length == 0) {
            showName = profile.showName;
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
