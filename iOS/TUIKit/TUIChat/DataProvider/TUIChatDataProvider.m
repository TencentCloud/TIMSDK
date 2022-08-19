
@import ImSDK_Plus;
#import <objc/runtime.h>

#import "TUIChatDataProvider.h"
#import "TUIVideoMessageCellData.h"
#import "TUIMessageDataProvider.h"
#import "TUICore.h"
#import "NSDictionary+TUISafe.h"
#import "TUIThemeManager.h"

#define Input_SendBtn_Key @"Input_SendBtn_Key"
#define Input_SendBtn_Title @"Input_SendBtn_Title"
#define Input_SendBtn_ImageName @"Input_SendBtn_ImageName"

static NSArray *customInputBtnInfo = nil;

@implementation TUIChatDataProvider
+ (void)initialize
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeLanguage) name:TUIChangeLanguageNotification object:nil];   
}

+ (void)onChangeLanguage
{
    customInputBtnInfo = nil;
}

+ (NSArray *)customInputBtnInfo
{
    if (customInputBtnInfo == nil) {
        customInputBtnInfo = @[@{Input_SendBtn_Key : TUIInputMoreCellKey_Link,
                                 Input_SendBtn_Title :  TUIKitLocalizableString(TUIKitMoreLink),
                                 Input_SendBtn_ImageName : @"chat_more_link_img"
                                }
        ];
    }
    return customInputBtnInfo;
}

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
        
        NSMutableArray *tmpMsgs = [NSMutableArray array];
        for (TUIMessageCellData *uiMsg in uiMsgs) {
            V2TIMMessage *msg = uiMsg.innerMessage;
            if (msg) {
                [tmpMsgs addObject:msg];
            }
        }
        NSArray *msgs = [NSArray arrayWithArray:tmpMsgs];
        msgs = [msgs sortedArrayUsingComparator:^NSComparisonResult(V2TIMMessage *obj1, V2TIMMessage *obj2) {
            if ([obj1.timestamp timeIntervalSince1970] == [obj2.timestamp timeIntervalSince1970]) {
                return obj1.seq > obj2.seq;
            } else {
                return [obj1.timestamp compare:obj2.timestamp];
            }
        }];
        
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
        
        @weakify(self);
        NSString *loginUserId = [V2TIMManager.sharedInstance getLoginUser];
        [V2TIMManager.sharedInstance getUsersInfo:@[loginUserId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            @strongify(self);
            
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
                    fail(ERR_NO_SUCC_RESULT, @"failed to merge-forward");
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
    if (isNeedVideoCall) {
        NSDictionary *extentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall param:param];
        if (extentionInfo) {
            TUIInputMoreCellData *videoCallMenusData = [TUIInputMoreCellData new];
            videoCallMenusData.key = TUIInputMoreCellKey_VideoCall;
            videoCallMenusData.extentionView = [extentionInfo tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_View asClass:UIView.class];
            [moreMenus addObject:videoCallMenusData];
        }
    }

    if (isNeedAudioCall) {
        NSDictionary *extentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall param:param];
        if (extentionInfo) {
            TUIInputMoreCellData *audioCallMenusData = [TUIInputMoreCellData new];
            audioCallMenusData.key = TUIInputMoreCellKey_AudioCall;
            audioCallMenusData.extentionView = [extentionInfo tui_objectForKey:TUICore_TUIChatExtension_GetMoreCellInfo_View asClass:UIView.class];
            [moreMenus addObject:audioCallMenusData];
        }
    }

    if (isNeedGroupLive && groupID.length > 0) {
        TUIInputMoreCellData *liveMenusData = [TUIInputMoreCellData new];
        liveMenusData.key = TUIInputMoreCellKey_GroupLive;
        liveMenusData.title = TUIKitLocalizableString(TUIKitMoreGroupLive);
        liveMenusData.image = TUIChatBundleThemeImage(@"chat_more_group_live", @"more_group_live");
        [moreMenus addObject:liveMenusData];

    }

    for (NSDictionary *buttonInfo in [self customInputBtnInfo]) {
        NSString *key = buttonInfo[Input_SendBtn_Key];
        NSString *title = buttonInfo[Input_SendBtn_Title];
        NSString *imageName = buttonInfo[Input_SendBtn_ImageName];
        if ([key isEqualToString:TUIInputMoreCellKey_Link] && !isNeedLink) {
            break;
        }
        TUIInputMoreCellData *linkMenusData = [TUIInputMoreCellData new];
        linkMenusData.key = key;
        linkMenusData.title = title;
        linkMenusData.image = TUIChatBundleThemeImage(imageName, imageName);
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
    if (!userID) {
        if (fail) {
            fail(ERR_INVALID_PARAMETERS, @"userID is nil");
        }
        return;
    }
    
    [[V2TIMManager sharedInstance] getUsersInfo:@[userID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        V2TIMUserFullInfo *info = infoList.firstObject;
        if (succ) {        
            succ(info);
        }
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
            if (succ) {
                succ(result);
            }
        } else {
            if (fail) {
                fail(result.resultCode, result.resultMsg);
            }
        }
    } fail:fail];
}

+ (void)findMessages:(NSArray *)msgIDs callback:(void(^)(BOOL succ, NSString *error_message, NSArray *msgs))callback
{
    [V2TIMManager.sharedInstance findMessages:msgIDs succ:^(NSArray<V2TIMMessage *> *msgs) {
        if (callback) {
            callback(YES, nil, msgs);
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(NO, desc, @[]);
        }
    }];
}

@end
