//
//  TUIConversationListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationListController.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIConversationCell.h"
#import "TUIConversationListDataProvider.h"
#import "TUIFoldListViewController.h"

#define GroupBtnSpace 24
#define GroupScrollViewHeight 30

@interface TUIConversationListController () <UIGestureRecognizerDelegate,
                                             UIPopoverPresentationControllerDelegate,
                                             TUIConversationTableViewDelegate,
                                             TUIPopViewDelegate,
                                             TUINotificationProtocol>
@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) TUIConversationListBaseDataProvider *settingDataProvider;
@property(nonatomic, strong) UIView *tableViewContainer;
@property(nonatomic, strong) UIView *bannerView;
@property(nonatomic, assign) CGFloat viewHeight;

@property(nonatomic, assign) BOOL actualShowConversationGroup;
@property(nonatomic, strong) UIView *groupView;
@property(nonatomic, strong) UIScrollView *groupScrollView;
@property(nonatomic, strong) UIView *groupAnimationView;
@property(nonatomic, strong) UIView *groupBtnContainer;
@property(nonatomic, strong) NSMutableArray *groupItemList;
@property(nonatomic, strong) TUIConversationGroupItem *allGroupItem;
@end

@implementation TUIConversationListController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isShowBanner = YES;
        self.isShowConversationGroup = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];
    }
    return self;
}

#pragma mark - NSNotification
- (void)onThemeChanged {
    self.groupAnimationView.layer.borderColor = [TUIConversationDynamicColor(@"conversation_group_bg_color", @"#EBECF0") CGColor];
}

#pragma mark - SettingDataProvider
- (void)setDataProvider:(TUIConversationListBaseDataProvider *)dataProvider {
    self.settingDataProvider = dataProvider;
}

- (TUIConversationListBaseDataProvider *)dataProvider {
    return self.settingDataProvider;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigation];
    [self setupViews];
    [TUICore registerEvent:TUICore_TUIConversationGroupNotify subKey:@"" object:self];
    [TUICore registerEvent:TUICore_TUIConversationMarkNotify subKey:@"" object:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.currentTableView reloadData];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [TUICore unRegisterEventByObject:self];
}

- (void)setupNavigation {
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:TIMCommonDynamicImage(@"nav_more_img", [UIImage imageNamed:TIMCommonImagePath(@"more")]) forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [moreButton.widthAnchor constraintEqualToConstant:24].active = YES;
    [moreButton.heightAnchor constraintEqualToConstant:24].active = YES;
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationController.navigationItem.rightBarButtonItem = moreItem;

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)rightBarButtonClick:(UIButton *)rightBarButton {
    NSMutableArray *menus = [NSMutableArray array];
    TUIPopCellData *friend = [[TUIPopCellData alloc] init];

    friend.image = TUIConversationDynamicImage(@"pop_icon_new_chat_img", [UIImage imageNamed:TUIConversationImagePath(@"new_chat")]);
    friend.title = TIMCommonLocalizableString(ChatsNewChatText);
    [menus addObject:friend];

    TUIPopCellData *group = [[TUIPopCellData alloc] init];
    group.image = TUIConversationDynamicImage(@"pop_icon_new_group_img", [UIImage imageNamed:TUIConversationImagePath(@"new_groupchat")]);
    group.title = TIMCommonLocalizableString(ChatsNewGroupText);
    [menus addObject:group];

    CGFloat height = [TUIPopCell getHeight] * menus.count + TUIPopView_Arrow_Size.height;
    CGFloat orginY = StatusBar_Height + NavBar_Height;
    CGFloat orginX = Screen_Width - 155;
    if(isRTL()){
        orginX = 10;
    }
    TUIPopView *popView = [[TUIPopView alloc] initWithFrame:CGRectMake(orginX, orginY, 145, height)];
    CGRect frameInNaviView = [self.navigationController.view convertRect:rightBarButton.frame fromView:rightBarButton.superview];
    popView.arrowPoint = CGPointMake(frameInNaviView.origin.x + frameInNaviView.size.width * 0.5, orginY);
    popView.delegate = self;
    [popView setData:menus];
    [popView showInWindow:self.view.window];
}

- (void)setupViews {
    self.view.backgroundColor = TUIConversationDynamicColor(@"conversation_bg_color", @"#FFFFFF");
    self.viewHeight = self.view.mm_h;
    if (self.isShowBanner) {
        CGSize size = CGSizeMake(self.view.bounds.size.width, 60);
        self.bannerView.mm_width(size.width).mm_height(60);
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[TUICore_TUIConversationExtension_ConversationListBanner_BannerSize] = NSStringFromCGSize(size);
        param[TUICore_TUIConversationExtension_ConversationListBanner_ModalVC] = self;
        BOOL result = [TUICore raiseExtension:TUICore_TUIConversationExtension_ConversationListBanner_ClassicExtensionID
                                   parentView:self.bannerView
                                        param:param];
        if (!result) {
            self.bannerView.mm_height(0);
        }
    }

    [self.view addSubview:self.tableViewContainer];
    [self.tableViewContainer addSubview:self.tableViewForAll];

    if (self.isShowConversationGroup) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          NSArray *extensionList = [TUICore getExtensionList:TUICore_TUIConversationExtension_ConversationGroupListBanner_ClassicExtensionID param:nil];
          @weakify(self);
          [[[RACObserve(self, actualShowConversationGroup) distinctUntilChanged] skip:0] subscribeNext:^(NSNumber *showConversationGroup) {
            @strongify(self);
            if ([showConversationGroup boolValue]) {
                [self.tableViewContainer setFrame:CGRectMake(0, self.groupView.mm_maxY, self.view.mm_w, self.viewHeight - self.groupView.mm_maxY)];

                self.groupItemList = [NSMutableArray array];
                [self addGroup:self.allGroupItem];

                for (TUIExtensionInfo *info in extensionList) {
                    TUIConversationGroupItem *groupItem = info.data[TUICore_TUIConversationExtension_ConversationGroupListBanner_GroupItemKey];
                    if (groupItem) {
                        [self addGroup:groupItem];
                    }
                }
                [self onSelectGroup:self.allGroupItem];
            } else {
                self.tableViewContainer.frame = CGRectMake(0, self.bannerView.mm_maxY, self.view.mm_w, self.viewHeight - self.bannerView.mm_maxY);
                self.tableViewForAll.frame = self.tableViewContainer.bounds;
            }
          }];
          self.actualShowConversationGroup = (extensionList.count > 0);
        });
    } else {
        self.tableViewContainer.frame = CGRectMake(0, self.bannerView.mm_maxY, self.view.mm_w, self.viewHeight - self.bannerView.mm_maxY);
        self.tableViewForAll.frame = self.tableViewContainer.bounds;
    }
}

- (TUIConversationGroupItem *)allGroupItem {
    if (!_allGroupItem) {
        _allGroupItem = [[TUIConversationGroupItem alloc] init];
        _allGroupItem.groupName = TIMCommonLocalizableString(TUIConversationGroupAll);
    }
    return _allGroupItem;
}

- (UIView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, StatusBar_Height + NavBar_Height, 0, 0)];
        [self.view addSubview:_bannerView];
    }
    return _bannerView;
}

- (TUIConversationTableView *)currentTableView {
    for (UIView *view in self.tableViewContainer.subviews) {
        if ([view isKindOfClass:[TUIConversationTableView class]]) {
            return (TUIConversationTableView *)view;
        }
    }
    return nil;
}

- (UIView *)tableViewContainer {
    if (!_tableViewContainer) {
        _tableViewContainer = [[UIView alloc] init];
        _tableViewContainer.autoresizesSubviews = YES;
    }
    return _tableViewContainer;
}

- (TUIConversationTableView *)tableViewForAll {
    if (!_tableViewForAll) {
        _tableViewForAll = [[TUIConversationTableView alloc] init];
        _tableViewForAll.convDelegate = self;
        _tableViewForAll.tipsMsgWhenNoConversation = [NSString stringWithFormat:TIMCommonLocalizableString(TUIConversationNone), @""];
        if (self.settingDataProvider) {
            [_tableViewForAll setDataProvider:self.settingDataProvider];
        } else {
            TUIConversationListDataProvider *dataProvider = [[TUIConversationListDataProvider alloc] init];
            [_tableViewForAll setDataProvider:dataProvider];
        }
    }
    return _tableViewForAll;
}

- (UIView *)groupView {
    if (!_groupView) {
        _groupView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bannerView.mm_maxY, self.view.mm_w, 60)];
        [self.view addSubview:_groupView];

        CGFloat groupExtensionBtnLeft = _groupView.mm_w - GroupScrollViewHeight - kScale375(16);
        self.groupBtnContainer = [[UIView alloc] initWithFrame:CGRectMake(groupExtensionBtnLeft, 18, GroupScrollViewHeight, GroupScrollViewHeight)];
        [_groupView addSubview:self.groupBtnContainer];
        [TUICore raiseExtension:TUICore_TUIConversationExtension_ConversationGroupManagerContainer_ClassicExtensionID
                     parentView:self.groupBtnContainer
                          param:@{TUICore_TUIConversationExtension_ConversationGroupManagerContainer_ParentVCKey : self}];
        
        CGFloat groupScrollViewWidth = self.groupBtnContainer.mm_x - kScale375(16) - kScale375(10);
        UIView *groupScrollBackgrounView = [[UIView alloc] init];
        [_groupView addSubview:groupScrollBackgrounView];
        groupScrollBackgrounView.frame = CGRectMake(kScale375(16), 18, groupScrollViewWidth, GroupScrollViewHeight);
        self.groupScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, groupScrollViewWidth, GroupScrollViewHeight)];
        self.groupScrollView.backgroundColor = TUIConversationDynamicColor(@"conversation_group_bg_color", @"#EBECF0");
        self.groupScrollView.showsHorizontalScrollIndicator = NO;
        self.groupScrollView.showsVerticalScrollIndicator = NO;
        self.groupScrollView.bounces = NO;
        self.groupScrollView.scrollEnabled = YES;
        self.groupScrollView.layer.cornerRadius = GroupScrollViewHeight / 2.0;
        self.groupScrollView.layer.masksToBounds = YES;
        [groupScrollBackgrounView addSubview:self.groupScrollView];
        @weakify(self);
        [[[RACObserve(self.groupScrollView, contentSize) distinctUntilChanged] skip:1] subscribeNext:^(NSValue *contentSizeValue) {
          @strongify(self);
            [self.groupScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(groupScrollBackgrounView.mas_leading);
                make.height.mas_equalTo(GroupScrollViewHeight);
                make.width.mas_equalTo(MIN(groupScrollViewWidth, [contentSizeValue CGSizeValue].width));
                make.centerY.mas_equalTo(groupScrollBackgrounView);
            }];
        }];

        self.groupAnimationView = [[UIView alloc] init];
        self.groupAnimationView.backgroundColor = TUIConversationDynamicColor(@"conversation_group_animate_view_color", @"#FFFFFF");
        self.groupAnimationView.layer.cornerRadius = GroupScrollViewHeight / 2.0;
        self.groupAnimationView.layer.masksToBounds = YES;
        self.groupAnimationView.layer.borderWidth = 1;
        self.groupAnimationView.layer.borderColor = [TUIConversationDynamicColor(@"conversation_group_bg_color", @"#EBECF0") CGColor];
        [self.groupScrollView addSubview:self.groupAnimationView];
        if (isRTL()) {
            [groupScrollBackgrounView resetFrameToFitRTL];
            [self.groupBtnContainer resetFrameToFitRTL];
            self.groupScrollView.transform = CGAffineTransformMakeRotation(M_PI);
            NSArray *subViews = self.groupScrollView.subviews;
            for (UIView *subView in subViews) {
                    subView.transform = CGAffineTransformMakeRotation(M_PI);
            }
        }
    }
    return _groupView;
}

#pragma mark Conversation Group Manager
- (void)createGroupBtn:(TUIConversationGroupItem *)groupItem positionX:(CGFloat)positionX {
    UIButton *groupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [groupBtn setBackgroundColor:[UIColor clearColor]];
    [groupBtn setAttributedTitle:[self getGroupBtnAttributedString:groupItem] forState:UIControlStateNormal];
    [groupBtn setTitleColor:TUIConversationDynamicColor(@"conversation_group_btn_unselect_color", @"#666666") forState:UIControlStateNormal];
    [groupBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [groupBtn addTarget:self action:@selector(onGroupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [groupBtn sizeToFit];
    groupBtn.mm_x = positionX;
    groupBtn.mm_w = groupBtn.mm_w + GroupBtnSpace;
    groupBtn.mm_h = GroupScrollViewHeight;
    groupItem.groupBtn = groupBtn;
    if (isRTL()) {
        groupBtn.transform = CGAffineTransformMakeRotation(M_PI);
    }

}

- (void)updateGroupBtn:(TUIConversationGroupItem *)groupItem {
    [groupItem.groupBtn setAttributedTitle:[self getGroupBtnAttributedString:groupItem] forState:UIControlStateNormal];
    if(isRTL()) {
        groupItem.groupBtn.mm_w = groupItem.groupBtn.mm_w ;
        groupItem.groupBtn.mm_h = GroupScrollViewHeight;
    }
    else {
        [groupItem.groupBtn sizeToFit];
        groupItem.groupBtn.mm_w = groupItem.groupBtn.mm_w + GroupBtnSpace;
        groupItem.groupBtn.mm_h = GroupScrollViewHeight;
    }
}

- (void)onGroupBtnClick:(UIButton *)btn {
    for (TUIConversationGroupItem *groupItem in self.groupItemList) {
        if ([groupItem.groupBtn isEqual:btn]) {
            [self onSelectGroup:groupItem];
            return;
        }
    }
}

- (void)reloadGroupList:(NSArray<TUIConversationGroupItem *> *)groupItemList {
    NSString *currentSelectGroup = @"";
    for (TUIConversationGroupItem *groupItem in self.groupItemList) {
        if (groupItem.groupBtn.isSelected) {
            currentSelectGroup = groupItem.groupName;
        }
        [groupItem.groupBtn removeFromSuperview];
    }
    [self.groupItemList removeAllObjects];
    [self.groupScrollView setContentSize:CGSizeZero];

    [self addGroup:self.allGroupItem];
    for (TUIConversationGroupItem *groupItem in groupItemList) {
        [self addGroup:groupItem];
        if ([groupItem.groupName isEqualToString:currentSelectGroup]) {
            groupItem.groupBtn.selected = YES;
            self.groupAnimationView.frame = groupItem.groupBtn.frame;
        }
    }
    if (isRTL()) {
        NSArray *subViews = self.groupScrollView.subviews;
        for (UIView *subView in subViews) {
                subView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }
}

- (void)addGroup:(TUIConversationGroupItem *)addGroup {
    [self createGroupBtn:addGroup positionX:self.groupScrollView.contentSize.width];
    [self.groupItemList addObject:addGroup];
    [self.groupScrollView addSubview:addGroup.groupBtn];
    [self.groupScrollView setContentSize:CGSizeMake(addGroup.groupBtn.mm_maxX, GroupScrollViewHeight)];
}

- (void)insertGroup:(TUIConversationGroupItem *)insertGroup atIndex:(NSInteger)index {
    if (index < self.groupItemList.count) {
        for (int i = 0; i < self.groupItemList.count; ++i) {
            TUIConversationGroupItem *groupItem = self.groupItemList[i];
            if (i == index) {
                [self createGroupBtn:insertGroup positionX:groupItem.groupBtn.mm_x];
                [self.groupScrollView addSubview:insertGroup.groupBtn];
            }
            if (i >= index) {
                groupItem.groupBtn.mm_x += insertGroup.groupBtn.mm_w;
                if (groupItem.groupBtn.isSelected) {
                    self.groupAnimationView.frame = groupItem.groupBtn.frame;
                }
            }
        }
        [self.groupItemList insertObject:insertGroup atIndex:index];
        [self.groupScrollView setContentSize:CGSizeMake(self.groupScrollView.contentSize.width + insertGroup.groupBtn.mm_w, GroupScrollViewHeight)];
    } else {
        [self addGroup:insertGroup];
    }
}

- (void)updateGroup:(TUIConversationGroupItem *)updateGroup {
    CGFloat offsetX = 0;
    for (int i = 0; i < self.groupItemList.count; ++i) {
        TUIConversationGroupItem *groupItem = self.groupItemList[i];
        if (offsetX != 0) {
            groupItem.groupBtn.mm_x += offsetX;
        }
        if ([groupItem.groupName isEqualToString:updateGroup.groupName]) {
            groupItem.unreadCount = updateGroup.unreadCount;
            CGFloat oldBtnWidth = groupItem.groupBtn.mm_w;
            [self updateGroupBtn:groupItem];
            CGFloat newBtnWidth = groupItem.groupBtn.mm_w;
            offsetX = newBtnWidth - oldBtnWidth;
        }
        if (groupItem.groupBtn.isSelected) {
            self.groupAnimationView.frame = groupItem.groupBtn.frame;
        }
    }
    [self.groupScrollView setContentSize:CGSizeMake(self.groupScrollView.contentSize.width + offsetX, GroupScrollViewHeight)];
}

- (void)renameGroup:(NSString *)oldName newName:(NSString *)newName {
    CGFloat offsetX = 0;
    for (int i = 0; i < self.groupItemList.count; ++i) {
        TUIConversationGroupItem *groupItem = self.groupItemList[i];
        if (offsetX != 0) {
            groupItem.groupBtn.mm_x += offsetX;
        }
        if ([groupItem.groupName isEqualToString:oldName]) {
            groupItem.groupName = newName;
            CGFloat oldBtnWidth = groupItem.groupBtn.mm_w;
            [self updateGroupBtn:groupItem];
            CGFloat newBtnWidth = groupItem.groupBtn.mm_w;
            offsetX = newBtnWidth - oldBtnWidth;
        }
        if (groupItem.groupBtn.isSelected) {
            self.groupAnimationView.frame = groupItem.groupBtn.frame;
        }
    }
    [self.groupScrollView setContentSize:CGSizeMake(self.groupScrollView.contentSize.width + offsetX, GroupScrollViewHeight)];
}

- (void)deleteGroup:(TUIConversationGroupItem *)deleteGroup {
    CGFloat offsetX = 0;
    NSUInteger removeIndex = 0;
    BOOL isSelectedGroup = NO;
    for (int i = 0; i < self.groupItemList.count; ++i) {
        TUIConversationGroupItem *groupItem = self.groupItemList[i];
        if (offsetX != 0) {
            groupItem.groupBtn.mm_x += offsetX;
        }
        if ([groupItem.groupName isEqualToString:deleteGroup.groupName]) {
            [groupItem.groupBtn removeFromSuperview];
            offsetX = -groupItem.groupBtn.mm_w;
            removeIndex = i;
            isSelectedGroup = groupItem.groupBtn.isSelected;
        }
        if (groupItem.groupBtn.isSelected) {
            self.groupAnimationView.frame = groupItem.groupBtn.frame;
        }
    }
    [self.groupItemList removeObjectAtIndex:removeIndex];
    [self.groupScrollView setContentSize:CGSizeMake(self.groupScrollView.contentSize.width + offsetX, GroupScrollViewHeight)];
    if (isSelectedGroup) {
        [self onSelectGroup:self.groupItemList.firstObject];
    }
}

- (void)onSelectGroup:(TUIConversationGroupItem *)selectGroupItem {
    for (int i = 0; i < self.groupItemList.count; ++i) {
        TUIConversationGroupItem *groupItem = self.groupItemList[i];
        if ([groupItem.groupName isEqualToString:selectGroupItem.groupName]) {
            groupItem.groupBtn.selected = YES;

            [UIView animateWithDuration:0.1
                             animations:^{
                               self.groupAnimationView.frame = groupItem.groupBtn.frame;
                             }];
            for (UIView *view in self.tableViewContainer.subviews) {
                [view removeFromSuperview];
            }
            if ([groupItem.groupName isEqualToString:TIMCommonLocalizableString(TUIConversationGroupAll)]) {
                self.tableViewForAll.frame = self.tableViewContainer.bounds;
                [self.tableViewContainer addSubview:self.tableViewForAll];
            } else {
                [TUICore raiseExtension:TUICore_TUIConversationExtension_ConversationListContainer_ClassicExtensionID
                             parentView:self.tableViewContainer
                                  param:@{TUICore_TUIConversationExtension_ConversationListContainer_GroupNameKey : groupItem.groupName}];
                self.currentTableView.convDelegate = self;
            }
        } else {
            groupItem.groupBtn.selected = NO;
        }
        [self updateGroupBtn:groupItem];
    }
}

- (NSMutableAttributedString *)getGroupBtnAttributedString:(TUIConversationGroupItem *)groupItem {
    NSMutableString *content = [NSMutableString stringWithString:@""];
    NSMutableString *contentName = [NSMutableString stringWithString: groupItem.groupName];
    NSMutableString *contentNum = [NSMutableString stringWithString:@""];
    NSMutableAttributedString *attributeString = nil;
    NSInteger unreadCount = groupItem.unreadCount;
    if (unreadCount > 0) {
        [contentNum appendString:(unreadCount > 99 ? @"99+" : [@(unreadCount) stringValue])];
    }
    if (isRTL()){
        [content appendString:@"\u200E"];
        [content appendString:contentNum];
        [content appendString:@" "];
        [content appendString:@"\u202B"];
        [content appendString:contentName];
        attributeString = [[NSMutableAttributedString alloc] initWithString:content];
    }
    else {
        [content appendString:contentName];
        [content appendString:@" "];
        [content appendString:contentNum];
        attributeString = [[NSMutableAttributedString alloc] initWithString:content];
    }
    
    [attributeString setAttributes:@{
        NSForegroundColorAttributeName : TUIConversationDynamicColor(@"conversation_group_btn_select_color", @"#147AFF"),
        NSFontAttributeName : [UIFont systemFontOfSize:12],
        NSBaselineOffsetAttributeName : @(1)
    }
                             range:[content rangeOfString:contentNum]];
    if (groupItem.groupBtn.isSelected) {
        [attributeString setAttributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:16],
            NSForegroundColorAttributeName : TUIConversationDynamicColor(@"conversation_group_btn_select_color", @"#147AFF")
        }
                                 range:[content rangeOfString:contentName]];
    } else {
        [attributeString setAttributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:16],
            NSForegroundColorAttributeName : TUIConversationDynamicColor(@"conversation_group_btn_unselect_color", @"#666666")
        }
                                 range:[content rangeOfString:contentName]];
    }
    return attributeString;
}

#pragma mark TUINotificationProtocol
- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIConversationGroupNotify] || [key isEqualToString:TUICore_TUIConversationMarkNotify]) {
        if (!self.actualShowConversationGroup) {
            self.actualShowConversationGroup = YES;
        }
    }
    if ([key isEqualToString:TUICore_TUIConversationGroupNotify]) {
        if ([param objectForKey:TUICore_TUIConversationGroupNotify_GroupListReloadKey]) {
            NSArray *groupItemList = [param objectForKey:TUICore_TUIConversationGroupNotify_GroupListReloadKey];
            if (groupItemList) {
                [self reloadGroupList:groupItemList];
            }
        } else if ([param objectForKey:TUICore_TUIConversationGroupNotify_GroupAddKey]) {
            TUIConversationGroupItem *groupItem = [param objectForKey:TUICore_TUIConversationGroupNotify_GroupAddKey];
            if (groupItem) {
                [self addGroup:groupItem];
            }
        } else if ([param objectForKey:TUICore_TUIConversationGroupNotify_GroupUpdateKey]) {
            TUIConversationGroupItem *groupItem = [param objectForKey:TUICore_TUIConversationGroupNotify_GroupUpdateKey];
            if (groupItem) {
                [self updateGroup:groupItem];
            }
        } else if ([param objectForKey:TUICore_TUIConversationGroupNotify_GroupRenameKey]) {
            NSDictionary *renameItem = [param objectForKey:TUICore_TUIConversationGroupNotify_GroupRenameKey];
            if (renameItem) {
                [self renameGroup:renameItem.allKeys.firstObject newName:renameItem.allValues.firstObject];
            }
        } else if ([param objectForKey:TUICore_TUIConversationGroupNotify_GroupDeleteKey]) {
            TUIConversationGroupItem *groupItem = [param objectForKey:TUICore_TUIConversationGroupNotify_GroupDeleteKey];
            if (groupItem) {
                [self deleteGroup:groupItem];
            }
        }
    } else if ([key isEqualToString:TUICore_TUIConversationMarkNotify]) {
        if ([param objectForKey:TUICore_TUIConversationGroupNotify_MarkAddKey]) {
            TUIConversationGroupItem *groupItem = [param objectForKey:TUICore_TUIConversationGroupNotify_MarkAddKey];
            if (groupItem) {
                [self insertGroup:groupItem atIndex:groupItem.groupIndex];
            }
        } else if ([param objectForKey:TUICore_TUIConversationGroupNotify_MarkUpdateKey]) {
            TUIConversationGroupItem *groupItem = [param objectForKey:TUICore_TUIConversationGroupNotify_MarkUpdateKey];
            if (groupItem) {
                [self updateGroup:groupItem];
            }
        }
    }
}

#pragma TUIConversationTableViewDelegate
- (void)tableViewDidScroll:(CGFloat)offsetY {
    if (!self.bannerView || self.bannerView.hidden || !self.isShowBanner) {
        return;
    }
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.currentTableView.adjustedContentInset;
    }
    CGFloat contentSizeHeight = self.currentTableView.contentSize.height + safeAreaInsets.top + safeAreaInsets.bottom;
    if (contentSizeHeight > self.currentTableView.mm_h && self.currentTableView.contentOffset.y + self.currentTableView.mm_h > contentSizeHeight) {
        return;
    }
    if (offsetY > self.bannerView.mm_h) {
        offsetY = self.bannerView.mm_h;
    }
    if (offsetY < 0) {
        offsetY = 0;
    }
    self.bannerView.mm_top(StatusBar_Height + NavBar_Height - offsetY);
    if (self.actualShowConversationGroup) {
        self.groupView.mm_top(self.bannerView.mm_maxY);
        self.tableViewContainer.mm_top(self.groupView.mm_maxY).mm_height(self.viewHeight - self.groupView.mm_maxY);
    } else {
        self.tableViewContainer.mm_top(self.bannerView.mm_maxY).mm_height(self.viewHeight - self.bannerView.mm_maxY);
    }
}

- (void)tableViewDidSelectCell:(TUIConversationCellData *)data {
    if (data.isLocalConversationFoldList) {
        [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:NO];

        TUIFoldListViewController *foldVC = [[TUIFoldListViewController alloc] init];
        [self.navigationController pushViewController:foldVC animated:YES];

        @weakify(self);
        foldVC.dismissCallback = ^(NSMutableAttributedString *_Nonnull foldStr, NSArray *_Nonnull sortArr, NSArray *_Nonnull needRemoveFromCacheMapArray) {
          @strongify(self);
          data.foldSubTitle = foldStr;
          data.subTitle = data.foldSubTitle;
          data.isMarkAsUnread = NO;

          if (sortArr.count <= 0) {
              data.orderKey = 0;
              if ([self.dataProvider.conversationList containsObject:data]) {
                  [self.dataProvider hideConversation:data];
              }
          }

          for (NSString *removeId in needRemoveFromCacheMapArray) {
              if ([self.dataProvider.markFoldMap objectForKey:removeId]) {
                  [self.dataProvider.markFoldMap removeObjectForKey:removeId];
              }
          }

          [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:NO];
          [self.currentTableView reloadData];
        };
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]) {
        [self.delegate conversationListController:self didSelectConversation:data];
    } else {
        NSDictionary *param = @{
            TUICore_TUIChatObjectFactory_ChatViewController_Title : data.title ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_UserID : data.userID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_GroupID : data.groupID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : data.avatarImage ?: [UIImage new],
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : data.faceUrl ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_ConversationID : data.conversationID ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AtTipsStr : data.atTipsStr ?: @"",
            TUICore_TUIChatObjectFactory_ChatViewController_AtMsgSeqs : data.atMsgSeqs ?: @[],
            TUICore_TUIChatObjectFactory_ChatViewController_Draft : data.draftText ?: @""
        };
        [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Classic param:param forResult:nil];
    }
}

- (void)tableViewDidShowAlert:(UIAlertController *)ac {
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma TUIPopViewDelegate
- (void)popView:(TUIPopView *)popView didSelectRowAtIndex:(NSInteger)index {
    if (0 == index) {
        [self startConversation:V2TIM_C2C];
    } else {
        [self startConversation:V2TIM_GROUP];
    }
}

- (void)startConversation:(V2TIMConversationType)type {
    __weak typeof(self) weakSelf = self;
    void (^selectContactCompletion)(NSArray<TUICommonContactSelectCellData *> *) = ^(NSArray<TUICommonContactSelectCellData *> *array) {
      if (V2TIM_C2C == type) {
          NSDictionary *param = @{
              TUICore_TUIChatObjectFactory_ChatViewController_Title : array.firstObject.title ?: @"",
              TUICore_TUIChatObjectFactory_ChatViewController_UserID : array.firstObject.identifier ?: @"",
              TUICore_TUIChatObjectFactory_ChatViewController_AvatarImage : array.firstObject.avatarImage ?: [UIImage new],
              TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : array.firstObject.avatarUrl.absoluteString ?: @""
          };
          [weakSelf.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Classic param:param forResult:nil];

          NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
          [tempArray removeObjectAtIndex:tempArray.count - 2];
          weakSelf.navigationController.viewControllers = tempArray;
      } else {
          NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
          [[V2TIMManager sharedInstance]
              getUsersInfo:@[ loginUser ]
                      succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                        NSString *showName = loginUser;
                        if (infoList.firstObject.nickName.length > 0) {
                            showName = infoList.firstObject.nickName;
                        }
                        NSMutableString *groupName = [NSMutableString stringWithString:showName];
                        for (TUICommonContactSelectCellData *item in array) {
                            [groupName appendFormat:@"、%@", item.title];
                        }

                        if ([groupName length] > 10) {
                            groupName = [groupName substringToIndex:10].mutableCopy;
                        }
                        void (^createGroupCompletion)(BOOL, V2TIMGroupInfo *) = ^(BOOL isSuccess, V2TIMGroupInfo *_Nonnull info) {
                          NSDictionary *param = @{
                              TUICore_TUIChatObjectFactory_ChatViewController_Title : info.groupName ?: @"",
                              TUICore_TUIChatObjectFactory_ChatViewController_GroupID : info.groupID ?: @"",
                              TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : info.faceURL ?: @""
                          };
                          [self.navigationController pushViewController:TUICore_TUIChatObjectFactory_ChatViewController_Classic param:param forResult:nil];

                          NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                          for (UIViewController *vc in self.navigationController.viewControllers) {
                              if ([vc isKindOfClass:NSClassFromString(@"TUIGroupCreateController")] ||
                                  [vc isKindOfClass:NSClassFromString(@"TUIContactSelectController")]) {
                                  [tempArray removeObject:vc];
                              }
                          }

                          weakSelf.navigationController.viewControllers = tempArray;
                        };

                        NSDictionary *param = @{
                            TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_TitleKey : array.firstObject.title ?: @"",
                            TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupNameKey : groupName ?: @"",
                            TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_GroupTypeKey : GroupType_Work,
                            TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_CompletionKey : createGroupCompletion,
                            TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod_ContactListKey : array ?: @[]
                        };

                        UIViewController *groupVC = (UIViewController *)[TUICore createObject:TUICore_TUIContactObjectFactory
                                                                                          key:TUICore_TUIContactObjectFactory_GetGroupCreateControllerMethod
                                                                                        param:param];
                        [weakSelf.navigationController pushViewController:(UIViewController *)groupVC animated:YES];
                      }
                      fail:nil];
      }
    };
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_TitleKey : TIMCommonLocalizableString(ChatsSelectContact),
        TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_MaxSelectCount : @(type == V2TIM_C2C ? 1 : INT_MAX),
        TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey : selectContactCompletion
    };
    UIViewController *vc = [TUICore createObject:TUICore_TUIContactObjectFactory
                                             key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
                                           param:param];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark TUIConversationListDataProviderDelegate
- (NSString *)getConversationDisplayString:(V2TIMConversation *)conversation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
        return [self.delegate getConversationDisplayString:conversation];
    }
    V2TIMMessage *msg = conversation.lastMessage;
    if (msg.customElem == nil || msg.customElem.data == nil) {
        return nil;
    }
    NSDictionary *param = [TUITool jsonData2Dictionary:msg.customElem.data];
    if (param != nil && [param isKindOfClass:[NSDictionary class]]) {
        NSString *businessID = param[@"businessID"];
        if (![businessID isKindOfClass:[NSString class]]) {
            return nil;
        }

        // whether custom jump message
        if ([businessID isEqualToString:BussinessID_TextLink] || ([(NSString *)param[@"text"] length] > 0 && [(NSString *)param[@"link"] length] > 0)) {
            NSString *desc = param[@"text"];
            if (msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED) {
                V2TIMUserFullInfo *info = msg.revokerInfo;
                NSString *  revokeReason = msg.revokeReason;
                BOOL hasRiskContent = msg.hasRiskContent;
                if (hasRiskContent) {
                    desc =  TIMCommonLocalizableString(TUIKitMessageTipsRecallRiskContent);
                }
                else if (info) {
                    NSString *userName = info.nickName;
                    desc  = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
                }
                else if (msg.isSelf) {
                    desc = TIMCommonLocalizableString(TUIKitMessageTipsYouRecallMessage);
                } else if (msg.userID.length > 0) {
                    desc = TIMCommonLocalizableString(TUIKitMessageTipsOthersRecallMessage);
                } else if (msg.groupID.length > 0) {
                    /**
                     * For the name display of group messages, the group business card is displayed first, the nickname has the second priority, and the user ID
                     * has the lowest priority.
                     */
                    NSString *userName = msg.nameCard;
                    if (userName.length == 0) {
                        userName = msg.nickName ?: msg.sender;
                    }
                    desc = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitMessageTipsRecallMessageFormat), userName];
                }
            }
            return desc;
        }
    }
    return nil;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end

@interface IUConversationView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUConversationView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
