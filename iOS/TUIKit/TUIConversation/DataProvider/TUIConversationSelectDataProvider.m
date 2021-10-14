//
//  TUIConversationSelectModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/6/25.
//

#import "TUIConversationSelectDataProvider.h"
#import "TUIDefine.h"


@interface TUIConversationSelectDataProvider ()
@property (nonatomic, strong) NSMutableArray<V2TIMConversation *> *localConvList;
@end

@implementation TUIConversationSelectDataProvider

- (void)loadConversations
{
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getConversationList:0 count:INT_MAX succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateConversation:list];
    } fail:^(int code, NSString *msg) {
        // 拉取会话列表失败
        NSLog(@"getConversationList failed");
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
        data.unreadCount = 0;
        data.draftText = @"";
        data.subTitle = [[NSMutableAttributedString alloc] initWithString:@""];
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
}

- (BOOL)filteConversation:(V2TIMConversation *)conv
{
    // 屏蔽AVChatRoom的群聊会话
    if ([conv.groupType isEqualToString:@"AVChatRoom"]) {
        return YES;
    }
    return NO;
}

- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList
{
    // 按时间排序，最近会话在上
    [dataList sortUsingComparator:^NSComparisonResult(TUIConversationCellData *obj1, TUIConversationCellData *obj2) {
        return [obj2.time compare:obj1.time];
    }];

    // 将置顶会话固定在最上面
    NSArray *topList = [[TUIConversationPin sharedInstance] topConversationList];
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

- (NSArray<TUIConversationCellData *> *)dataList
{
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray<V2TIMConversation *> *)localConvList
{
    if (_localConvList == nil) {
        _localConvList = [NSMutableArray array];
    }
    return _localConvList;
}

// 创建会议群
- (void)createMeetingGroupWithContacts:(NSArray<TUICommonContactSelectCellData *>  *)contacts completion:(void(^)(BOOL, TUIConversationCellData *convData))completion
{
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSString *showName = loginUser;
        if (infoList.firstObject.nickName.length > 0) {
            showName = infoList.firstObject.nickName;
        }
        NSMutableString *groupName = [NSMutableString stringWithString:showName];
        NSMutableArray *members = [NSMutableArray array];
        //遍历contacts，初始化群组成员信息、群组名称信息
        for (TUICommonContactSelectCellData *item in contacts) {
            V2TIMCreateGroupMemberInfo *member = [[V2TIMCreateGroupMemberInfo alloc] init];
            member.userID = item.identifier;
            member.role = V2TIM_GROUP_MEMBER_ROLE_MEMBER;
            [groupName appendFormat:@"、%@", item.title];
            [members addObject:member];
        }

        //群组名称默认长度不超过10，如有需求可在此更改，但可能会出现UI上的显示bug
        if ([groupName length] > 10) {
            groupName = [groupName substringToIndex:10].mutableCopy;
        }

        V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
        info.groupName = groupName;
        info.groupType = GroupType_Meeting;

        //发送创建请求后的回调函数
        [[V2TIMManager sharedInstance] createGroup:info memberList:members succ:^(NSString *groupID) {
            //创建成功后，在群内推送创建成功的信息
            NSString *content = nil;
            if([info.groupType isEqualToString:GroupType_Work]) {
                content = NSLocalizedString(@"ChatsCreatePrivateGroupTips", nil); // @"创建讨论组";
            } else if([info.groupType isEqualToString:GroupType_Public]){
                content = NSLocalizedString(@"ChatsCreateGroupTips", nil); // @"创建群聊";
            } else if([info.groupType isEqualToString:GroupType_Meeting]) {
                content = NSLocalizedString(@"ChatsCreateChatRoomTips", nil); // @"创建聊天室";
            } else {
                content = NSLocalizedString(@"ChatsCreateDefaultTips", nil); // @"创建群组";
            }
            NSDictionary *dic = @{@"version": @(GroupCreate_Version),@"businessID": GroupCreate,@"opUser":showName,@"content":content};
            NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            V2TIMMessage *msg = [[V2TIMManager sharedInstance] createCustomMessage:data];
            [[V2TIMManager sharedInstance] sendMessage:msg receiver:nil groupID:groupID priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:nil progress:nil succ:nil fail:nil];

            //创建成功
            TUIConversationCellData *cellData = [[TUIConversationCellData alloc] init];
            cellData.groupID = groupID;
            cellData.title = groupName;
            if (completion) {
                completion(YES, cellData);
            }
            
        } fail:^(int code, NSString *msg) {
            if (completion) {
                completion(NO, nil);
            }
        }];
    } fail:^(int code, NSString *msg) {
        if (completion) {
            completion(NO, nil);
        }
    }];
}

@end
