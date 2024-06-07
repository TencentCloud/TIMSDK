//
//  TUISearchGroupDataProvider.m
//  Pods
//
//  Created by harvy on 2021/3/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISearchGroupDataProvider.h"
#import "NSString+TUIUtil.h"

static BOOL match(NSArray *keywords, NSString *text) {
    BOOL isMatch = NO;
    for (NSString *keyword in keywords) {
        if ([text.lowercaseString tui_containsString:keyword]) {
            isMatch |= YES;
            break;
        }
    }
    return isMatch;
}

@interface TUISearchGroupResult ()

@property(nonatomic, copy) NSString *groupId;
@property(nonatomic, strong) NSArray<V2TIMGroupMemberFullInfo *> *memberInfos;

@property(nonatomic, strong) V2TIMGroupInfo *groupInfo;
@property(nonatomic, assign) TUISearchGroupMatchField matchField;
@property(nonatomic, copy) NSString *matchValue;
@property(nonatomic, strong) NSArray<TUISearchGroupMemberMatchResult *> *matchMembers;

@end
@implementation TUISearchGroupResult
@end

@interface TUISearchGroupMemberMatchResult ()
@property(nonatomic, strong) V2TIMGroupMemberFullInfo *memberInfo;
@property(nonatomic, assign) TUISearchGroupMemberMatchField memberMatchField;
@property(nonatomic, copy) NSString *memberMatchValue;
@end
@implementation TUISearchGroupMemberMatchResult
@end

@implementation TUISearchGroupParam
@end

@implementation TUISearchGroupDataProvider

+ (void)searchGroups:(TUISearchGroupParam *)searchParam succ:(TUISearchGroupResultListSucc __nullable)succ fail:(TUISearchGroupResultListFail __nullable)fail {
    if (searchParam == nil) {
        if (fail) {
            fail(-1, @"Invalid paramters, searchParam is null");
        }
        return;
    }

    if (searchParam.keywordList == nil || searchParam.keywordList.count == 0 || searchParam.keywordList.count > 5) {
        if (fail) {
            fail(-1, @"Invalid paramters, keyword count is zero or beyond the limit of five");
        }
        return;
    }

    NSMutableArray *keywords = [NSMutableArray array];
    for (NSString *keyword in searchParam.keywordList) {
        [keywords addObject:keyword.lowercaseString];
    }

    __block NSArray *groupsOne = nil;
    __block NSArray *groupsTwo = nil;

    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    [self doSearchGroups:searchParam
        keywords:keywords
        succ:^(NSArray<TUISearchGroupResult *> *_Nonnull resultSet) {
          groupsOne = resultSet;
          dispatch_group_leave(group);
        }
        fail:^(NSInteger code, NSString *_Nonnull desc) {
          dispatch_group_leave(group);
        }];

    BOOL isSearchMember = searchParam.isSearchGroupMember;
    if (isSearchMember) {
        dispatch_group_enter(group);
        [self doSearchMembers:searchParam
            keywords:keywords
            succ:^(NSArray<TUISearchGroupResult *> *_Nonnull resultSet) {
              groupsTwo = resultSet;
              dispatch_group_leave(group);
            }
            fail:^(NSInteger code, NSString *_Nonnull desc) {
              dispatch_group_leave(group);
            }];
    }

    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
      NSArray *resultSet = [weakSelf mergeGroupSets:groupsOne withOthers:groupsTwo];
      dispatch_async(dispatch_get_main_queue(), ^{
        if (succ) {
            succ(resultSet);
        }
      });
    });
}

+ (void)doSearchGroups:(TUISearchGroupParam *)searchParam
              keywords:(NSArray<NSString *> *)keywords
                  succ:(TUISearchGroupResultListSucc)succ
                  fail:(TUISearchGroupResultListFail)fail {
    V2TIMGroupSearchParam *groupParam = [[V2TIMGroupSearchParam alloc] init];
    groupParam.keywordList = keywords;
    groupParam.isSearchGroupID = searchParam.isSearchGroupID;
    groupParam.isSearchGroupName = searchParam.isSearchGroupName;

    [V2TIMManager.sharedInstance searchGroups:groupParam
        succ:^(NSArray<V2TIMGroupInfo *> *groupList) {
          NSMutableArray *arrayM = [NSMutableArray array];
          for (V2TIMGroupInfo *groupInfo in groupList) {
              TUISearchGroupResult *result = [[TUISearchGroupResult alloc] init];
              result.groupId = groupInfo.groupID;
              result.groupInfo = groupInfo;
              result.matchMembers = nil;
              if (match(keywords, groupInfo.groupName)) {
                  result.matchField = TUISearchGroupMatchFieldGroupName;
                  result.matchValue = groupInfo.groupName;
                  [arrayM addObject:result];
                  continue;
              }
              if (match(keywords, groupInfo.groupID)) {
                  result.matchField = TUISearchGroupMatchFieldGroupID;
                  result.matchValue = groupInfo.groupID;
                  [arrayM addObject:result];
                  continue;
              }
          }
          if (succ) {
              succ(arrayM);
          }
        }
        fail:^(int code, NSString *desc) {
          if (fail) {
              fail(code, desc);
          }
        }];
}

+ (void)doSearchMembers:(TUISearchGroupParam *)searchParam
               keywords:(NSArray<NSString *> *)keywords
                   succ:(TUISearchGroupResultListSucc)succ
                   fail:(TUISearchGroupResultListFail)fail {
    V2TIMGroupMemberSearchParam *memberParam = [[V2TIMGroupMemberSearchParam alloc] init];
    memberParam.keywordList = keywords;
    memberParam.groupIDList = nil;
    memberParam.isSearchMemberUserID = searchParam.isSearchMemberUserID;
    memberParam.isSearchMemberNickName = searchParam.isSearchMemberNickName;
    memberParam.isSearchMemberNameCard = searchParam.isSearchMemberNameCard;
    memberParam.isSearchMemberRemark = searchParam.isSearchMemberRemark;

    [V2TIMManager.sharedInstance searchGroupMembers:memberParam
        succ:^(NSDictionary<NSString *, NSArray<V2TIMGroupMemberFullInfo *> *> *memberList) {
          NSMutableArray<TUISearchGroupResult *> *resultSet = [NSMutableArray array];
          NSMutableArray *groupIds = [NSMutableArray array];
          [memberList enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull groupId, NSArray<V2TIMGroupMemberFullInfo *> *_Nonnull obj, BOOL *_Nonnull stop) {
            [groupIds addObject:groupId];
            TUISearchGroupResult *result = [[TUISearchGroupResult alloc] init];
            result.groupId = groupId;
            result.matchField = TUISearchGroupMatchFieldMember;
            result.matchValue = nil;
            result.memberInfos = obj;
            [resultSet addObject:result];
          }];

          NSMutableDictionary *groupInfoMap = [NSMutableDictionary dictionary];
          dispatch_group_t group = dispatch_group_create();
          {
              dispatch_group_enter(group);
              [V2TIMManager.sharedInstance getGroupsInfo:groupIds
                  succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
                    for (V2TIMGroupInfoResult *groupInfoResult in groupResultList) {
                        if (groupInfoResult.resultCode == 0) {
                            groupInfoMap[groupInfoResult.info.groupID] = groupInfoResult.info;
                        }
                    }
                    dispatch_group_leave(group);
                  }
                  fail:^(int code, NSString *desc) {
                    dispatch_group_leave(group);
                  }];
          }

          {
              dispatch_group_enter(group);
              for (TUISearchGroupResult *result in resultSet) {
                  NSArray *members = result.memberInfos;
                  NSMutableArray *arrayM = [NSMutableArray array];
                  for (V2TIMGroupMemberFullInfo *memberInfo in members) {
                      TUISearchGroupMemberMatchResult *memberMatchResult = [[TUISearchGroupMemberMatchResult alloc] init];
                      if (match(keywords, memberInfo.nameCard)) {
                        memberMatchResult.memberMatchField = TUISearchGroupMemberMatchFieldNameCard;
                        memberMatchResult.memberMatchValue = memberInfo.nameCard;
                        [arrayM addObject:memberMatchResult];
                        continue;
                      }
                      
                      if (match(keywords, memberInfo.friendRemark)) {
                        memberMatchResult.memberMatchField = TUISearchGroupMemberMatchFieldRemark;
                        memberMatchResult.memberMatchValue = memberInfo.friendRemark;
                        [arrayM addObject:memberMatchResult];
                        continue;
                      }
                      
                      if (match(keywords, memberInfo.nickName)) {
                        memberMatchResult.memberMatchField = TUISearchGroupMemberMatchFieldNickName;
                        memberMatchResult.memberMatchValue = memberInfo.nickName;
                        [arrayM addObject:memberMatchResult];
                        continue;
                      }
                      
                      if (match(keywords, memberInfo.userID)) {
                        memberMatchResult.memberMatchField = TUISearchGroupMemberMatchFieldUserID;
                        memberMatchResult.memberMatchValue = memberInfo.userID;
                        [arrayM addObject:memberMatchResult];
                        continue;
                      }
                  }
                  result.matchMembers = arrayM;
              }
              dispatch_group_leave(group);
          }

          dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
            NSMutableArray *arrayM = [NSMutableArray array];
            NSArray *validGroupIds = groupInfoMap.allKeys;
            for (TUISearchGroupResult *result in resultSet) {
                if ([validGroupIds containsObject:result.groupId]) {
                    result.groupInfo = groupInfoMap[result.groupId];
                    [arrayM addObject:result];
                }
            }
            if (succ) {
                succ(arrayM);
            }
          });
        }
        fail:^(int code, NSString *desc) {
          if (fail) {
              fail(code, desc);
          }
        }];
}

+ (NSArray *)mergeGroupSets:(NSArray *)groupsOne withOthers:(NSArray *)groupsTwo {
    NSMutableArray *arrayM = [NSMutableArray array];

    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    for (TUISearchGroupResult *result in groupsOne) {
        [arrayM addObject:result];
        map[result.groupId] = @(1);
    }

    for (TUISearchGroupResult *result in groupsTwo) {
        if ([map objectForKey:result.groupId]) {
            continue;
        }
        [arrayM addObject:result];
    }

    [arrayM sortUsingComparator:^NSComparisonResult(TUISearchGroupResult *obj1, TUISearchGroupResult *obj2) {
      return obj1.groupInfo.lastMessageTime > obj2.groupInfo.lastMessageTime ? NSOrderedDescending : NSOrderedAscending;
    }];

    return arrayM;
}

@end
