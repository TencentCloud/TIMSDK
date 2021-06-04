//
//  TUIConversationSelectController.m
//  Pods
//
//  Created by harvy on 2020/12/8.
//

#import "TUIConversationSelectController.h"
#import "NSBundle+TUIKIT.h"
#import "TUIConversationCell.h"
#import "TIMMessage+DataProvider.h"
#import "TUIConversationCellData.h"
#import "TUIContactListPicker.h"
#import "THeader.h"
#import "TUIKit.h"
#import "TCommonCell.h"
#import "TUIContactSelectController.h"
#import "TCommonContactCellData.h"
#import "THelper.h"


@interface TUIConversationSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TUIContactListPicker *pickerView;
@property (nonatomic, strong) TCommonTableViewCell *headerView;

@property (nonatomic, assign) BOOL enableMuliple;
@property (nonatomic, strong) NSMutableArray<TUIConversationCellData *> *dataList;
@property (nonatomic, strong) NSMutableArray<V2TIMConversation *> *localConvList;
@property (nonatomic, strong) NSMutableArray<TUIConversationCellData *> *currentSelectedList;      // 当前选中的会话列表

@end

@implementation TUIConversationSelectController

static NSString *const Id = @"con";

#pragma mark - Life
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self loadConversations];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateLayout];
}

#pragma mark - API
+ (instancetype)showIn:(UIViewController *)presentVC
{
    TUIConversationSelectController *vc = [[TUIConversationSelectController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    UIViewController *pVc = presentVC;
    if (pVc == nil) {
        pVc = UIApplication.sharedApplication.keyWindow.rootViewController;
    }
    [pVc presentViewController:nav animated:YES completion:nil];
    return vc;
}

#pragma mark - Datas
- (void)loadConversations
{
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getConversationList:0 count:INT_MAX succ:^(NSArray<V2TIMConversation *> *list, uint64_t lastTS, BOOL isFinished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateConversation:list];
    } fail:^(int code, NSString *msg) {
        // 拉取会话列表失败
        NSLog(@"");
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
    [self.tableView reloadData];
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

// 创建讨论组
- (void)createMeetingGroupWithContacts:(NSArray<TCommonContactSelectCellData *>  *)contacts completion:(void(^)(BOOL, TUIConversationCellData *convData))completion
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
        for (TCommonContactSelectCellData *item in contacts) {
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

#pragma mark - UI
- (void)setupViews
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TUILocalizableString(Cancel)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(doCancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TUILocalizableString(Multiple)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(doMultiple)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _headerView = [[TCommonTableViewCell alloc] init];
    _headerView.textLabel.text = TUILocalizableString(TUIKitRelayTargetCreateNewChat);
    _headerView.textLabel.font = [UIFont systemFontOfSize:15.0];
    _headerView.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [_headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCreateSessionOrSelectContact)]];
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = self.headerView;
    [_tableView registerClass:TUIConversationCell.class forCellReuseIdentifier:Id];
    [self.view addSubview:_tableView];
    
    _pickerView = [[TUIContactListPicker alloc] initWithFrame:CGRectZero];
    _pickerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _pickerView.hidden = YES;
    [_pickerView.accessoryBtn addTarget:self action:@selector(doPickerDone) forControlEvents:UIControlEventTouchUpInside];
    __weak typeof(self) weakSelf = self;
    _pickerView.onCancel = ^(TCommonContactSelectCellData * _Nonnull data) {
        TUIConversationCellData *tmp = nil;
        for (TUIConversationCellData *convCellData in weakSelf.currentSelectedList) {
            if ([convCellData.conversationID isEqualToString:data.identifier]) {
                tmp = convCellData;
                break;
            }
        }
        if (tmp == nil) {
            return;
        }
        
        tmp.selected = NO;
        [weakSelf.currentSelectedList removeObject:tmp];
        [weakSelf updatePickerView];
        [weakSelf.tableView reloadData];
    };
    [self.view addSubview:_pickerView];
}

- (void)updateLayout
{
    self.pickerView.hidden = !self.enableMuliple;
    self.headerView.frame =  CGRectMake(0, 0, self.view.bounds.size.width, 55);
    _headerView.textLabel.text = self.enableMuliple ? TUILocalizableString(TUIKitRelayTargetSelectFromContacts) : TUILocalizableString(TUIKitRelayTargetCreateNewChat);
    
    if (!self.enableMuliple) {
        self.tableView.frame = self.view.bounds;
        return;
    }
    
    CGFloat pH = 55;
    CGFloat pMargin = 0;
    if (@available(iOS 11.0, *)) {
        pMargin = self.view.safeAreaInsets.bottom;
    }
    self.pickerView.frame = CGRectMake(0, self.view.bounds.size.height - pH - pMargin, self.view.bounds.size.width, pH + pMargin);
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - pH - pMargin);
}

- (void)updatePickerView
{
    NSMutableArray *arrayM = [NSMutableArray array];
    for (TUIConversationCellData *convCellData in self.currentSelectedList) {
        TCommonContactCellData *data = [[TCommonContactCellData alloc] init];
        data.avatarUrl = [NSURL URLWithString:convCellData.faceUrl];
        data.avatarImage = convCellData.avatarImage;
        data.title = convCellData.title;
        data.identifier = convCellData.conversationID;
        [arrayM addObject:data];
    }
    self.pickerView.selectArray = [NSArray arrayWithArray:arrayM];
}

#pragma mark - Action
- (void)doCancel
{
    if (self.enableMuliple) {
        // 退出多选
        self.enableMuliple = NO;
        [self.currentSelectedList removeAllObjects];
        self.pickerView.selectArray = @[];
        [self updatePickerView];
        [self updateLayout];
        [self.tableView reloadData];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)doMultiple
{
    self.enableMuliple = YES;
    [self updateLayout];
    [self.tableView reloadData];
}

- (void)onCreateSessionOrSelectContact
{
    __weak typeof(self) weakSelf = self;
    TUIContactSelectController *vc = [[TUIContactSelectController alloc] init];
    vc.finishBlock = ^(NSArray<TCommonContactSelectCellData *> * _Nonnull selectArray) {
        if (weakSelf.enableMuliple) {
            // 多选: 从通讯录中选择 -> 为每个联系人创建会话 -> pickerView显示每个联系人
            for (TCommonContactSelectCellData *contact in selectArray) {
                if ([self existInSelectedArray:contact]) {
                    continue;
                }
                TUIConversationCellData *conv = [[TUIConversationCellData alloc] init];
                conv.conversationID = contact.identifier;
                conv.userID = contact.identifier;
                conv.groupID = @"";
                conv.avatarImage = contact.avatarImage;
                conv.faceUrl = contact.avatarUrl.absoluteString;
                [weakSelf.currentSelectedList addObject:conv];
            }
            [weakSelf updatePickerView];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else {
            // 单选: 创建新聊天(多人就是群聊) -> 为所选联系人创建群聊 -> 直接转发
            if (selectArray.count <= 1) {
                // 只有一个，创建一个单独的会话即可
                TCommonContactSelectCellData *contact = selectArray.firstObject;
                if (contact) {
                    TUIConversationCellData *conv = [[TUIConversationCellData alloc] init];
                    conv.conversationID = contact.identifier;
                    conv.userID = contact.identifier;
                    conv.groupID = @"";
                    conv.avatarImage = contact.avatarImage;
                    conv.faceUrl = contact.avatarUrl.absoluteString;
                    weakSelf.currentSelectedList = [NSMutableArray arrayWithArray:@[conv]];
                    [weakSelf tryFinishSelected:^(BOOL finished) {
                        if (finished) {
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
                return;
            }
            [weakSelf createMeetingGroupWithContacts:selectArray completion:^(BOOL success, TUIConversationCellData *convData) {
                if (!success) {
                    [THelper makeToast:TUILocalizableString(TUIKitRelayTargetCrateGroupError)];
                    return;
                }
                weakSelf.currentSelectedList = [NSMutableArray arrayWithArray:@[convData]];
                [weakSelf tryFinishSelected:^(BOOL finished) {
                    if (finished) {
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            }];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)existInSelectedArray:(TCommonContactSelectCellData *)contact
{
    for (TUIConversationCellData *cellData in self.currentSelectedList) {
        if (cellData.userID.length && [cellData.userID isEqualToString:contact.identifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)doPickerDone
{
    __weak typeof(self) weakSelf = self;
    [self tryFinishSelected:^(BOOL finished) {
        if (finished) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

// 试着转发消息
- (void)tryFinishSelected:(TUIConversationSelectCompletHandler)handler
{
    if (self.currentSelectedList.count == 0) {
        [THelper makeToast:TUILocalizableString(TUIKitRelayTargetNoneTips)];
        return;
    }
    
    if (self.callback) {
        self.callback(self.currentSelectedList, handler);
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:Id forIndexPath:indexPath];
    if (indexPath.row < 0 || indexPath.row >= self.dataList.count) {
        return cell;
    }
    TUIConversationCellData *cellData = self.dataList[indexPath.row];
    cellData.showCheckBox = self.enableMuliple;
    cellData.cselector = @selector(didSelectConversation:);
    [cell fillWithData:cellData];
    return cell;
}

- (void)didSelectConversation:(TUIConversationCell *)cell
{
    TUIConversationCellData *cellData = cell.convData;
    cellData.selected = !cellData.selected;
    if (!self.enableMuliple) {
        // 单选
        self.currentSelectedList = [NSMutableArray arrayWithArray:@[cellData]];
        __weak typeof(self) weakSelf = self;
        [self tryFinishSelected:^(BOOL finished) {
            if (finished) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        return;
    }
    
    // 多选
    if ([self.currentSelectedList containsObject:cellData]) {
        [self.currentSelectedList removeObject:cellData];
    }else {
        [self.currentSelectedList addObject:cellData];
    }
    
    // 显示pickerView
    [self updatePickerView];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    titleView.bounds = CGRectMake(0, 0, self.tableView.bounds.size.width, 30);
    UILabel *label = [[UILabel alloc] init];
    label.text = TUILocalizableString(TUIKitRelayRecentMessages);
    label.font = [UIFont systemFontOfSize:12.0];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentLeft;
    [titleView addSubview:label];
    label.frame = CGRectMake(10, 0, self.tableView.bounds.size.width - 10, 30);
    return titleView;
}

#pragma mark - Lazy
- (NSMutableArray *)dataList
{
    if (_dataList == nil) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray *)localConvList
{
    if (_localConvList == nil) {
        _localConvList = [NSMutableArray array];
    }
    return _localConvList;
}

- (NSMutableArray *)currentSelectedList
{
    if (_currentSelectedList == nil) {
        _currentSelectedList = [NSMutableArray array];
    }
    return _currentSelectedList;
}

@end
