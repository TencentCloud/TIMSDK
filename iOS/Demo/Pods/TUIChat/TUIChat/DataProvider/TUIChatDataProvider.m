
@import ImSDK_Plus;
#import <objc/runtime.h>

#import "TUIChatDataProvider.h"
#import "TUIVideoMessageCellData.h"
#import "TUIMessageDataProvider.h"
#import "TUICore.h"
#import "NSDictionary+TUISafe.h"

@implementation TUIChatDataProvider

// 转发消息到目标会话
- (void)getForwardMessageWithCellDatas:(NSArray<TUIMessageCellData *> *)uiMsgs
                             toTargets:(NSArray<TUIChatConversationModel *> *)targets
                                 Merge:(BOOL)merge
                           ResultBlock:(void(^)(TUIChatConversationModel *targetConversation, NSArray<V2TIMMessage *> *msgs))resultBlock
                                  fail:(nullable V2TIMFail)fail
{
    if (uiMsgs.count == 0) {
        if (fail) {
            fail(ERR_SVR_PROFILE_INVALID_PARAMETERS, @"uiMsgs为空");
        }
        return ;
    }
    
    dispatch_apply(targets.count, dispatch_get_global_queue(0, 0), ^(size_t index) {
        
        TUIChatConversationModel *convCellData = targets[index];
        
        
        // 获取消息列表
        NSMutableArray *tmpMsgs = [NSMutableArray array];
        for (TUIMessageCellData *uiMsg in uiMsgs) {
            V2TIMMessage *msg = uiMsg.innerMessage;
            if (msg) {
                [tmpMsgs addObject:msg];
            }
        }
        NSArray *msgs = [NSArray arrayWithArray:tmpMsgs];
        
        // 排序-按照时间先后顺序以及seq顺序转发
        msgs = [msgs sortedArrayUsingComparator:^NSComparisonResult(V2TIMMessage *obj1, V2TIMMessage *obj2) {
            if ([obj1.timestamp timeIntervalSince1970] == [obj2.timestamp timeIntervalSince1970]) {
                return obj1.seq > obj2.seq;
            } else {
                return [obj1.timestamp compare:obj2.timestamp];
            }
        }];
        
        // 逐条转发消息
        if (!merge) {
            
            NSMutableArray *forwardMsgs = [NSMutableArray array];
            for (V2TIMMessage *msg in msgs) {
                V2TIMMessage *forwardMessage = [V2TIMManager.sharedInstance createForwardMessage:msg];
                if (forwardMessage) {
                    forwardMessage.isExcludedFromUnreadCount = [TUIConfig defaultConfig].isExcludedFromUnreadCount;
                    forwardMessage.isExcludedFromLastMessage = [TUIConfig defaultConfig].isExcludedFromLastMessage;
                    [forwardMsgs addObject:forwardMessage];
                }
            }
            if (resultBlock) {
                resultBlock(convCellData, forwardMsgs);
            }
            return;
        }
        
        // 合并转发
        @weakify(self);
        NSString *loginUserId = [V2TIMManager.sharedInstance getLoginUser];
        [V2TIMManager.sharedInstance getUsersInfo:@[loginUserId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            @strongify(self);
            
            // 创建转发消息
            NSString *myName = loginUserId;
            if (infoList.firstObject.nickName.length > 0) {
                myName = infoList.firstObject.nickName;
            }
            
            NSString *title = [self.forwardDelegate dataProvider:self mergeForwardTitleWithMyName:myName];
            NSMutableArray *abstactList = [NSMutableArray array];
            if (uiMsgs.count > 0) {
                [abstactList addObject:[self abstractDisplayWithMessage:msgs[0]]];
            }
            if (uiMsgs.count > 1) {
                [abstactList addObject:[self abstractDisplayWithMessage:msgs[1]]];
            }
            if (uiMsgs.count > 2) {
                [abstactList addObject:[self abstractDisplayWithMessage:msgs[2]]];
            }
            NSString *compatibleText = TUIKitLocalizableString(TUIKitRelayCompatibleText);
            V2TIMMessage *mergeMessage = [V2TIMManager.sharedInstance createMergerMessage:msgs title:title abstractList:abstactList compatibleText:compatibleText];
            if (mergeMessage == nil) {
                if (fail) {
                    fail(ERR_NO_SUCC_RESULT, @"合并转发消息失败");
                }
                return;
            }
            mergeMessage.isExcludedFromUnreadCount = [TUIConfig defaultConfig].isExcludedFromUnreadCount;
            mergeMessage.isExcludedFromLastMessage = [TUIConfig defaultConfig].isExcludedFromLastMessage;
            if (resultBlock) {
                resultBlock(convCellData, @[mergeMessage]);
            }
            
        } fail:fail];
    });
}

- (NSString *)abstractDisplayWithMessage:(V2TIMMessage *)msg
{
    // 合并转发的消息只支持 nickName
    NSString *desc = @"";
    if (msg.nickName.length > 0) {
        desc = msg.nickName;
    } else if(msg.sender.length > 0) {
        desc = msg.sender;
    }
    NSString *display = [self.forwardDelegate dataProvider:self mergeForwardMsgAbstactForMessage:msg];
    
    if (display.length == 0) {
        display = [TUIMessageDataProvider getDisplayString:msg];
    }
    if (desc.length > 0 && display.length > 0) {
        desc = [desc stringByAppendingFormat:@":%@", display];
    }
    return desc;
}

#pragma mark - CellData

+ (NSMutableArray<TUIInputMoreCellData *> *)moreMenuCellDataArray:(NSString *)groupID
                                                           userID:(NSString *)userID
                                                  isNeedVideoCall:(BOOL)isNeedVideoCall
                                                  isNeedAudioCall:(BOOL)isNeedAudioCall
                                                  isNeedGroupLive:(BOOL)isNeedGroupLive
                                                       isNeedLink:(BOOL)isNeedLink {
    NSMutableArray *moreMenus = [NSMutableArray array];
    [moreMenus addObject:[TUIInputMoreCellData photoData]];
    [moreMenus addObject:[TUIInputMoreCellData pictureData]];
    [moreMenus addObject:[TUIInputMoreCellData videoData]];
    [moreMenus addObject:[TUIInputMoreCellData fileData]];
    
    NSDictionary *param = @{TUICore_TUIChatExtension_GetMoreCellInfo_GroupID : groupID ? groupID : @"",TUICore_TUIChatExtension_GetMoreCellInfo_UserID : userID ? userID : @""};
    // 聊天页面, 视频通话按钮
    if (isNeedVideoCall) {
        NSDictionary *extentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall param:param];
        TUIInputMoreCellData *videoCallMenusData = [TUIInputMoreCellData new];
        videoCallMenusData.key = TUIInputMoreCellKey_VideoCall;
        videoCallMenusData.extentionView = [extentionInfo tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_View asClass:UIView.class];
        [moreMenus addObject:videoCallMenusData];
    }
    // 聊天页面, 语音通话按钮
    if (isNeedAudioCall) {
        NSDictionary *extentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall param:param];
        TUIInputMoreCellData *audioCallMenusData = [TUIInputMoreCellData new];
        audioCallMenusData.key = TUIInputMoreCellKey_AudioCall;
        audioCallMenusData.extentionView = [extentionInfo tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_View asClass:UIView.class];
        [moreMenus addObject:audioCallMenusData];
    }
    // 聊天页面, 群直播按钮
    if (isNeedGroupLive && groupID.length > 0) {
        TUIInputMoreCellData *liveMenusData = [TUIInputMoreCellData new];
        liveMenusData.key = TUIInputMoreCellKey_GroupLive;
        liveMenusData.title = TUIKitLocalizableString(TUIKitMoreGroupLive);
        liveMenusData.image = [UIImage d_imageNamed:@"more_group_live" bundle:TUIChatBundle];
        [moreMenus addObject:liveMenusData];
    }
    // 聊天页面, 自定义消息按钮
    if (isNeedLink) {
        TUIInputMoreCellData *linkMenusData = [TUIInputMoreCellData new];
        linkMenusData.key = TUIInputMoreCellKey_Link;
        linkMenusData.title = TUIKitLocalizableString(TUIKitMoreLink);
        linkMenusData.image = [UIImage d_imageNamed:@"more_link" bundle:TUIChatBundle];
        [moreMenus addObject:linkMenusData];
    }
    
    return moreMenus;
}

@end


#pragma mark - TUIChatDataProvider (IMSDK)
@implementation TUIChatDataProvider (IMSDK)

+ (void)getTotalUnreadMessageCountWithSuccBlock:(void(^)(UInt64 totalCount))succ
                                           fail:(nullable V2TIMFail)fail
{
    [V2TIMManager.sharedInstance getTotalUnreadMessageCount:succ fail:fail];
}

+ (void)saveDraftWithConversationID:(NSString *)conversationId Text:(NSString *)text {
    NSString *draft = text;
    draft = [draft stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
    [[V2TIMManager sharedInstance] setConversationDraft:conversationId draftText:draft succ:nil fail:nil];
}

#pragma mark - C2C
+ (void)getFriendInfoWithUserId:(nullable NSString *)userID
                      SuccBlock:(void(^)(V2TIMFriendInfoResult *friendInfoResult))succ
                      failBlock:(nullable V2TIMFail)fail
{
    NSParameterAssert(userID);
    if (fail && !userID) {
        fail(ERR_INVALID_PARAMETERS, @"userID is nil");
        return;
    }
    
    [[V2TIMManager sharedInstance] getFriendsInfo:@[userID] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        V2TIMFriendInfoResult *result = resultList.firstObject;
        succ(result);
    } fail:fail];
}

+ (void)getUserInfoWithUserId:(NSString *)userID
                    SuccBlock:(void(^)(V2TIMUserFullInfo *userInfo))succ
                    failBlock:(nullable V2TIMFail)fail
{
    NSParameterAssert(userID);
    if (fail && !userID) {
        fail(ERR_INVALID_PARAMETERS, @"userID is nil");
        return;
    }
    
    [[V2TIMManager sharedInstance] getUsersInfo:@[userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *info = infoList.firstObject;
        succ(info);
    } fail:fail];
}

#pragma mark - Group
+ (void)getGroupInfoWithGroupID:(NSString *)groupID
                     SuccBlock:(void(^)(V2TIMGroupInfoResult *groupResult))succ
                     failBlock:(nullable V2TIMFail)fail
{
    NSParameterAssert(groupID);
    if (fail && !groupID) {
        fail(ERR_INVALID_PARAMETERS, @"groupID is nil");
        return;
    }
    
    [[V2TIMManager sharedInstance] getGroupsInfo:@[groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        V2TIMGroupInfoResult *result = groupResultList.firstObject;
        if (result
            && result.resultCode == 0) {
            succ(result);
        } else {
            fail(result.resultCode, result.resultMsg);
        }
    } fail:fail];
}

@end
