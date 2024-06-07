//
//  TUISearchDataProvider.m
//  Pods
//
//  Created by harvy on 2020/12/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISearchDataProvider.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUISearchGroupDataProvider.h"
#import "TUISearchResultCellModel.h"
#import <TUICore/NSString+TUIUtil.h>

TUISearchParamKey TUISearchChatHistoryParamKeyConversationId = @"TUISearchChatHistoryParamKeyConversationId";
TUISearchParamKey TUISearchChatHistoryParamKeyCount = @"TUISearchChatHistoryParamKeyCount";
TUISearchParamKey TUISearchChatHistoryParamKeyPage = @"TUISearchChatHistoryParamKeyPage";
NSUInteger TUISearchDefaultPageSize = 20;

typedef void (^TUISearchResultCallback)(BOOL succ, NSString *__nullable errMsg, NSArray<TUISearchResultCellModel *> *__nullable results);

@interface TUISearchDataProvider ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray<TUISearchResultCellModel *> *> *resultSet;

@end

@implementation TUISearchDataProvider

- (void)searchForKeyword:(NSString *)keyword forModules:(TUISearchResultModule)modules param:(NSDictionary<TUISearchParamKey, id> *__nullable)param {
    __weak typeof(self) weakSelf = self;
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf searchForKeyword:keyword forModules:modules param:param];
        });
        return;
    }

    if (keyword.length == 0) {
        [self.resultSet removeAllObjects];
        if ([self.delegate respondsToSelector:@selector(onSearchResults:forModules:)]) {
            [self.delegate onSearchResults:self.resultSet forModules:modules];
        }
        return;
    }

    dispatch_group_t group = dispatch_group_create();
    BOOL request = NO;

    // Contact
    if ((modules == TUISearchResultModuleAll) || (modules & TUISearchResultModuleContact)) {
        request = YES;
        dispatch_group_enter(group);
        [self searchContacts:keyword
                    callback:^(BOOL succ, NSString *errMsg, NSArray *results) {
                      if (succ && results) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                            if (results.count) {
                                [weakSelf.resultSet setObject:results forKey:@(TUISearchResultModuleContact)];
                            } else {
                                [weakSelf.resultSet removeObjectForKey:@(TUISearchResultModuleContact)];
                            }
                            dispatch_group_leave(group);
                          });
                          return;
                      }
                      dispatch_group_leave(group);
                    }];
    }

    // Group
    if ((modules == TUISearchResultModuleAll) || (modules & TUISearchResultModuleGroup)) {
        request = YES;
        dispatch_group_enter(group);
        [self searchGroups:keyword
                  callback:^(BOOL succ, NSString *errMsg, NSArray *results) {
                    if (succ && results) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                          if (results.count) {
                              [weakSelf.resultSet setObject:results forKey:@(TUISearchResultModuleGroup)];
                          } else {
                              [weakSelf.resultSet removeObjectForKey:@(TUISearchResultModuleGroup)];
                          }
                          dispatch_group_leave(group);
                        });
                        return;
                    }
                    dispatch_group_leave(group);
                  }];
    }

    // Chat history
    if ((modules == TUISearchResultModuleAll) || (modules & TUISearchResultModuleChatHistory)) {
        request = YES;
        dispatch_group_enter(group);
        [self searchChatHistory:keyword
                          param:param
                       callback:^(BOOL succ, NSString *_Nullable errMsg, NSArray<TUISearchResultCellModel *> *_Nullable results) {
                         if (succ && results) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                               if (results.count) {
                                   [weakSelf.resultSet setObject:results forKey:@(TUISearchResultModuleChatHistory)];
                               } else {
                                   [weakSelf.resultSet removeObjectForKey:@(TUISearchResultModuleChatHistory)];
                               }
                             });
                         }
                         dispatch_group_leave(group);
                       }];
    }

    if (!request) {
        if ([self.delegate respondsToSelector:@selector(onSearchError:)]) {
            [self.delegate onSearchError:@"search module not exists"];
        }
        return;
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
      if ([self.delegate respondsToSelector:@selector(onSearchResults:forModules:)]) {
          [self.delegate onSearchResults:self.resultSet forModules:modules];
      }
    });
}

- (void)searchContacts:(NSString *)keyword callback:(TUISearchResultCallback)callback {
    if (keyword == nil || callback == nil) {
        if (callback) {
            callback(NO, @"invalid parameters, keyword is null", nil);
        }
        return;
    }

    V2TIMFriendSearchParam *param = [[V2TIMFriendSearchParam alloc] init];
    param.keywordList = @[ keyword ];
    param.isSearchUserID = YES;
    param.isSearchNickName = YES;
    param.isSearchRemark = YES;
    [V2TIMManager.sharedInstance searchFriends:param
        succ:^(NSArray<V2TIMFriendInfoResult *> *infoList) {
          NSMutableArray *arrayM = [NSMutableArray array];
          for (V2TIMFriendInfoResult *result in infoList) {
              TUISearchResultCellModel *cellModel = [[TUISearchResultCellModel alloc] init];
              NSString *title = result.friendInfo.friendRemark;
              if (title.length == 0) {
                  title = result.friendInfo.userFullInfo.nickName;
              }
              if (title.length == 0) {
                  title = result.friendInfo.userID;
              }

              NSString *why = @"";
              if ([result.friendInfo.friendRemark.lowercaseString containsString:keyword.lowercaseString]) {
                  why = result.friendInfo.friendRemark;
              } else if ([result.friendInfo.userFullInfo.nickName.lowercaseString containsString:keyword.lowercaseString]) {
                  why = result.friendInfo.userFullInfo.nickName;
              } else if ([result.friendInfo.userID.lowercaseString containsString:keyword.lowercaseString]) {
                  why = result.friendInfo.userID;
              }
              if (why.length) {
                  if ([why isEqualToString:title]) {
                      why = nil;
                  } else {
                      why = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitSearchResultMatchFormat), why];
                  }
              }

              cellModel.titleAttributeString = [TUISearchDataProvider attributeStringWithText:title key:keyword];
              cellModel.detailsAttributeString = [TUISearchDataProvider attributeStringWithText:why key:keyword];
              cellModel.groupID = nil;
              cellModel.avatarUrl = result.friendInfo.userFullInfo.faceURL;
              cellModel.avatarImage = DefaultAvatarImage;
              cellModel.context = result.friendInfo;
              [arrayM addObject:cellModel];
          }
          callback(YES, nil, arrayM);
        }
        fail:^(int code, NSString *desc) {
          callback(NO, desc, nil);
        }];
}

- (void)searchGroups:(NSString *)keyword callback:(TUISearchResultCallback)callback {
    if (keyword == nil || callback == nil) {
        if (callback) {
            callback(NO, @"invalid parameters, keyword is null", nil);
        }
        return;
    }

    TUISearchGroupParam *param = [[TUISearchGroupParam alloc] init];
    param.keywordList = @[ keyword ];
    param.isSearchGroupID = YES;
    param.isSearchGroupName = YES;
    param.isSearchGroupMember = YES;
    param.isSearchMemberRemark = YES;
    param.isSearchMemberUserID = YES;
    param.isSearchMemberNickName = YES;
    param.isSearchMemberNameCard = YES;
    [TUISearchGroupDataProvider searchGroups:param
        succ:^(NSArray<TUISearchGroupResult *> *_Nonnull resultSet) {
          NSMutableArray *arrayM = [NSMutableArray array];
          for (TUISearchGroupResult *result in resultSet) {
              TUISearchResultCellModel *cellModel = [[TUISearchResultCellModel alloc] init];
              NSString *title = result.groupInfo.groupName;
              if (title.length == 0) {
                  title = result.groupInfo.groupID;
              }
              cellModel.titleAttributeString = [TUISearchDataProvider attributeStringWithText:title key:keyword];
              cellModel.detailsAttributeString = nil;
              cellModel.groupID = result.groupInfo.groupID;
              cellModel.groupType = result.groupInfo.groupType;
              cellModel.avatarImage = DefaultGroupAvatarImageByGroupType(result.groupInfo.groupType);
              cellModel.avatarUrl = result.groupInfo.faceURL;
              cellModel.context = result.groupInfo;
              [arrayM addObject:cellModel];

              if (result.matchField == TUISearchGroupMatchFieldGroupID) {
                  NSString *text = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitSearchResultMatchGroupIDFormat), result.matchValue];
                  cellModel.detailsAttributeString = [TUISearchDataProvider attributeStringWithText:text key:keyword];
              } else if (result.matchField == TUISearchGroupMatchFieldMember && result.matchMembers.count) {
                  NSString *text = TIMCommonLocalizableString(TUIKitSearchResultMatchGroupMember);
                  for (int i = 0; i < result.matchMembers.count; i++) {
                      TUISearchGroupMemberMatchResult *memberResult = result.matchMembers[i];
                      text = [text stringByAppendingString:memberResult.memberMatchValue];
                      if (i < result.matchMembers.count - 1) {
                          text = [text stringByAppendingString:@"、"];
                      }
                  }
                  cellModel.detailsAttributeString = [TUISearchDataProvider attributeStringWithText:text key:keyword];
              }
          }
          callback(YES, nil, arrayM);
        }
        fail:^(NSInteger code, NSString *_Nonnull desc) {
          callback(NO, desc, nil);
        }];
}

- (void)searchChatHistory:(NSString *)keyword param:(NSDictionary<TUISearchParamKey, id> *__nullable)paramters callback:(TUISearchResultCallback)callback {
    if (keyword == nil || callback == nil) {
        if (callback) {
            callback(NO, @"invalid parameters, keyword is null", nil);
        }
        return;
    }

    NSUInteger pageSize = TUISearchDefaultPageSize;
    NSUInteger pageIndex = 0;
    NSString *conversationID = nil;
    NSArray *allKeys = paramters.allKeys;
    BOOL displayWithConveration = YES;

    if ([allKeys containsObject:TUISearchChatHistoryParamKeyCount]) {
        pageSize = [paramters[TUISearchChatHistoryParamKeyCount] integerValue];
    }
    if ([allKeys containsObject:TUISearchChatHistoryParamKeyPage]) {
        pageIndex = [paramters[TUISearchChatHistoryParamKeyPage] integerValue];
    }
    if ([allKeys containsObject:TUISearchChatHistoryParamKeyConversationId]) {
        conversationID = paramters[TUISearchChatHistoryParamKeyConversationId];
        displayWithConveration = NO;
    }

    V2TIMMessageSearchParam *param = [[V2TIMMessageSearchParam alloc] init];
    param.keywordList = @[ keyword ];
    param.messageTypeList = nil;
    param.conversationID = conversationID;
    param.searchTimePosition = 0;
    param.searchTimePeriod = 0;
    param.pageIndex = pageIndex;
    param.pageSize = pageSize;
    [V2TIMManager.sharedInstance searchLocalMessages:param
        succ:^(V2TIMMessageSearchResult *searchResult) {
          if (searchResult.totalCount == 0) {
              if (callback) {
                  callback(YES, nil, @[]);
              }
              return;
          }

          NSMutableArray *conversationIds = [NSMutableArray array];
          NSMutableDictionary *conversationInfoMap = [NSMutableDictionary dictionary];
          NSMutableDictionary *conversationMessageMap = [NSMutableDictionary dictionary];
          NSMutableDictionary *conversationCountMap = [NSMutableDictionary dictionary];
          NSArray<V2TIMMessageSearchResultItem *> *messageSearchResultItems = searchResult.messageSearchResultItems;
          for (V2TIMMessageSearchResultItem *searchItem in messageSearchResultItems) {
              NSString *conversationID = searchItem.conversationID;
              NSUInteger messageCount = searchItem.messageCount;
              NSArray<V2TIMMessage *> *messageList = searchItem.messageList ?: @[];
              if (conversationID.length == 0) {
                  continue;
              }
              [conversationIds addObject:conversationID];
              conversationMessageMap[conversationID] = messageList;
              conversationCountMap[conversationID] = @(messageCount);
          }

          if (conversationIds.count == 0) {
              if (callback) {
                  callback(YES, nil, @[]);
              }
              return;
          }

          [V2TIMManager.sharedInstance getConversationList:conversationIds
              succ:^(NSArray<V2TIMConversation *> *list) {
                for (V2TIMConversation *conversation in list) {
                    if (conversation.conversationID) {
                        conversationInfoMap[conversation.conversationID] = conversation;
                    }
                }
                NSMutableArray *arrayM = [NSMutableArray array];
                for (NSString *conversationId in conversationIds) {
                    if (![conversationInfoMap.allKeys containsObject:conversationId]) {
                        continue;
                    }

                    V2TIMConversation *conv = conversationInfoMap[conversationId];
                    NSArray *messageList = conversationMessageMap[conversationId];
                    NSUInteger count = [conversationCountMap[conversationId] integerValue];
                    if (displayWithConveration) {
                        TUISearchResultCellModel *cellModel = [[TUISearchResultCellModel alloc] init];
                        NSString *desc = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitSearchResultDisplayChatHistoryCountFormat), count];
                        if (messageList.count == 1) {
                            V2TIMMessage *firstMessage = messageList.firstObject;
                            desc = [TUISearchDataProvider matchedTextForMessage:(V2TIMMessage *)firstMessage withKey:keyword];
                        }
                        cellModel.title = conv.showName;
                        cellModel.detailsAttributeString = [TUISearchDataProvider attributeStringWithText:desc key:messageList.count == 1 ? keyword : nil];
                        cellModel.groupID = conv.groupID;
                        cellModel.avatarImage = conv.type == V2TIM_GROUP ? DefaultGroupAvatarImageByGroupType(conv.groupType) : DefaultAvatarImage;
                        cellModel.groupType = conv.groupType;
                        cellModel.avatarUrl = conv.faceUrl;
                        cellModel.context = @{
                            kSearchChatHistoryConversationId : conversationId,
                            kSearchChatHistoryConverationInfo : conv,
                            kSearchChatHistoryConversationMsgs : messageList
                        };
                        [arrayM addObject:cellModel];
                    } else {
                        for (V2TIMMessage *message in messageList) {
                            TUISearchResultCellModel *cellModel = [[TUISearchResultCellModel alloc] init];
                            cellModel.title = message.nickName ?: message.sender;
                            NSString *desc = [TUISearchDataProvider matchedTextForMessage:message withKey:keyword];
                            cellModel.detailsAttributeString = [TUISearchDataProvider attributeStringWithText:desc key:keyword];
                            cellModel.groupID = conv.groupID;
                            cellModel.groupType = conv.groupType;
                            cellModel.avatarUrl = message.faceURL;
                            cellModel.avatarImage = conv.type == V2TIM_GROUP ? DefaultGroupAvatarImageByGroupType(conv.groupType) : DefaultAvatarImage;
                            cellModel.context = message;
                            [arrayM addObject:cellModel];
                        }
                    }
                }
                TUISearchResultCellModel *lastCellModel = [arrayM lastObject];
                lastCellModel.hideSeparatorLine = YES;

                if (callback) {
                    callback(YES, nil, arrayM);
                }
              }
              fail:^(int code, NSString *desc) {
                if (callback) {
                    callback(NO, desc, nil);
                }
              }];
        }
        fail:^(int code, NSString *desc) {
          if (callback) {
              callback(NO, desc, nil);
          }
          if (code == ERR_SDK_INTERFACE_NOT_SUPPORT) {
              [TUITool postUnsupportNotificationOfService:TIMCommonLocalizableString(TUIKitErrorUnsupportIntefaceSearch)];
          }
        }];
}

+ (NSAttributedString *)attributeStringWithText:(NSString *)text key:(NSString *)key {
    if (text.length == 0) {
        return nil;
    }

    if (key == nil || key.length == 0 || ![text.lowercaseString tui_containsString:key.lowercaseString]) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:text
                                                                              attributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
        return attributeString;
    }

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text
                                                                             attributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];

    NSUInteger loc = 0;
    NSUInteger len = text.length;
    while (len > 0) {
        NSRange range = [text.lowercaseString rangeOfString:key.lowercaseString options:NSCaseInsensitiveSearch range:NSMakeRange(loc, len)];
        if (range.length) {
            [attr addAttribute:NSForegroundColorAttributeName value:TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF") range:range];
            loc = range.location + 1;
            len = text.length - loc;
        } else {
            len = 0;
            loc = 0;
        }
    }
    return [[NSAttributedString alloc] initWithAttributedString:attr];
}

+ (NSString *)matchedTextForMessage:(V2TIMMessage *)msg withKey:(NSString *)key {
    if (key.length == 0) {
        return @"";
    }

    if ((msg.elemType == V2TIM_ELEM_TYPE_TEXT) && [msg.textElem.text tui_containsString:key]) {
        return msg.textElem.text;
    } else if ((msg.elemType == V2TIM_ELEM_TYPE_IMAGE) && [msg.imageElem.path tui_containsString:key]) {
        return msg.imageElem.path;
    } else if ((msg.elemType == V2TIM_ELEM_TYPE_SOUND) && [msg.soundElem.path tui_containsString:key]) {
        return msg.soundElem.path;
    } else if (msg.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        if ([msg.videoElem.videoPath tui_containsString:key]) {
            return msg.videoElem.videoPath;
        } else if ([msg.videoElem.snapshotPath tui_containsString:key]) {
            return msg.videoElem.snapshotPath;
        } else {
            return @"";
        }
    } else if ((msg.elemType == V2TIM_ELEM_TYPE_FILE) && [msg.fileElem.path tui_containsString:key]) {
        return msg.fileElem.path;
    } else if (msg.elemType == V2TIM_ELEM_TYPE_MERGER) {
        NSArray *abM = msg.mergerElem.abstractList;
        NSString *abs = @"";
        for (NSString *ab in abM) {
            abs = [abs stringByAppendingString:ab];
            abs = [abs stringByAppendingString:@","];
        }
        if ([msg.mergerElem.title tui_containsString:key]) {
            return msg.mergerElem.title;
        } else if ([abs tui_containsString:key]) {
            return abs;
        } else {
            return @"";
        }
    }

    return @"";
}

#pragma mark - Lazy
- (NSMutableDictionary *)resultSet {
    if (_resultSet == nil) {
        _resultSet = [NSMutableDictionary dictionary];
    }
    return _resultSet;
}

@end
