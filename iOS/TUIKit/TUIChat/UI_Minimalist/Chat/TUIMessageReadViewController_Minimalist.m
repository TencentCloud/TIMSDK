//
//  TUIMessageReadViewController_Minimalist.m
//  TUIChat
//
//  Created by xia on 2022/3/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageReadViewController_Minimalist.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUITool.h>
#import <TUICore/UIColor+TUIHexColor.h>
#import "TUIImageMessageCellData.h"
#import "TUIMemberCellData.h"
#import "TUIMemberCell_Minimalist.h"
#import "TUIMessageDataProvider.h"
#import "TUIVideoMessageCellData.h"
#import "TUITextMessageCellData.h"
#import "TUIReplyMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "TUIMessageCellConfig_Minimalist.h"

@interface TUIMessageReadViewController_Minimalist () <UITableViewDelegate, UITableViewDataSource,TUINotificationProtocol>

@property(nonatomic, strong) TUIMessageCellData *cellData;
@property(nonatomic, assign) BOOL showReadStatusDisable;
@property(nonatomic, strong) TUIMessageDataProvider *dataProvider;

@property(nonatomic, strong) UIView *messageBackView;
@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSMutableArray *readMembers;
@property(nonatomic, strong) NSMutableArray *unreadMembers;
@property(nonatomic, assign) NSUInteger readSeq;
@property(nonatomic, assign) NSUInteger unreadSeq;
@property(nonatomic, copy) NSString *c2cReceiverName;
@property(nonatomic, copy) NSString *c2cReceiverAvatarUrl;
@property(nonatomic, strong) TUIMessageCell_Minimalist *alertView;
@property(nonatomic, strong) TUIMessageCellConfig_Minimalist *messageCellConfig;
@end

@implementation TUIMessageReadViewController_Minimalist

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self isGroupMessageRead]) {
        [self loadMembers];
    }
    [self setupViews];
    // Do any additional setup after loading the view.

    [TUICore registerEvent:TUICore_TUIPluginNotify subKey:TUICore_TUIPluginNotify_DidChangePluginViewSubKey object:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateRootMsg];
    if (_viewWillShowHandler) {
        _viewWillShowHandler(_alertView);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_viewDidShowHandler) {
        _viewDidShowHandler(_alertView);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_viewWillDismissHandler) {
        _viewWillDismissHandler(_alertView);
    }
}
- (void)dealloc {
    NSLog(@"%s dealloc", __FUNCTION__);
}

#pragma mark - Public
- (instancetype)initWithCellData:(TUIMessageCellData *)data
                    dataProvider:(TUIMessageDataProvider *)dataProvider
           showReadStatusDisable:(BOOL)showReadStatusDisable
                 c2cReceiverName:(NSString *)name
               c2cReceiverAvatar:(NSString *)avatarUrl {
    self = [super init];
    if (self) {
        self.cellData = data;
        self.dataProvider = dataProvider;
        self.showReadStatusDisable = showReadStatusDisable;
        self.c2cReceiverName = name;
        self.c2cReceiverAvatarUrl = avatarUrl;
    }
    return self;
}

#pragma mark - Private
- (void)setupViews {
    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
    [self setupTitleView];

    [self setupMessageView];
}

- (void)layoutViews {
    float backViewTop = self.navigationController.navigationBar.mm_maxY;
    self.messageBackView.frame = CGRectMake(0, 0, self.view.bounds.size.width, kScale390(17)+ kScale390(24)+ kScale390(4));
    self.tableView.mm_top(backViewTop).mm_left(0).mm_width(self.view.mm_w).mm_height(self.view.mm_h - _tableView.mm_y);
}

- (void)setupTitleView {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TIMCommonLocalizableString(MessageInfo);
    titleLabel.font = [UIFont systemFontOfSize:18.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void)setupMessageView {
    UIView *messageBackView = [[UIView alloc] init];
    messageBackView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    messageBackView.userInteractionEnabled = YES;
    self.messageBackView = messageBackView;
    self.tableView.tableHeaderView = self.messageBackView;
    self.tableView.tableHeaderView.userInteractionEnabled = YES;

    UILabel *dateLabel = [[UILabel alloc] init];
    [messageBackView addSubview:dateLabel];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *dateString = [formatter stringFromDate:self.cellData.innerMessage.timestamp];
    dateLabel.text = dateString;
    dateLabel.font = [UIFont systemFontOfSize:kScale390(14)];
    dateLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    dateLabel.textColor = TUIChatDynamicColor(@"chat_message_read_name_date_text_color", @"#999999");
    [dateLabel sizeToFit];
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(kScale390(17));
        make.width.mas_equalTo(dateLabel.frame.size.width);
        make.height.mas_equalTo(kScale390(24));
    }];
}

- (void)updateRootMsg {
    TUIMessageCellData *data = self.alertViewCellData;
    self.alertViewCellData.showAvatar = NO;
    self.alertViewCellData.showMessageModifyReplies = NO;
}

- (void)loadMembers {
    [self getReadMembersWithCompletion:^(int code, NSString *desc, NSArray *members, BOOL isFinished) {
      [self.tableView reloadData];
    }];
    [self getUnreadMembersWithCompletion:^(int code, NSString *desc, NSArray *members, BOOL isFinished) {
      [self.tableView reloadData];
    }];
}

- (void)getReadMembersWithCompletion:(void (^)(int code, NSString *desc, NSArray *members, BOOL isFinished))completion {
    @weakify(self);
    [TUIMessageDataProvider
        getReadMembersOfMessage:self.cellData.innerMessage
                         filter:V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ
                        nextSeq:self.readSeq
                     completion:^(int code, NSString *_Nonnull desc, NSArray *_Nonnull members, NSUInteger nextSeq, BOOL isFinished) {
                       @strongify(self);
                       if (code != 0) {
                           return;
                       }
                       [self.readMembers addObjectsFromArray:members];
                       self.readSeq = isFinished ? -1 : nextSeq;

                       if (completion) {
                           completion(code, desc, members, isFinished);
                       }
                     }];
}

- (void)getUnreadMembersWithCompletion:(void (^)(int code, NSString *desc, NSArray *members, BOOL isFinished))completion {
    @weakify(self);
    [TUIMessageDataProvider
        getReadMembersOfMessage:self.cellData.innerMessage
                         filter:V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD
                        nextSeq:self.unreadSeq
                     completion:^(int code, NSString *_Nonnull desc, NSArray *_Nonnull members, NSUInteger nextSeq, BOOL isFinished) {
                       @strongify(self);
                       if (code != 0) {
                           return;
                       }
                       [self.unreadMembers addObjectsFromArray:members];
                       self.unreadSeq = isFinished ? -1 : nextSeq;

                       if (completion) {
                           completion(code, desc, members, isFinished);
                       }
                     }];
}

- (void)getUserOrFriendProfileVCWithUserID:(NSString *)userID SuccBlock:(void (^)(UIViewController *vc))succ failBlock:(nullable V2TIMFail)fail {
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ ? : ^(UIViewController *vc){},
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail ? : ^(int code, NSString * desc){}
    };
    [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TUICommonCellData *data = [self members][indexPath.row];
    @weakify(self);
    if ([data isKindOfClass:TUIMemberDescribeCellData.class]) {
        return;
    } else if ([data isKindOfClass:TUIMemberCellData.class]) {
        if ([self isGroupMessageRead]) {
            if (indexPath.row >= [self members].count) {
                return;
            }
            TUIMemberCellData *currentData = (TUIMemberCellData *)data;
            [self getUserOrFriendProfileVCWithUserID:currentData.userID
                                           SuccBlock:^(UIViewController *vc) {
                                             @strongify(self);
                                             [self.navigationController pushViewController:vc animated:YES];
                                           }
                                           failBlock:nil];
        } else {
            [self getUserOrFriendProfileVCWithUserID:self.cellData.innerMessage.userID
                                           SuccBlock:^(UIViewController *vc) {
                                             @strongify(self);
                                             [self.navigationController pushViewController:vc animated:YES];
                                           }
                                           failBlock:nil];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0){
        return 1;
    }
    return [self members].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        TUIMessageCell *cell = nil;
        TUIMessageCellData *data = self.alertViewCellData;
        cell = [tableView dequeueReusableCellWithIdentifier:data.reuseId forIndexPath:indexPath];
        cell.delegate = self;
        [cell fillWithData:data];
        [cell notifyBottomContainerReadyOfData:nil];
        return cell;
    }
    
    TUICommonCellData *data = [self members][indexPath.row];
    TUICommonTableViewCell *cell = nil;

    if ([data isKindOfClass:TUIMemberDescribeCellData.class]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TUIMemberDescribeCell_Minimalist" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kMemberCellReuseId forIndexPath:indexPath];
    }

    [cell fillWithData:data];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CGFloat margin = 0;
        if (self.cellData.sameToNextMsgSender) {
            margin = 10;
        }
        return [self.messageCellConfig getHeightFromMessageCellData:self.cellData] + margin;
    }
    
    TUICommonCellData *data = [self members][indexPath.row];
    if ([data isKindOfClass:TUIMemberDescribeCellData.class]) {
        return kScale390(57);
    } else {
        return kScale390(57);
    }
    return kScale390(57);
}
#pragma mark - datasource
- (NSArray *)members {
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:2];

    if ([self isGroupMessageRead]) {
        if (self.readMembers.count > 0) {
            TUIMemberDescribeCellData *describeCellData = [[TUIMemberDescribeCellData alloc] init];
            describeCellData.title = TIMCommonLocalizableString(GroupReadBy);
            describeCellData.icon = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_all_people_read")];
            [dataArray addObject:describeCellData];

            for (V2TIMGroupMemberInfo *member in self.readMembers) {
                TUIMemberCellData *data = [[TUIMemberCellData alloc] initWithUserID:member.userID
                                                                                                 nickName:member.nickName
                                                                                             friendRemark:member.friendRemark
                                                                                                 nameCard:member.nameCard
                                                                                                avatarUrl:member.faceURL
                                                                                                   detail:nil];
                [dataArray addObject:data];
            }
        }

        if (self.unreadMembers.count > 0) {
            TUIMemberDescribeCellData *describeCellData = [[TUIMemberDescribeCellData alloc] init];
            describeCellData.title = TIMCommonLocalizableString(GroupDeliveredTo);
            describeCellData.icon = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_some_people_read")];

            [dataArray addObject:describeCellData];

            for (V2TIMGroupMemberInfo *member in self.unreadMembers) {
                TUIMemberCellData *data = [[TUIMemberCellData alloc] initWithUserID:member.userID
                                                                                                 nickName:member.nickName
                                                                                             friendRemark:member.friendRemark
                                                                                                 nameCard:member.nameCard
                                                                                                avatarUrl:member.faceURL
                                                                                                   detail:nil];
                [dataArray addObject:data];
            }
        }
    } else {
        if (self.cellData.direction == MsgDirectionIncoming) {
            return dataArray;
        }
        NSString *detail = nil;
        BOOL isPeerRead = self.cellData.messageReceipt.isPeerRead;

        TUIMemberDescribeCellData *describeCellData = [[TUIMemberDescribeCellData alloc] init];
        if (isPeerRead) {
            describeCellData.title = TIMCommonLocalizableString(C2CReadBy);
            describeCellData.icon = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_all_people_read")];
        } else {
            describeCellData.title = TIMCommonLocalizableString(C2CDeliveredTo);
            describeCellData.icon = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_some_people_read")];
        }

        TUIMemberCellData *data = [[TUIMemberCellData alloc] initWithUserID:self.cellData.innerMessage.userID
                                                                                         nickName:nil
                                                                                     friendRemark:self.c2cReceiverName
                                                                                         nameCard:nil
                                                                                        avatarUrl:self.c2cReceiverAvatarUrl
                                                                                           detail:detail];

        [dataArray addObject:describeCellData];
        [dataArray addObject:data];
    }

    return dataArray;
}

- (NSMutableArray *)readMembers {
    if (!_readMembers) {
        _readMembers = [[NSMutableArray alloc] init];
    }
    return _readMembers;
}

- (NSMutableArray *)unreadMembers {
    if (!_unreadMembers) {
        _unreadMembers = [[NSMutableArray alloc] init];
    }
    return _unreadMembers;
}

- (BOOL)isGroupMessageRead {
    return self.cellData.innerMessage.groupID.length > 0;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
        [_tableView setBackgroundColor:TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF")];
        [self.view addSubview:_tableView];

        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:view];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TUIMemberCell_Minimalist class] forCellReuseIdentifier:kMemberCellReuseId];
        [_tableView registerClass:[TUIMemberDescribeCell_Minimalist class] forCellReuseIdentifier:@"TUIMemberDescribeCell_Minimalist"];
        [self.messageCellConfig bindTableView:self.tableView];
    }
    return _tableView;
}

- (void)dataProvider:(TUIMessageBaseDataProvider *)dataProvider onRemoveHeightCache:(TUIMessageCellData *)cellData {
    if (cellData) {
        [self.messageCellConfig removeHeightCacheOfMessageCellData:cellData];
    }
}
- (TUIMessageCellConfig_Minimalist *)messageCellConfig {
    if (_messageCellConfig == nil) {
        _messageCellConfig = [[TUIMessageCellConfig_Minimalist alloc] init];
    }
    return _messageCellConfig;
}

#pragma mark - TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {

    if ([key isEqualToString:TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_DidChangePluginViewSubKey]) {
        // Translation View is Shown or content changed.
        TUIMessageCellData *data = param[TUICore_TUIPluginNotify_DidChangePluginViewSubKey_Data];
        [self clearAndReloadCellOfData:data];
    }
}

- (void)clearAndReloadCellOfData:(TUIMessageCellData *)data {
    [self.messageCellConfig removeHeightCacheOfMessageCellData:data];
    [self.tableView reloadData];
}
@end
