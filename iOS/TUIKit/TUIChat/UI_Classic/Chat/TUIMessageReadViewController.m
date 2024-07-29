//
//  TUIMessageReadViewController.m
//  TUIChat
//
//  Created by xia on 2022/3/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageReadViewController.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUITool.h>
#import <TUICore/UIColor+TUIHexColor.h>
#import "TUIImageMessageCellData.h"
#import "TUIMemberCell.h"
#import "TUIMemberCellData.h"
#import "TUIMessageDataProvider.h"
#import "TUIVideoMessageCellData.h"

@interface TUIMessageReadSelectView ()

@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *bottomLine;

@end

@implementation TUIMessageReadSelectView

#pragma mark - Life cycle
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutViews];
}

#pragma mark - Public
- (instancetype)initWithTitle:(NSString *)title viewTag:(TUIMessageReadViewTag)tag selected:(BOOL)selected {
    self = [super init];
    if (self) {
        self.title = title;
        self.tag = tag;

        [self setupViews];
        [self setupGesture];
        [self setupRAC];

        self.selected = selected;
    }
    return self;
}

#pragma mark - Private
- (void)setupViews {
    self.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.title;
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];

    self.bottomLine = [[UIView alloc] init];
    [self addSubview:self.bottomLine];
}

- (void)layoutViews {
    self.titleLabel.mm_sizeToFit().mm_height(24).mm__centerX(self.mm_w / 2.0).mm__centerY(self.mm_h / 2.0);

    self.bottomLine.mm_width(self.titleLabel.mm_w).mm_height(5 / 2.0).mm_top(self.titleLabel.mm_maxY + 8 / 2.0).mm__centerX(self.titleLabel.mm_centerX);
}

- (void)setupRAC {
    @weakify(self);
    [RACObserve(self, selected) subscribeNext:^(id _Nullable x) {
      @strongify(self);
      [self updateColorBySelected:self.selected];
    }];
}

- (void)updateColorBySelected:(BOOL)selected {
    UIColor *color = selected ? TUIChatDynamicColor(@"chat_message_read_status_tab_color", @"#147AFF")
                              : TIMCommonDynamicColor(@"chat_message_read_status_tab_unselect_color", @"#444444");
    self.titleLabel.textColor = color;
    self.bottomLine.hidden = !selected;
    self.bottomLine.backgroundColor = color;
}

- (void)setupGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - Event
- (void)onTapped:(UIGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(messageReadSelectView:didSelectItemTag:)]) {
        [self.delegate messageReadSelectView:self didSelectItemTag:self.tag];
    }
}

@end

@interface TUIMessageReadViewController () <UITableViewDelegate, UITableViewDataSource, TUIMessageReadSelectViewDelegate>

@property(nonatomic, strong) TUIMessageCellData *cellData;
@property(nonatomic, assign) BOOL showReadStatusDisable;
@property(nonatomic, assign) TUIMessageReadViewTag selectedViewTag;
@property(nonatomic, strong) TUIMessageDataProvider *dataProvider;

@property(nonatomic, strong) UIView *messageBackView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property(nonatomic, strong) UILabel *contentLabel;

@property(nonatomic, strong) NSMutableDictionary *selectViewsDict;
@property(nonatomic, strong) NSMutableArray *readMembers;
@property(nonatomic, strong) NSMutableArray *unreadMembers;
@property(nonatomic, assign) NSUInteger readSeq;
@property(nonatomic, assign) NSUInteger unreadSeq;
@property(nonatomic, copy) NSString *c2cReceiverName;
@property(nonatomic, copy) NSString *c2cReceiverAvatarUrl;

@end

@implementation TUIMessageReadViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self isGroupMessageRead]) {
        self.selectedViewTag = TUIMessageReadViewTagRead;
        [self loadMembers];
    } else {
        self.selectedViewTag = TUIMessageReadViewTagC2C;
    }
    [self setupViews];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_viewWillDismissHandler) {
        _viewWillDismissHandler();
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
    if ([self isGroupMessageRead]) {
        [self setupSelectView];
    }
    [self setupTableView];
}

- (void)layoutViews {
    id content = [self content];
    CGFloat messageBackViewHeight = 69 ;
    if ([content isKindOfClass:UIImage.class]) {
        messageBackViewHeight = 87;
    }
    [self.messageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.leading.mas_equalTo(0);
        make.height.mas_equalTo(messageBackViewHeight);
        make.width.mas_equalTo(self.view);
    }];
    // content label may not exist when content is not text
    if (self.contentLabel) {
        [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.top.mas_equalTo(33);
            make.height.mas_equalTo(24);
            make.trailing.mas_equalTo(-16);
        }];
    }

    UIView *readView = [self layoutSelectView:self.selectViewsDict[@(TUIMessageReadViewTagRead)] leftView:nil];
    UIView *unreadView = [self layoutSelectView:self.selectViewsDict[@(TUIMessageReadViewTagUnread)] leftView:readView];
    if (self.showReadStatusDisable) {
        [self layoutSelectView:self.selectViewsDict[@(TUIMessageReadViewTagReadDisable)] leftView:unreadView];
    }

    self.tableView.mm_top(self.messageBackView.mm_maxY + 10 + (self.selectViewsDict.count > 0 ? 48 : 0))
        .mm_left(0)
        .mm_width(self.view.mm_w)
        .mm_height(self.view.mm_h - _tableView.mm_y);
}

- (UIView *)layoutSelectView:(UIView *)view leftView:(UIView *)leftView {
    NSInteger count = self.selectViewsDict.count;
    if (count == 0) {
        return nil;
    }
    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view).multipliedBy(1.0/count);
        make.height.mas_equalTo(48);
        if (leftView) {
            make.leading.mas_equalTo(leftView.mas_trailing);
        }
        else {
            make.leading.mas_equalTo(0);
        }
        make.top.mas_equalTo(self.messageBackView.mas_bottom).mas_offset(10);
    }];
    return view;
}

- (void)setupTitleView {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TIMCommonLocalizableString(TUIKitMessageReadDetail);
    titleLabel.font = [UIFont systemFontOfSize:18.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void)setupMessageView {
    UIView *messageBackView = [[UIView alloc] init];
    messageBackView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    [self.view addSubview:messageBackView];
    self.messageBackView = messageBackView;

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = self.cellData.senderName;
    nameLabel.font = [UIFont systemFontOfSize:12.0];
    nameLabel.textColor = TUIChatDynamicColor(@"chat_message_read_name_date_text_color", @"#999999");
    nameLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    [messageBackView addSubview:nameLabel];
    [nameLabel sizeToFit];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.leading.mas_equalTo(16);
        make.width.mas_equalTo(nameLabel.frame.size.width);
        make.height.mas_equalTo(nameLabel.frame.size.height);
    }];
    UILabel *dateLabel = [[UILabel alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    NSString *dateString = [formatter stringFromDate:self.cellData.innerMessage.timestamp];
    dateLabel.text = dateString;
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    dateLabel.textColor = TUIChatDynamicColor(@"chat_message_read_name_date_text_color", @"#999999");
    [messageBackView addSubview:dateLabel];
    [dateLabel sizeToFit];
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(nameLabel);
        make.leading.mas_equalTo(nameLabel.mas_trailing).mas_offset(12);
        make.width.mas_equalTo(dateLabel.frame.size.width);
        make.height.mas_equalTo(dateLabel.frame.size.height);
    }];
    id content = [self content];
    if ([content isKindOfClass:NSString.class]) {
        UILabel *contentLabel = [[UILabel alloc] init];
        contentLabel.text = content;
        contentLabel.font = [UIFont systemFontOfSize:16];
        contentLabel.textColor = TUIChatDynamicColor(@"chat_input_text_color", @"#111111");
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        self.contentLabel = contentLabel;
        [messageBackView addSubview:contentLabel];
    } else if ([content isKindOfClass:UIImage.class]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = content;
        [messageBackView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(33);
            make.leading.mas_equalTo(16);
            make.width.mas_equalTo([self scaledSizeOfImage:content].width);
            make.height.mas_equalTo([self scaledSizeOfImage:content].height);
        }];
    }
}

- (void)setupSelectView {
    NSMutableDictionary *dataDict = [self selectViewsData];
    NSInteger count = dataDict.count;
    NSMutableArray * selectViewsArray = [NSMutableArray arrayWithCapacity:2];
    UIView *tmp = nil;
    for (NSNumber *tag in dataDict) {
        NSDictionary *data = dataDict[tag];
        TUIMessageReadSelectView *selectView = [[TUIMessageReadSelectView alloc] initWithTitle:data[@"title"]
                                                                                       viewTag:[data[@"tag"] integerValue]
                                                                                      selected:[data[@"selected"] boolValue]];
        selectView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
        selectView.delegate = self;
        [self.view addSubview:selectView];
        [selectViewsArray addObject:selectView];
        [self.selectViewsDict setObject:selectView forKey:data[@"tag"]];

        selectView.mm_width(self.view.mm_w / count)
            .mm_height(48)
            .mm_left(tmp == nil ? 0 : tmp.mm_x + tmp.mm_w)
            .mm_top(self.messageBackView.mm_y + self.messageBackView.mm_h + 10);

        tmp = selectView;
    }
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    _tableView.rowHeight = 56;
    [_tableView setBackgroundColor:TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF")];
    [self.view addSubview:_tableView];
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:view];
    _tableView.separatorStyle = [self isGroupMessageRead] ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    [_tableView registerClass:[TUIMemberCell class] forCellReuseIdentifier:kMemberCellReuseId];

    self.indicatorView.frame = CGRectMake(0, 0, self.view.bounds.size.width, TMessageController_Header_Height);
    self.tableView.tableFooterView = self.indicatorView;
}

- (void)loadMembers {
    [self getReadMembersWithCompletion:^(int code, NSString *desc, NSArray *members, BOOL isFinished) {
      if (code != 0) {
          [TUITool makeToast:TIMCommonLocalizableString(TUIKitMessageReadGetReadMembersFail)];
          NSLog(@"get read members failed, code: %d, desc: %@", code, desc);
          return;
      }
      [self.tableView reloadData];
    }];
    [self getUnreadMembersWithCompletion:^(int code, NSString *desc, NSArray *members, BOOL isFinished) {
      if (code != 0) {
          [TUITool makeToast:TIMCommonLocalizableString(TUIKitMessageReadGetUnreadMembersFail)];
          NSLog(@"get unread members failed, code: %d, desc: %@", code, desc);
          return;
      }
      [self.tableView reloadData];
    }];
}

- (void)getReadMembersWithCompletion:(void (^)(int code, NSString *desc, NSArray *members, BOOL isFinished))completion {
    @weakify(self);
    [TUIMessageDataProvider getReadMembersOfMessage:self.cellData.innerMessage
                                             filter:V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ
                                            nextSeq:self.readSeq
                                         completion:^(int code, NSString *_Nonnull desc, NSArray *_Nonnull members, NSUInteger nextSeq, BOOL isFinished) {
                                           @strongify(self);
                                           if (code != 0) {
                                               if (completion) {
                                                   completion(code, desc, nil, NO);
                                               }
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
    [TUIMessageDataProvider getReadMembersOfMessage:self.cellData.innerMessage
                                             filter:V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD
                                            nextSeq:self.unreadSeq
                                         completion:^(int code, NSString *_Nonnull desc, NSArray *_Nonnull members, NSUInteger nextSeq, BOOL isFinished) {
                                           @strongify(self);
                                           if (code != 0) {
                                               if (completion) {
                                                   completion(code, desc, nil, NO);
                                               }
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
    [TUICore createObject:TUICore_TUIContactObjectFactory key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isGroupMessageRead]) {
        if (indexPath.row >= [self members].count) {
            return;
        }
        V2TIMGroupMemberInfo *member = [self members][indexPath.row];
        [self getUserOrFriendProfileVCWithUserID:member.userID
                                       SuccBlock:^(UIViewController *vc) {
                                         [self.navigationController pushViewController:vc animated:YES];
                                       }
                                       failBlock:nil];
    } else {
        [self getUserOrFriendProfileVCWithUserID:self.cellData.innerMessage.userID
                                       SuccBlock:^(UIViewController *vc) {
                                         [self.navigationController pushViewController:vc animated:YES];
                                       }
                                       failBlock:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self isGroupMessageRead] ? [self members].count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:kMemberCellReuseId forIndexPath:indexPath];
    cell.changeColorWhenTouched = YES;

    TUIMemberCellData *data;
    if ([self isGroupMessageRead]) {
        if (indexPath.row >= [self members].count) {
            return nil;
        }
        V2TIMGroupMemberInfo *member = [self members][indexPath.row];
        data = [[TUIMemberCellData alloc] initWithUserID:member.userID
                                                nickName:member.nickName
                                            friendRemark:member.friendRemark
                                                nameCard:member.nameCard
                                               avatarUrl:member.faceURL
                                                  detail:nil];
    } else {
        NSString *detail = nil;
        BOOL isPeerRead = self.cellData.messageReceipt.isPeerRead;
        detail = isPeerRead ? TIMCommonLocalizableString(TUIKitMessageReadC2CRead) : TIMCommonLocalizableString(TUIKitMessageReadC2CUnReadDetail);
        data = [[TUIMemberCellData alloc] initWithUserID:self.cellData.innerMessage.userID
                                                nickName:nil
                                            friendRemark:self.c2cReceiverName
                                                nameCard:nil
                                               avatarUrl:self.c2cReceiverAvatarUrl
                                                  detail:detail];
    }
    [cell fillWithData:data];
    return cell;
}

#pragma mark - UIScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0 || scrollView.contentOffset.y < scrollView.bounds.origin.y) {
        return;
    }
    if (self.indicatorView.isAnimating) {
        return;
    }
    [self.indicatorView startAnimating];
    @weakify(self);
    switch (self.selectedViewTag) {
        case TUIMessageReadViewTagRead: {
            [self getReadMembersWithCompletion:^(int code, NSString *desc, NSArray *members, BOOL isFinished) {
              @strongify(self);
              [self.indicatorView stopAnimating];
              [self refreshTableView];

              if (members != nil && members.count == 0) {
                  [TUITool makeToast:TIMCommonLocalizableString(TUIKitMessageReadNoMoreData)];
                  [self.tableView setContentOffset:CGPointMake(0, scrollView.contentOffset.y - TMessageController_Header_Height) animated:YES];
              }
            }];
            break;
        }
        case TUIMessageReadViewTagUnread: {
            [self getUnreadMembersWithCompletion:^(int code, NSString *desc, NSArray *members, BOOL isFinished) {
              @strongify(self);
              [self.indicatorView stopAnimating];
              [self refreshTableView];

              if (members != nil && members.count == 0) {
                  [TUITool makeToast:TIMCommonLocalizableString(TUIKitMessageReadNoMoreData)];
                  [self.tableView setContentOffset:CGPointMake(0, scrollView.contentOffset.y - TMessageController_Header_Height) animated:YES];
              }
            }];
            break;
        }
        case TUIMessageReadViewTagReadDisable: {
            break;
        }
        default: {
            break;
        }
    }
}

- (void)refreshTableView {
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
}

#pragma mark - TUIMessageReadSelectViewDelegate
- (void)messageReadSelectView:(TUIMessageReadSelectView *)view didSelectItemTag:(TUIMessageReadViewTag)tag {
    for (TUIMessageReadSelectView *view in self.selectViewsDict.allValues) {
        view.selected = view.tag == tag;
    }
    self.selectedViewTag = tag;
    [self.tableView reloadData];
}

#pragma mark - Getter
- (id)content {
    V2TIMMessage *msg = self.cellData.innerMessage;
    NSMutableString *content = [NSMutableString stringWithString:[TUIMessageDataProvider getDisplayString:msg]];
    switch (msg.elemType) {
        case V2TIM_ELEM_TYPE_IMAGE: {
            TUIImageMessageCellData *data = (TUIImageMessageCellData *)self.cellData;
            return data.thumbImage;
        }
        case V2TIM_ELEM_TYPE_VIDEO: {
            TUIVideoMessageCellData *data = (TUIVideoMessageCellData *)self.cellData;
            return data.thumbImage;
        }
        case V2TIM_ELEM_TYPE_FILE: {
            [content appendString:msg.fileElem.filename];
            break;
        }
        case V2TIM_ELEM_TYPE_CUSTOM: {
            break;
        }
        default: {
            break;
        }
    }
    return content;
}

- (CGSize)scaledSizeOfImage:(UIImage *)image {
    NSSet *portraitOrientations =
        [NSSet setWithArray:@[ @(UIImageOrientationLeft), @(UIImageOrientationRight), @(UIImageOrientationLeftMirrored), @(UIImageOrientationRightMirrored) ]];

    UIImageOrientation orientation = image.imageOrientation;
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);

    // Height is fixed at 42.0, and width is proportionally scaled.
    if ([portraitOrientations containsObject:@(orientation)]) {
        // UIImage is stored in memory in a fixed size, like 1280 * 720.
        // So we should adapt its size manually according to the direction.
        return CGSizeMake(42.0 * height / width, 42.0);
    } else {
        return CGSizeMake(42.0 * width / height, 42.0);
    }
}

- (NSMutableDictionary *)selectViewsData {
    NSMutableDictionary *readViews = [NSMutableDictionary dictionaryWithDictionary:@{
        @(TUIMessageReadViewTagRead) : @{
            @"tag" : @(TUIMessageReadViewTagRead),
            @"title" :
                [NSString stringWithFormat:@"%ld %@", (long)self.cellData.messageReceipt.readCount, TIMCommonLocalizableString(TUIKitMessageReadPartRead)],
            @"selected" : @(YES)
        },
        @(TUIMessageReadViewTagUnread) : @{
            @"tag" : @(TUIMessageReadViewTagUnread),
            @"title" :
                [NSString stringWithFormat:@"%ld %@", (long)self.cellData.messageReceipt.unreadCount, TIMCommonLocalizableString(TUIKitMessageReadPartUnread)],
            @"selected" : @(NO)
        },
    }];
    if (self.showReadStatusDisable) {
        [readViews
            setObject:@{@"tag" : @(TUIMessageReadViewTagReadDisable), @"title" : TIMCommonLocalizableString(TUIKitMessageReadPartDisable), @"selected" : @(NO)}
               forKey:@(TUIMessageReadViewTagReadDisable)];
    }
    return readViews;
}

- (NSArray *)members {
    switch (self.selectedViewTag) {
        case TUIMessageReadViewTagRead: {
            return self.readMembers;
        }
        case TUIMessageReadViewTagUnread: {
            return self.unreadMembers;
        }
        case TUIMessageReadViewTagReadDisable: {
            return @[];
        }
        default: {
            return @[];
        }
    }
}

- (NSMutableDictionary *)selectViewsDict {
    if (!_selectViewsDict) {
        _selectViewsDict = [[NSMutableDictionary alloc] init];
    }
    return _selectViewsDict;
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

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

- (BOOL)isGroupMessageRead {
    return self.cellData.innerMessage.groupID.length > 0;
}

@end
