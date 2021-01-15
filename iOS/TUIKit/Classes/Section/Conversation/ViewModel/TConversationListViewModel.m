//
//  TConversationListViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TConversationListViewModel.h"
#import "TUILocalStorage.h"
#import "TUIKit.h"
#import "THeader.h"
#import "THelper.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMMessage+DataProvider.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"

@import ImSDK;

@interface TConversationListViewModel ()
@property BOOL isLoadFinished;
@property BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *localConvList;
@end

@implementation TConversationListViewModel

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRefreshNotificationAdded:) name:TUIKitNotification_TIMRefreshListener_Add object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRefreshNotificationChanged:) name:TUIKitNotification_TIMRefreshListener_Changed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onGroupDismiss:) name:TUIKitNotification_onGroupDismissed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onGroupRecycled:) name:TUIKitNotification_onGroupRecycled object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKickOffFromGroup:) name:TUIKitNotification_onKickOffFromGroup object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onLeaveFromGroup:) name:TUIKitNotification_onLeaveFromGroup object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didTopConversationListChanged:) name:kTopConversationListChangedNotification object:nil];
        self.localConvList = [[NSMutableArray alloc] init];
        [self loadConversation];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didTopConversationListChanged:(NSNotification *)no
{
    NSMutableArray *dataList = [NSMutableArray arrayWithArray:self.dataList];
    [self sortDataList:dataList];
    self.dataList = dataList;
}

- (void)onRefreshNotificationAdded:(NSNotification *)notify {
    // 新增会话
    NSArray *convList = notify.object;
    [self updateConversation:convList];
}

- (void)onRefreshNotificationChanged:(NSNotification *)notify {
    // 更新会话
    NSArray *convList = notify.object;
    [self updateConversation:convList];
}

- (void)loadConversation
{
    @weakify(self)
    [[V2TIMManager sharedInstance] getConversationList:0 count:INT_MAX succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {
        @strongify(self)
        [self updateConversation:list];
    } fail:^(int code, NSString *msg) {
        // 拉取会话列表失败
    }];
}

- (void)updateConversation:(NSArray *)convList
{
    // 更新 UI 会话列表，如果 UI 会话列表有新增的会话，就替换，如果没有，就新增
    for (int i = 0 ; i < convList.count ; ++ i) {
        V2TIMConversation *conv = convList[i];
        BOOL isExit = NO;
        for (int j = 0; j < self.localConvList.count; ++ j) {
            V2TIMConversation *localConv = self.localConvList[j];
            if ([localConv.conversationID isEqualToString:conv.conversationID]) {
                [self.localConvList replaceObjectAtIndex:j withObject:conv];
                isExit = YES;
                break;
            }
        }
        if (!isExit) {
            [self.localConvList addObject:conv];
        }
    }
    // 更新 cell data
    NSMutableArray *dataList = [NSMutableArray array];
    for (V2TIMConversation *conv in self.localConvList) {
        // 屏蔽会话
        if ([self filteConversation:conv]) {
            continue;
        }
        
        // 创建cellData
        TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
        data.conversationID = conv.conversationID;
        data.groupID = conv.groupID;
        data.userID = conv.userID;
        data.title = conv.showName;
        data.faceUrl = conv.faceUrl;
        data.subTitle = [self getLastDisplayString:conv];
        data.atMsgSeqList = [self getGroupAtMsgSeqList:conv];
        data.time = [self getLastDisplayDate:conv];
        if (NO == [conv.groupType isEqualToString:@"Meeting"]) {
            data.unreadCount = conv.unreadCount;
        }
        data.draftText = conv.draftText;
        if (conv.type == V2TIM_C2C) {   // 设置会话的默认头像
            data.avatarImage = DefaultAvatarImage;
        } else {
            data.avatarImage = DefaultGroupAvatarImage;
        }
        
        [dataList addObject:data];
    }
    // UI 会话列表根据 lastMessage 时间戳重新排序
    [self sortDataList:dataList];
    self.dataList = dataList;
    // 更新未读数
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onChangeUnReadCount object:self.localConvList];
}

- (BOOL)filteConversation:(V2TIMConversation *)conv
{
    // 屏蔽AVChatRoom的群聊会话
    if ([conv.groupType isEqualToString:@"AVChatRoom"]) {
        return YES;
    }
    
    // 屏蔽异常会话
    if ([self getLastDisplayString:conv] == nil || [self getLastDisplayDate:conv] == nil) {
        if (conv.unreadCount != 0) {
            // 修复 在某种情况下会出现data.time为nil且还有未读会话的情况，实际上是lastMessage为空(v1conv的lastmessage)，导致出现界面不显示当前会话，聊天界面却显示未读的情况
            // 如果碰到这种情况，直接设置成已读
            NSString *userID = conv.userID;
            if (userID.length > 0) {
                [[V2TIMManager sharedInstance] markC2CMessageAsRead:userID succ:^{
                    
                } fail:^(int code, NSString *msg) {
                    
                }];
            }
            NSString *groupID = conv.groupID;
            if (groupID.length > 0) {
                [[V2TIMManager sharedInstance] markGroupMessageAsRead:groupID succ:^{
                    
                } fail:^(int code, NSString *msg) {
                    
                }];
            }
        }
        return YES;
    }
    
    return NO;
}

- (void)onGroupDismiss:(NSNotification *)no
{
    NSString *groupID = no.object;
    TUIConversationCellData *data = [self cellDataOf:groupID];
    if (data) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitGroupDismssTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (void)onGroupRecycled:(NSNotification *)no
{
    NSString *groupID = no.object;
    TUIConversationCellData *data = [self cellDataOf:groupID];
    if (data) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitGroupRecycledTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (void)onKickOffFromGroup:(NSNotification *)no
{
    NSString *groupID = no.object;
    TUIConversationCellData *data = [self cellDataOf:groupID];
    if (data) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitGroupKickOffTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (void)onLeaveFromGroup:(NSNotification *)no
{
    NSString *groupID = no.object;
    TUIConversationCellData *data = [self cellDataOf:groupID];
    if (data) {
        [THelper makeToast:[NSString stringWithFormat:TUILocalizableString(TUIKitGroupDropoutTipsFormat), data.groupID]];
        [self removeData:data];
    }
}

- (NSMutableArray<NSNumber *> *)getGroupAtMsgSeqList:(V2TIMConversation *)conv {
    NSMutableArray *seqList = [NSMutableArray array];
    for (V2TIMGroupAtInfo *atInfo in conv.groupAtInfolist) {
        [seqList addObject:@(atInfo.seq)];
    }
    if (seqList.count > 0) {
        return seqList;
    }
    return nil;
}

- (NSString *)getGroupAtTipString:(V2TIMConversation *)conv {
    NSString *atTipsStr = @"";
    BOOL atMe = NO;
    BOOL atAll = NO;
    for (V2TIMGroupAtInfo *atInfo in conv.groupAtInfolist) {
        switch (atInfo.atType) {
            case V2TIM_AT_ME:
                atMe = YES;
                continue;;
            case V2TIM_AT_ALL:
                atAll = YES;
                continue;;
            case V2TIM_AT_ALL_AT_ME:
                atMe = YES;
                atAll = YES;
                continue;;
            default:
                continue;;
        }
    }
    if (atMe && !atAll) {
        atTipsStr = TUILocalizableString(TUIKitConversationTipsAtMe); // @"[有人@我]";
    }
    if (!atMe && atAll) {
        atTipsStr = TUILocalizableString(TUIKitConversationTipsAtAll); // @"[@所有人]";
    }
    if (atMe && atAll) {
        atTipsStr = TUILocalizableString(TUIKitConversationTipsAtMeAndAll); // @"[有人@我][@所有人]";
    }
    return atTipsStr;
}

- (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conv
{
    NSString *lastMsgStr = [conv.lastMessage getDisplayString];
    // 如果没有 lastMsg 和草稿，直接返回 nil
    if (lastMsgStr.length == 0 && conv.draftText.length == 0) {
        return nil;
    }
    NSString *atStr = [self getGroupAtTipString:conv];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",atStr]];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemRedColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];
    
    if(conv.draftText.length > 0){
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:TUILocalizableString(TUIKitMessageTypeDraftFormat),conv.draftText]]];
    } else {
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:lastMsgStr]];
    }
    return attributeString;
}

- (NSDate *)getLastDisplayDate:(V2TIMConversation *)conv
{
    if(conv.draftText.length > 0){
        return conv.draftTimestamp;
    }
    if (conv.lastMessage) {
        return conv.lastMessage.timestamp;
    }
    return [NSDate distantPast];
}

- (TUIConversationCellData *)cellDataOf:(NSString *)groupID
{
    for (TUIConversationCellData *data in self.dataList) {
        if ([data.groupID isEqualToString:groupID]) {
            return data;
        }
    }
    return nil;
}

- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList
{
    // 按时间排序，最近会话在上
    [dataList sortUsingComparator:^NSComparisonResult(TUIConversationCellData *obj1, TUIConversationCellData *obj2) {
        return [obj2.time compare:obj1.time];
    }];

    // 将置顶会话固定在最上面
    NSArray *topList = [[TUILocalStorage sharedInstance] topConversationList];
    int existTopListSize = 0;
    for (NSString *convID in topList) {
        int userIdx = -1;
        for (int i = 0; i < dataList.count; i++) {
            if ([dataList[i].conversationID isEqualToString:convID]) {
                userIdx = i;
                dataList[i].isOnTop = YES;
                break;
            }
        }
        if (userIdx >= 0 && userIdx != existTopListSize) {
            TUIConversationCellData *data = dataList[userIdx];
            [dataList removeObjectAtIndex:userIdx];
            [dataList insertObject:data atIndex:existTopListSize];
            existTopListSize++;
        }
    }
}

- (void)removeData:(TUIConversationCellData *)data
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:self.dataList];
    [list removeObject:data];
    self.dataList = list;
    for (V2TIMConversation *conv in self.localConvList) {
        if ([conv.conversationID isEqualToString:data.conversationID]) {
            [self.localConvList removeObject:conv];
            break;
        }
    }
    [[V2TIMManager sharedInstance] deleteConversation:data.conversationID succ:nil fail:nil];
}
@end
