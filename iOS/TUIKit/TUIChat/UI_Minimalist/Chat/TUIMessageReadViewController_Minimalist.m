//
//  TUIMessageReadViewController_Minimalist.m
//  TUIChat
//
//  Created by xia on 2022/3/10.
//

#import "TUIMessageReadViewController_Minimalist.h"
#import "TUIThemeManager.h"
#import "TUIMemberCell_Minimalist.h"
#import "UIColor+TUIHexColor.h"
#import "TUITool.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIMemberCellData_Minimalist.h"
#import "TUIImageMessageCellData_Minimalist.h"
#import "TUIVideoMessageCellData_Minimalist.h"
#import "TUICore.h"

@interface TUIMessageReadViewController_Minimalist () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) TUIMessageCellData *cellData;
@property (nonatomic, assign) BOOL showReadStatusDisable;
@property (nonatomic, strong) TUIMessageDataProvider_Minimalist *dataProvider;

@property (nonatomic, strong) UIView *messageBackView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *readMembers;
@property (nonatomic, strong) NSMutableArray *unreadMembers;
@property (nonatomic, assign) NSUInteger readSeq;
@property (nonatomic, assign) NSUInteger unreadSeq;
@property (nonatomic, copy) NSString *c2cReceiverName;
@property (nonatomic, copy) NSString *c2cReceiverAvatarUrl;
@property (nonatomic, strong) TUIMessageCell_Minimalist *alertView;

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
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_viewWillShowHandler) {
        _viewWillShowHandler(_alertView);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_viewDidShowHandler) {
        _viewDidShowHandler(_alertView);
    }
}

- (void)dealloc {
    NSLog(@"%s dealloc", __FUNCTION__);
}

#pragma mark - Public
- (instancetype)initWithCellData:(TUIMessageCellData *)data
                    dataProvider:(TUIMessageDataProvider_Minimalist *)dataProvider
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
    self.view.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
    [self setupTitleView];
    
    [self setupMessageView];
    
    [self setupTableView];
}

- (void)layoutViews {
    float backViewTop = self.navigationController.navigationBar.mm_maxY;
    if (![UINavigationBar appearance].isTranslucent &&
        [[[UIDevice currentDevice] systemVersion] doubleValue] < 15.0) {
        backViewTop = 0;
    }
    
    self.tableView
        .mm_top(backViewTop)
        .mm_left(0)
        .mm_width(self.view.mm_w)
        .mm_height(self.view.mm_h - _tableView.mm_y);
}


- (void)setupTitleView {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TUIKitLocalizableString(MessageInfo);
    titleLabel.font = [UIFont systemFontOfSize:18.0];
    titleLabel.textColor = TUICoreDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void)setupMessageView {
    UIView *messageBackView = [[UIView alloc] init];
    messageBackView.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
    messageBackView.userInteractionEnabled = YES;
    self.messageBackView = messageBackView;
    
    UILabel *dateLabel = [[UILabel alloc] init];
    [messageBackView addSubview:dateLabel];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *dateString = [formatter stringFromDate:self.cellData.innerMessage.timestamp];
    dateLabel.text = dateString;
    dateLabel.font = [UIFont systemFontOfSize:kScale390(14)];
    dateLabel.textColor = TUIChatDynamicColor(@"chat_message_read_name_date_text_color", @"#999999");
    [dateLabel sizeToFit];
    dateLabel.frame = CGRectMake((self.view.frame.size.width - dateLabel.frame.size.width ) *0.5, kScale390(17), dateLabel.frame.size.width, kScale390(24));

    _alertView = [[self.alertCellClass alloc] init];
    _alertView.userInteractionEnabled = NO;
    [messageBackView addSubview:_alertView];
    
    _alertView.translatesAutoresizingMaskIntoConstraints = NO;
    [_alertView fillWithData:self.alertViewCellData];
    [_alertView layoutIfNeeded];
    if (self.alertViewCellData.direction == MsgDirectionIncoming) {
        _alertView.frame = CGRectMake(kScale390(16) ,dateLabel.frame.origin.y + dateLabel.frame.size.height, _originFrame.size.width, _originFrame.size.height);
    }
    else {
        _alertView.frame = CGRectMake(self.view.bounds.size.width - _originFrame.size.width - kScale390(12) ,
                                                dateLabel.frame.origin.y + dateLabel.frame.size.height,
                                                _originFrame.size.width, _originFrame.size.height);
    }
    
    messageBackView.mm_width (self.view.bounds.size.width);
    messageBackView.mm_height( _alertView.frame.origin.y + _alertView.frame.size.height + kScale390(4));

}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView setBackgroundColor:TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF")];
    [self.view addSubview:_tableView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:view];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[TUIMemberCell_Minimalist class] forCellReuseIdentifier:kMemberCellReuseId];
    [_tableView registerClass:[TUIMemberDescribeCell_Minimalist class] forCellReuseIdentifier:@"TUIMemberDescribeCell_Minimalist"];
    self.tableView.tableHeaderView = self.messageBackView;
    self.tableView.tableHeaderView.userInteractionEnabled = YES;
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
    [TUIMessageDataProvider_Minimalist getReadMembersOfMessage:self.cellData.innerMessage
                                                        filter:V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ
                                                       nextSeq:self.readSeq
                                                    completion:^(int code, NSString * _Nonnull desc, NSArray * _Nonnull members, NSUInteger nextSeq, BOOL isFinished) {
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
    [TUIMessageDataProvider_Minimalist getReadMembersOfMessage:self.cellData.innerMessage
                                                        filter:V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD
                                                       nextSeq:self.unreadSeq
                                                    completion:^(int code, NSString * _Nonnull desc, NSArray * _Nonnull members, NSUInteger nextSeq, BOOL isFinished) {
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

- (void)getUserOrFriendProfileVCWithUserID:(NSString *)userID
                                 SuccBlock:(void(^)(UIViewController *vc))succ
                                 failBlock:(nullable V2TIMFail)fail {
    NSDictionary *param = @{
        TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
        TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_SuccKey: succ ? : ^(UIViewController *vc){},
        TUICore_TUIContactService_GetUserOrFriendProfileVCMethod_FailKey: fail ? : ^(int code, NSString * desc){}
    };
    [TUICore callService:TUICore_TUIContactService_Minimalist
                  method:TUICore_TUIContactService_GetUserOrFriendProfileVCMethod
                   param:param];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TUICommonCellData *data = [self members][indexPath.row];
    @weakify(self)
    if ([data isKindOfClass:TUIMemberDescribeCellData_Minimalist.class]) {
        return;
    }
    else if ([data isKindOfClass:TUIMemberCellData_Minimalist.class]) {
        if ([self isGroupMessageRead]) {
            if (indexPath.row >= [self members].count) {
                return;
            }
            TUIMemberCellData_Minimalist *currentData = (TUIMemberCellData_Minimalist *)data;
            [self getUserOrFriendProfileVCWithUserID:currentData.userID
                                           SuccBlock:^(UIViewController *vc) {
                @strongify(self)
                [self.navigationController pushViewController:vc animated:YES];
            } failBlock:nil];
        } else {
            [self getUserOrFriendProfileVCWithUserID:self.cellData.innerMessage.userID
                                           SuccBlock:^(UIViewController *vc) {
                @strongify(self)
                [self.navigationController pushViewController:vc animated:YES];
            } failBlock:nil];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self members].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    TUICommonCellData *data = [self members][indexPath.row];
    TUICommonTableViewCell *cell = nil;
    
    if ([data isKindOfClass:TUIMemberDescribeCellData_Minimalist.class]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TUIMemberDescribeCell_Minimalist" forIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:kMemberCellReuseId forIndexPath:indexPath];
    }
    
    [cell fillWithData:data];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUICommonCellData *data = [self members][indexPath.row];
    if ([data isKindOfClass:TUIMemberDescribeCellData_Minimalist.class]) {
        return kScale390(57);
    }
    else {
        return kScale390(57);
    }
    return kScale390(57);
}
#pragma mark - datasource
- (NSArray *)members {
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:2];
    
    if ([self isGroupMessageRead]) {
        if (self.readMembers.count > 0) {
            TUIMemberDescribeCellData_Minimalist * describeCellData = [[TUIMemberDescribeCellData_Minimalist alloc] init];
            describeCellData.title = TUIKitLocalizableString(GroupReadBy);
            describeCellData.icon = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_all_people_read")];
            [dataArray addObject:describeCellData];
            
            for (V2TIMGroupMemberInfo *member in self.readMembers) {
                TUIMemberCellData_Minimalist * data = [[TUIMemberCellData_Minimalist alloc] initWithUserID:member.userID
                                                        nickName:member.nickName
                                                    friendRemark:member.friendRemark
                                                        nameCard:member.nameCard
                                                       avatarUrl:member.faceURL
                                                          detail:nil];
                [dataArray addObject:data];
            }
        }
        
        if (self.unreadMembers.count > 0) {
            TUIMemberDescribeCellData_Minimalist * describeCellData = [[TUIMemberDescribeCellData_Minimalist alloc] init];
            describeCellData.title = TUIKitLocalizableString(GroupDeliveredTo);
            describeCellData.icon = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_some_people_read")];
            
            [dataArray addObject:describeCellData];
            
            for (V2TIMGroupMemberInfo *member in self.unreadMembers) {
                TUIMemberCellData_Minimalist * data = [[TUIMemberCellData_Minimalist alloc] initWithUserID:member.userID
                                                        nickName:member.nickName
                                                    friendRemark:member.friendRemark
                                                        nameCard:member.nameCard
                                                       avatarUrl:member.faceURL
                                                          detail:nil];
                [dataArray addObject:data];
            }
        }
    }
    else {
        if (self.cellData.direction == MsgDirectionIncoming) {
            return dataArray;
        }
        NSString *detail = nil;
        BOOL isPeerRead = self.cellData.messageReceipt.isPeerRead;
        
        TUIMemberDescribeCellData_Minimalist * describeCellData = [[TUIMemberDescribeCellData_Minimalist alloc] init];
        if (isPeerRead) {
            
            describeCellData.title = TUIKitLocalizableString(C2CReadBy);
            describeCellData.icon = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_all_people_read")];
        }
        else {
            describeCellData.title = TUIKitLocalizableString(C2CDeliveredTo);
            describeCellData.icon = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"msg_status_some_people_read")];
        }
        
        TUIMemberCellData_Minimalist * data = [[TUIMemberCellData_Minimalist alloc] initWithUserID:self.cellData.innerMessage.userID
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

@end
