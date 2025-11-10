//
//  TUIBaseChatViewController.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIBaseChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUITool.h>
#import <TUICore/NSString+TUIUtil.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIAIDenoiseSignatureManager.h"
#import "TUIBaseMessageController.h"
#import "TUICameraViewController.h"
#import "TUIChatConfig.h"
#import "TUIChatDataProvider.h"
#import "TUIChatMediaDataProvider.h"
#import "TUIChatModifyMessageHelper.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIFileMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIJoinGroupMessageCell.h"
#import "TUIMessageController.h"
#import "TUIMessageDataProvider.h"
#import "TUIMessageMultiChooseView.h"
#import "TUIMessageReadViewController.h"
#import "TUIReplyMessageCellData.h"
#import "TUITextMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "TUIChatShortcutMenuView.h"
#import "TUIAIPlaceholderTypingMessageManager.h"

static UIView *gCustomTopView;
static UIView *gTopExentsionView;
static UIView *gGroupPinTopView;
static CGRect gCustomTopViewRect;
@interface TUIBaseChatViewController () <TUIBaseMessageControllerDelegate,
                                         TUIInputControllerDelegate,
                                         UIImagePickerControllerDelegate,
                                         UIDocumentPickerDelegate,
                                         UINavigationControllerDelegate,
                                         TUIMessageMultiChooseViewDelegate,
                                         TUIChatBaseDataProviderDelegate,
                                         TUINotificationProtocol,
                                         TUIJoinGroupMessageCellDelegate,
                                         V2TIMConversationListener,
                                         TUINavigationControllerDelegate,
                                         TUIChatMediaDataListener,
                                         TIMInputViewMoreActionProtocol>

@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) TUIMessageMultiChooseView *multiChooseView;
@property(nonatomic, assign) BOOL responseKeyboard;
@property(nonatomic, assign) BOOL isPageAppears;

@property(nonatomic, strong) TUIChatDataProvider *dataProvider;

@property(nonatomic, assign) BOOL firstAppear;
@property(nonatomic, copy) NSString *mainTitle;

@property(nonatomic, strong) UIImageView *backgroudView;

@property(nonatomic, strong) TUIChatMediaDataProvider *mediaProvider;

// AI interrupt message properties
@property(nonatomic, assign) NSTimeInterval lastSendInterruptMessageTime;
@property(nonatomic, strong) TUIMessageCellData *receivingChatbotMessage;

// HUD properties
@property(nonatomic, strong) UIView *hudContainerView;
@property(nonatomic, strong) UIView *hudBackgroundView;
@property(nonatomic, strong) UILabel *hudLabel;

@end

@implementation TUIBaseChatViewController

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [TUIBaseChatViewController createCachePath];
        [[TUIAIDenoiseSignatureManager sharedInstance] updateSignature];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTopViewsAndMessagePage)
                                                     name:TUICore_TUIChatExtension_ChatViewTopArea_ChangedNotification
                                                   object:nil];
        [TUIChatMediaSendingManager.sharedInstance addCurrentVC:self];

    }
    return self;
}

- (void)setTitle:(NSString *)title {
    self.mainTitle = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTopViews];
    
    // data provider
    self.dataProvider = [[TUIChatDataProvider alloc] init];
    self.dataProvider.delegate = self;

    // setupUI
    self.firstAppear = YES;
    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#FFFFFF");
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configBackgroundView];
    [self setupNavigator];
    [self setupMessageController];
    [self setupInputMoreMenu];
    [self setupInputController];
    [self setupShortcutView];
    
    // reset then setup bottom container and its margin
    NSDictionary *userInfo = @{TUIKitNotification_onMessageVCBottomMarginChanged_Margin: @(0)};
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onMessageVCBottomMarginChanged object:nil userInfo:userInfo];
    [self setupBottomContainerView];

    // Notify
    [self configNotify];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configTopViewsViewWillAppear];
}

- (void)configTopViewsViewWillAppear {
    if (gCustomTopView.superview != self.view) {
        if (CGRectEqualToRect(gCustomTopView.frame, CGRectZero)) {
            gCustomTopView.frame = CGRectMake(0, CGRectGetMaxY(gTopExentsionView.frame), gCustomTopViewRect.size.width, gCustomTopViewRect.size.height);
        }
        [self.view addSubview:gCustomTopView];
    }
    if (gTopExentsionView.superview != self.view) {
        [self.view addSubview:gTopExentsionView];
    }
    if (gGroupPinTopView.superview != self.view && self.conversationData.groupID.length > 0){
        [self.view addSubview:gGroupPinTopView];
    }
    
    [self reloadTopViewsAndMessagePage];
}
- (void)setupTopViews {
    if (gTopExentsionView) {
        [gTopExentsionView removeFromSuperview];
    }
    else {
        gTopExentsionView = [[UIView alloc] init];
        gTopExentsionView.clipsToBounds = YES;
    }
    if (gGroupPinTopView) {
        [gGroupPinTopView removeFromSuperview];
    }
    else {
        gGroupPinTopView = [[UIView alloc] init];
        gGroupPinTopView.clipsToBounds = YES;
    }
    
    if (gTopExentsionView) {
        [self setupTopExentsionView];
    }
    if (gCustomTopView) {
        [self setupCustomTopView];
        gCustomTopView.frame = CGRectMake(0, CGRectGetMaxY(gTopExentsionView.frame), gCustomTopViewRect.size.width, gCustomTopViewRect.size.height);
    }
    if (gGroupPinTopView && self.conversationData.groupID.length > 0) {
        [self setupGroupPinTopView];
        gGroupPinTopView.frame = CGRectMake(0, CGRectGetMaxY(gCustomTopView.frame), gGroupPinTopView.frame.size.width, gGroupPinTopView.frame.size.height);;
    }
}

- (void)reloadTopViewsAndMessagePage {
    gCustomTopView.frame = CGRectMake(0, CGRectGetMaxY(gTopExentsionView.frame), gCustomTopView.frame.size.width, gCustomTopView.frame.size.height);
    if (gGroupPinTopView) {
        gGroupPinTopView.frame = CGRectMake(0, CGRectGetMaxY(gCustomTopView.frame), gGroupPinTopView.frame.size.width, gGroupPinTopView.frame.size.height);;
    }

    CGFloat topMarginByCustomView = [self topMarginByCustomView];
    if (_messageController.view.mm_y != topMarginByCustomView) {
        CGFloat textViewHeight = TUIChatConfig.defaultConfig.enableMainPageInputBar? TTextView_Height:0;
        _messageController.view.frame = CGRectMake(0, topMarginByCustomView, self.view.mm_w,
                                                   self.view.mm_h - textViewHeight - Bottom_SafeHeight - topMarginByCustomView);
        [self.messageController scrollToBottom:YES];
    }
}

- (void)dealloc {
    [TUICore unRegisterEventByObject:self];
    [self hideHud];
}

- (void)appWillResignActive:(NSNotification *)notification {
    [self saveDraft];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self saveDraft];
    }
}

- (void)viewDidLayoutSubviews {
    [self layoutBottomContanerView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.responseKeyboard = YES;
    self.isPageAppears = YES;
    if (self.firstAppear) {
        [self loadDraft];
        self.firstAppear = NO;
    }

    if (self.needScrollToBottom) {
        [self.messageController scrollToBottom:YES];
        self.needScrollToBottom = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.responseKeyboard = NO;
    self.isPageAppears = NO;

    [self openMultiChooseBoard:NO];
    [self.messageController enableMultiSelectedMode:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (_conversationData.isLimitedPortraitOrientation) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

- (void)setupNavigator {
    TUINavigationController *naviController = (TUINavigationController *)self.navigationController;
    if ([naviController isKindOfClass:TUINavigationController.class]) {
        naviController.uiNaviDelegate = self;
        UIImage *backimg = TIMCommonDynamicImage(@"nav_back_img", [UIImage imageNamed:TIMCommonImagePath(@"nav_back")]);
        backimg = [backimg rtl_imageFlippedForRightToLeftLayoutDirection];
        naviController.navigationItemBackArrowImage =  backimg;
    }
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    __weak typeof(self) weakSelf = self;
    [[RACObserve(_conversationData, title) distinctUntilChanged] subscribeNext:^(NSString *title) {
      [weakSelf.titleView setTitle:title];
    }];

    [[RACObserve(_conversationData, otherSideTyping) distinctUntilChanged] subscribeNext:^(id otherSideTyping) {
      BOOL otherSideTypingFlag = [otherSideTyping boolValue];
      if (!otherSideTypingFlag) {
          [weakSelf checkTitle:YES];
      }
      else {
          NSString *typingText = [NSString stringWithFormat:@"%@...", TIMCommonLocalizableString(TUIKitTyping)];
          [weakSelf.titleView setTitle:typingText];
      }
    }];

    [self checkTitle:NO];

    [TUIChatDataProvider
        getTotalUnreadMessageCountWithSuccBlock:^(UInt64 totalCount) {
          [weakSelf onChangeUnReadCount:totalCount];
        }
                                           fail:nil];

    _unRead = [[TUIUnReadView alloc] init];

    CGSize itemSize = CGSizeMake(25, 25);
    NSMutableArray *rightBarButtonList = [NSMutableArray array];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if ([self.conversationData isAIConversation]) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
        [button setImage:TUIChatBundleThemeImage(@"chat_ai_clear_icon_img",@"chat_ai_clear_icon")
                forState:UIControlStateNormal];
        [button.widthAnchor constraintEqualToConstant:itemSize.width].active = YES;
        [button.heightAnchor constraintEqualToConstant:itemSize.height].active = YES;
        [button addTarget:self action:@selector(rightBarAIClearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItems = @[rightItem];
        return;
    }
    
    if (self.conversationData.userID.length > 0) {
        param[TUICore_TUIChatExtension_NavigationMoreItem_UserID] = self.conversationData.userID;
    } else if (self.conversationData.groupID.length > 0) {
        param[TUICore_TUIChatExtension_NavigationMoreItem_GroupID] = self.conversationData.groupID;
    }
    param[TUICore_TUIChatExtension_NavigationMoreItem_ItemSize] = NSStringFromCGSize(itemSize);
    param[TUICore_TUIChatExtension_NavigationMoreItem_FilterVideoCall] = @(!TUIChatConfig.defaultConfig.enableVideoCall);
    param[TUICore_TUIChatExtension_NavigationMoreItem_FilterAudioCall] = @(!TUIChatConfig.defaultConfig.enableAudioCall);
    NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID param:param];
    TUIExtensionInfo *maxWeightInfo = [TUIExtensionInfo new];
    maxWeightInfo.weight = INT_MIN;
    for (TUIExtensionInfo *info in extensionList) {
        if (maxWeightInfo.weight < info.weight) {
            maxWeightInfo = info;
        }
    }
    if (maxWeightInfo == nil) {
        return;
    }
    if (maxWeightInfo.icon && maxWeightInfo.onClicked) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
        [button.widthAnchor constraintEqualToConstant:itemSize.width].active = YES;
        [button.heightAnchor constraintEqualToConstant:itemSize.height].active = YES;
        button.tui_extValueObj = maxWeightInfo;
        [button addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:maxWeightInfo.icon forState:UIControlStateNormal];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        [rightBarButtonList addObject:rightItem];
    }
    if (rightBarButtonList.count > 0) {
        self.navigationItem.rightBarButtonItems = rightBarButtonList.reverseObjectEnumerator.allObjects;
    }
}

- (void)setupMessageController {
    TUIMessageController *vc = [[TUIMessageController alloc] init];
    vc.hightlightKeyword = self.highlightKeyword;
    vc.locateMessage = self.locateMessage;
    vc.isMsgNeedReadReceipt = self.conversationData.msgNeedReadReceipt && [TUIChatConfig defaultConfig].msgNeedReadReceipt;
    _messageController = vc;
    _messageController.delegate = self;
    [_messageController setConversation:self.conversationData];
    
    CGFloat textViewHeight = TUIChatConfig.defaultConfig.enableMainPageInputBar? TTextView_Height:0;
    _messageController.view.frame = CGRectMake(0, [self topMarginByCustomView], self.view.frame.size.width,
                                               self.view.frame.size.height - textViewHeight - Bottom_SafeHeight - [self topMarginByCustomView]);
    [self addChildViewController:_messageController];
    [self.view addSubview:_messageController.view];
    [_messageController didMoveToParentViewController:self];
}

- (void)setupTopExentsionView {
    if (gTopExentsionView.superview != self.view) {
        [self.view addSubview:gTopExentsionView];
    }
    gTopExentsionView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (self.conversationData.userID.length > 0) {
        param[TUICore_TUIChatExtension_ChatViewTopArea_ChatID] = self.conversationData.userID;
        param[TUICore_TUIChatExtension_ChatViewTopArea_IsGroup] = @"0";
    } else if (self.conversationData.groupID.length > 0) {
        param[TUICore_TUIChatExtension_ChatViewTopArea_IsGroup] = @"1";
        param[TUICore_TUIChatExtension_ChatViewTopArea_ChatID] = self.conversationData.groupID;
    }
    [TUICore raiseExtension:TUICore_TUIChatExtension_ChatViewTopArea_ClassicExtensionID parentView:gTopExentsionView param:param];

}

- (void)setupGroupPinTopView {
    if (gGroupPinTopView.superview != self.view) {
        [self.view addSubview:gGroupPinTopView];
    }
    gGroupPinTopView.backgroundColor = [UIColor clearColor];
    gGroupPinTopView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
    
}

- (void)setupCustomTopView {
    if (gCustomTopView.superview != self.view) {
        [self.view addSubview:gCustomTopView];
    }
}

- (void)setupBottomContainerView {
    [self.view addSubview:self.bottomContainerView];
    
    NSArray *shortcutMenuItems = self.conversationData.shortcutMenuItems;
    CGFloat viewHeight = self.conversationData.shortcutViewHeight;
    if (shortcutMenuItems.count > 0) {
        TUIChatShortcutMenuView *view = [[TUIChatShortcutMenuView alloc] initWithDataSource:shortcutMenuItems];
        view.viewHeight = viewHeight;
        view.itemHorizontalSpacing = 0.0;
        if (self.conversationData.shortcutViewBackgroundColor != nil) {
            view.backgroundColor = self.conversationData.shortcutViewBackgroundColor;
        }
        [self.bottomContainerView addSubview:view];
        [view updateFrame];
    } else {
        [self notifyBttomContainerReady];
    }
}

- (void)layoutBottomContanerView {
    if (self.bottomContainerView.mm_y == self.messageController.view.mm_maxY) {
        return;
    }
    if (self.conversationData.shortcutMenuItems.count > 0) {
        CGFloat height = self.conversationData.shortcutViewHeight > 0 ? self.conversationData.shortcutViewHeight : 46;
        self.messageController.view.mm_h = self.messageController.view.mm_h - height;
        self.bottomContainerView.frame = CGRectMake(0, self.messageController.view.mm_maxY,
                                                    self.messageController.view.mm_w, height);
    }
}

- (void)setupInputController {

    _inputController = [[TUIInputController alloc] init];
    _inputController.delegate = self;
    
    @weakify(self);
    [RACObserve(self, moreMenus) subscribeNext:^(NSArray *x) {
      @strongify(self);
      [self.inputController.moreView setData:x];
    }];
    _inputController.view.frame =
        CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addChildViewController:_inputController];
    [self.view addSubview:_inputController.view];

    // AI style example - AI chat style can be enabled as needed
    // For example: Enable when the conversation ID contains "AI" or is a specific AI bot
    BOOL isAIConversation = [self.conversationData isAIConversation];
    if (isAIConversation) {
        [_inputController enableAIStyle:YES];
        NSString *conversationID = self.conversationData.conversationID;
        TUIMessageCellData *currentAITypingMessage = [[TUIAIPlaceholderTypingMessageManager sharedInstance]
                                                      getAIPlaceholderTypingMessageForConversation:conversationID];
        if (currentAITypingMessage) {
            [self setAIStartTyping];
        }
        __weak typeof(self) weakSelf = self;
        self.messageController.steamCellFinishedBlock = ^(BOOL finished, TUIMessageCellData * _Nonnull cellData) {
            if (!finished) {
                [weakSelf setAIStartTyping];
                weakSelf.receivingChatbotMessage = cellData;
            }
            else {
                [weakSelf setAIFinishTyping];
            }
        };
    }
    
    _inputController.view.hidden = !TUIChatConfig.defaultConfig.enableMainPageInputBar;

    self.moreMenus = [self.dataProvider getMoreMenuCellDataArray:self.conversationData.groupID
                                                          userID:self.conversationData.userID
                                               conversationModel:self.conversationData
                                                actionController:self];
}

- (void)setupShortcutView {
    id<TUIChatShortcutViewDataSource> dataSource = [TUIChatConfig defaultConfig].shortcutViewDataSource;
    if (dataSource && [dataSource respondsToSelector:@selector(itemsInShortcutViewOfModel:)]) {
        NSArray *items = [dataSource itemsInShortcutViewOfModel:self.conversationData];
        if (items.count > 0) {
            self.conversationData.shortcutMenuItems = items;
            if (dataSource && [dataSource respondsToSelector:@selector(shortcutViewBackgroundColorOfModel:)]) {
                UIColor *backgroundColor = [dataSource shortcutViewBackgroundColorOfModel:self.conversationData];
                self.conversationData.shortcutViewBackgroundColor = backgroundColor;
            }
            if (dataSource && [dataSource respondsToSelector:@selector(shortcutViewHeightOfModel:)]) {
                CGFloat height = [dataSource shortcutViewHeightOfModel:self.conversationData];
                self.conversationData.shortcutViewHeight = height;
            }
        }
    }
}

- (void)setupInputMoreMenu {
    id<TUIChatInputBarConfigDataSource> dataSource = [TUIChatConfig defaultConfig].inputBarDataSource;
    if (dataSource && [dataSource respondsToSelector:@selector(inputBarShouldHideItemsInMoreMenuOfModel:)]) {
        TUIChatInputBarMoreMenuItem tag = [dataSource inputBarShouldHideItemsInMoreMenuOfModel:self.conversationData];
        self.conversationData.enableFile = !(tag & TUIChatInputBarMoreMenuItem_File);
        self.conversationData.enablePoll = !(tag & TUIChatInputBarMoreMenuItem_Poll);
        self.conversationData.enableRoom = !(tag & TUIChatInputBarMoreMenuItem_Room);
        self.conversationData.enableAlbum = !(tag & TUIChatInputBarMoreMenuItem_Album);
        self.conversationData.enableAudioCall = !(tag & TUIChatInputBarMoreMenuItem_AudioCall);
        self.conversationData.enableVideoCall = !(tag & TUIChatInputBarMoreMenuItem_VideoCall);
        self.conversationData.enableGroupNote = !(tag & TUIChatInputBarMoreMenuItem_GroupNote);
        self.conversationData.enableTakePhoto = !(tag & TUIChatInputBarMoreMenuItem_TakePhoto);
        self.conversationData.enableRecordVideo = !(tag & TUIChatInputBarMoreMenuItem_RecordVideo);
        self.conversationData.enableWelcomeCustomMessage = !(tag & TUIChatInputBarMoreMenuItem_CustomMessage);
    }
    if (dataSource && [dataSource respondsToSelector:@selector(inputBarShouldAddNewItemsToMoreMenuOfModel:)]) {
        NSArray *items = [dataSource inputBarShouldAddNewItemsToMoreMenuOfModel:self.conversationData];
        if ([items isKindOfClass:NSArray.class]) {
            self.conversationData.customizedNewItemsInMoreMenu = items;
        }
    }
}

- (void)configBackgroundView {
    self.backgroudView = [[UIImageView alloc] init];
    self.backgroudView.backgroundColor =
        TUIChatConfig.defaultConfig.backgroudColor ? TUIChatConfig.defaultConfig.backgroudColor : TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    NSString *conversationID = [self getConversationID];
    NSString *imgUrl = [self getBackgroundImageUrlByConversationID:conversationID];

    if (TUIChatConfig.defaultConfig.backgroudImage) {
        self.backgroudView.backgroundColor = UIColor.clearColor;
        self.backgroudView.image = TUIChatConfig.defaultConfig.backgroudImage;
    } else if (IS_NOT_EMPTY_NSSTRING(imgUrl)) {
        [self.backgroudView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil];
    }
    CGFloat textViewHeight = TUIChatConfig.defaultConfig.enableMainPageInputBar? TTextView_Height:0;

    self.backgroudView.frame =
        CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - textViewHeight - Bottom_SafeHeight);

    [self.view insertSubview:self.backgroudView atIndex:0];
}

- (void)configNotify {
    [[V2TIMManager sharedInstance] addConversationListener:self];
    [TUICore registerEvent:TUICore_TUIConversationNotify subKey:TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [TUICore registerEvent:TUICore_TUIContactNotify subKey:TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey object:self];
    [TUICore registerEvent:TUICore_TUIChatNotify subKey:TUICore_TUIChatNotify_SendMessageSubKey object:self];

}

#pragma mark - Extension
- (void)notifyBttomContainerReady {
    [TUICore registerEvent:TUICore_TUIPluginNotify
                    subKey:TUICore_TUIPluginNotify_PluginViewDidAddToSuperview
                    object:self];
    [TUICore raiseExtension:TUICore_TUIChatExtension_ChatVCBottomContainer_ClassicExtensionID
                 parentView:self.bottomContainerView
                      param:@{TUICore_TUIChatExtension_ChatVCBottomContainer_UserID: self.conversationData.userID ? : @"",
                              TUICore_TUIChatExtension_ChatVCBottomContainer_VC: self}];
}

- (UIView *)bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
    }
    return _bottomContainerView;
}

#pragma mark - Public Methods

- (void)sendMessage:(V2TIMMessage *)message {
    [self.messageController sendMessage:message];
}
- (void)sendMessage:(V2TIMMessage *)message placeHolderCellData:(TUIMessageCellData *)placeHolderCellData {
    [self.messageController sendMessage:message placeHolderCellData:placeHolderCellData];
}

- (void)saveDraft {
    NSString *content = [self.inputController.inputBar.inputTextView.textStorage tui_getPlainString];

    TUIReplyPreviewData *previewData = nil;
    if (self.inputController.referenceData) {
        previewData = self.inputController.referenceData;
    } else if (self.inputController.replyData) {
        previewData = self.inputController.replyData;
    }
    if (previewData) {
        NSDictionary *dict = @{
            @"content" : content ?: @"",
            @"messageReply" : @{
                @"messageID" : previewData.msgID ?: @"",
                @"messageAbstract" : [previewData.msgAbstract ?: @"" getInternationalStringWithfaceContent],
                @"messageSender" : previewData.sender ?: @"",
                @"messageType" : @(previewData.type),
                @"messageTime" :
                    @(previewData.originMessage.timestamp ? [previewData.originMessage.timestamp timeIntervalSince1970] : 0),  // Compatible for web
                @"messageSequence" : @(previewData.originMessage.seq),                                                         // Compatible for web
                @"version" : @(kDraftMessageReplyVersion),
            },
        };
        NSMutableDictionary *mudic = [NSMutableDictionary dictionaryWithDictionary:dict];

        if (IS_NOT_EMPTY_NSSTRING(previewData.messageRootID)) {
            [mudic setObject:previewData.messageRootID forKey:@"messageRootID"];
        }
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:mudic options:0 error:&error];
        if (error == nil) {
            content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    [TUIChatDataProvider saveDraftWithConversationID:self.conversationData.conversationID Text:content];
}

- (void)loadDraft {
    
    NSString *draft = self.conversationData.draftText;
    if (draft.length == 0) {
        return;
    }

    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[draft dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error || jsonDict == nil) {
        NSMutableAttributedString *formatEmojiString = [draft getAdvancedFormatEmojiStringWithFont:kTUIInputNoramlFont
                                                                                         textColor:kTUIInputNormalTextColor
                                                                                    emojiLocations:nil];

        [self.inputController.inputBar addDraftToInputBar:formatEmojiString];
        return;
    }

    /**
     * 
     * Display draft
     */
    NSString *draftContent = [jsonDict.allKeys containsObject:@"content"] ? jsonDict[@"content"] : @"";

    NSMutableAttributedString *formatEmojiString = [draftContent getAdvancedFormatEmojiStringWithFont:kTUIInputNoramlFont
                                                                                            textColor:kTUIInputNormalTextColor
                                                                                       emojiLocations:nil];

    [self.inputController.inputBar addDraftToInputBar:formatEmojiString];

    NSString *messageRootID = [jsonDict.allKeys containsObject:@"messageRootID"] ? jsonDict[@"messageRootID"] : @"";

    /**
     * 
     * Display message reply preview bar
     */
    if ([jsonDict isKindOfClass:NSDictionary.class] && [jsonDict.allKeys containsObject:@"messageReply"]) {
        NSDictionary *reply = jsonDict[@"messageReply"];
        if ([reply isKindOfClass:NSDictionary.class] && [reply.allKeys containsObject:@"messageID"] && [reply.allKeys containsObject:@"messageAbstract"] &&
            [reply.allKeys containsObject:@"messageSender"] && [reply.allKeys containsObject:@"messageType"] && [reply.allKeys containsObject:@"version"]) {
            NSInteger version = [reply[@"version"] integerValue];
            if (version <= kDraftMessageReplyVersion) {
                if (IS_NOT_EMPTY_NSSTRING(messageRootID)) {
                    TUIReplyPreviewData *replyData = [[TUIReplyPreviewData alloc] init];
                    replyData.msgID = reply[@"messageID"];
                    replyData.msgAbstract = reply[@"messageAbstract"];
                    replyData.sender = reply[@"messageSender"];
                    replyData.type = [reply[@"messageType"] integerValue];
                    replyData.messageRootID = messageRootID;
                    [self.inputController showReplyPreview:replyData];
                } else {
                    TUIReferencePreviewData *replyData = [[TUIReferencePreviewData alloc] init];
                    replyData.msgID = reply[@"messageID"];
                    replyData.msgAbstract = reply[@"messageAbstract"];
                    replyData.sender = reply[@"messageSender"];
                    replyData.type = [reply[@"messageType"] integerValue];
                    [self.inputController showReferencePreview:replyData];
                }
            }
        }
    }
}

+ (void)setCustomTopView:(UIView *)view {
    gCustomTopView = view;
    gCustomTopViewRect = view.frame;
    gCustomTopView.clipsToBounds = YES;
}

+ (UIView *)customTopView {
    return gCustomTopView;
}
+ (UIView *)groupPinTopView {
    return gGroupPinTopView;
}
+ (UIView *)topAreaBottomView {
    if (gGroupPinTopView) {
        return gGroupPinTopView;
    }
    if (gCustomTopView) {
        return gCustomTopView;
    }
    if (gTopExentsionView) {
        return gTopExentsionView;
    }
    return nil;
}

#pragma mark - Getters & Setters

- (void)setConversationData:(TUIChatConversationModel *)conversationData {
    _conversationData = conversationData;

    //  conversationData
    NSDictionary *param = @{TUICore_TUIChatExtension_GetChatConversationModelParams_UserID: self.conversationData.userID ? : @""};
    NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:TUICore_TUIChatExtension_GetChatConversationModelParams param:param];
    TUIExtensionInfo *extention = extensionList.firstObject;
    if (extention) {
        _conversationData.msgNeedReadReceipt = [extention.data[TUICore_TUIChatExtension_GetChatConversationModelParams_MsgNeedReadReceipt] boolValue];
        _conversationData.enableVideoCall = [extention.data[TUICore_TUIChatExtension_GetChatConversationModelParams_EnableVideoCall] boolValue];
        _conversationData.enableAudioCall = [extention.data[TUICore_TUIChatExtension_GetChatConversationModelParams_EnableAudioCall] boolValue];
        _conversationData.enableWelcomeCustomMessage =
            [extention.data[TUICore_TUIChatExtension_GetChatConversationModelParams_EnableWelcomeCustomMessage] boolValue];
    }
}

- (CGFloat)topMarginByCustomView {
    CGFloat gCutomTopViewH = gCustomTopView && gCustomTopView.superview ? gCustomTopView.mm_h : 0 ;
    CGFloat gTopExtsionH = gTopExentsionView && gTopExentsionView.superview ? gTopExentsionView.mm_h : 0;
    CGFloat gGroupPinTopViewH = gGroupPinTopView && gGroupPinTopView.superview ? gGroupPinTopView.mm_h : 0;

    CGFloat height = gCutomTopViewH + gTopExtsionH + gGroupPinTopViewH;
    return height;
}

#pragma mark - Event Response
- (void)onChangeUnReadCount:(UInt64)totalCount {
    /**
     * The reason for the asynchrony here: The current chat page receives messages continuously and frequently, it may not be marked as read, and unread changes
     * will also be received at this time. In theory, the unreads at this time will not include the current session.
     */
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf.unRead setNum:totalCount];
    });
}

- (void)checkTitle:(BOOL)force {
    if (force || self.conversationData.title.length == 0) {
        if (self.conversationData.userID.length > 0) {
            self.conversationData.title = self.conversationData.userID;
            @weakify(self);

            [TUIChatDataProvider getFriendInfoWithUserId:self.conversationData.userID
                                               SuccBlock:^(V2TIMFriendInfoResult *_Nonnull friendInfoResult) {
                                                 @strongify(self);
                                                 if (friendInfoResult.relation & V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST &&
                                                     friendInfoResult.friendInfo.friendRemark.length > 0) {
                                                     self.conversationData.title = friendInfoResult.friendInfo.friendRemark;
                                                 } else {
                                                     [TUIChatDataProvider getUserInfoWithUserId:self.conversationData.userID
                                                                                      SuccBlock:^(V2TIMUserFullInfo *_Nonnull userInfo) {
                                                                                        if (userInfo.nickName.length > 0) {
                                                                                            self.conversationData.title = userInfo.nickName;
                                                                                        }
                                                                                      }
                                                                                      failBlock:nil];
                                                 }
                                               }
                                               failBlock:nil];
        } else if (self.conversationData.groupID.length > 0) {
            [TUIChatDataProvider getGroupInfoWithGroupID:self.conversationData.groupID
                                               SuccBlock:^(V2TIMGroupInfoResult *_Nonnull groupResult) {
                                                 if (groupResult.info.groupName.length > 0 &&
                                                     self.conversationData.enableRoom) {
                                                     self.conversationData.title = groupResult.info.groupName;
                                                 }
                                                 if ([groupResult.info.groupType isEqualToString:@"Room"] ) {
                                                     self.navigationItem.rightBarButtonItems = nil;
                                                 }
                                               }
                                               failBlock:nil];
        }
    }
}

- (void)leftBarButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonClick:(UIButton *)button {
    [self.inputController reset];

    TUIExtensionInfo *info = button.tui_extValueObj;
    if (info == nil || ![info isKindOfClass:TUIExtensionInfo.class] || info.onClicked == nil) {
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (self.conversationData.userID.length > 0) {
        param[TUICore_TUIChatExtension_NavigationMoreItem_UserID] = self.conversationData.userID;
    } else if (self.conversationData.groupID.length > 0) {
        param[TUICore_TUIChatExtension_NavigationMoreItem_GroupID] = self.conversationData.groupID;
    }

    if (self.navigationController) {
        param[TUICore_TUIChatExtension_NavigationMoreItem_PushVC] = self.navigationController;
    }
    info.onClicked(param);
}

- (void)rightBarAIClearButtonClick:(UIButton *)button {
    [self.inputController reset];
    if (self.inputController.inputBar.aiIsTyping) {
        [self showHudMsgText:TIMCommonLocalizableString(TUIKitAITyping)];
        return;
    }
    if (IS_NOT_EMPTY_NSSTRING(self.conversationData.userID)) {
        NSString *userID = self.conversationData.userID;
        @weakify(self);
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                    message:TIMCommonLocalizableString(TUIKitClearAllChatHistoryTips)
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        @strongify(self);
                                                        [V2TIMManager.sharedInstance clearC2CHistoryMessage:userID
                                                            succ:^{
                                                              [TUICore notifyEvent:TUICore_TUIConversationNotify
                                                                            subKey:TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey
                                                                            object:self
                                                                             param:nil];
                                                              [TUITool makeToast:TIMCommonLocalizableString(Done)];
                                                            }
                                                            fail:^(int code, NSString *desc) {
                                                              [TUITool makeToastError:code msg:desc];
                                                            }];
                                                      }]];
        [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)getUserOrFriendProfileVCWithUserID:(NSString *)userID succBlock:(void (^)(UIViewController *vc))succ failBlock:(nullable V2TIMFail)fail {
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ ? : ^(UIViewController *vc){},
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail ? : ^(int code, NSString * desc){}
    };
    [TUICore createObject:TUICore_TUIContactObjectFactory key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];
}

#pragma mark - TUICore notify

- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIConversationNotify] && [subKey isEqualToString:TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey]) {
        [self.messageController clearUImsg];
    } else if ([key isEqualToString:TUICore_TUIContactNotify] && [subKey isEqualToString:TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey]) {
        NSString *conversationID = param[TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey_ConversationID];
        if (IS_NOT_EMPTY_NSSTRING(conversationID)) {
            [self updateBackgroundImageUrlByConversationID:conversationID];
        }
    } else if ([key isEqualToString:TUICore_TUIPluginNotify] && [subKey isEqualToString:TUICore_TUIPluginNotify_PluginViewDidAddToSuperview]) {
        float height = [param[TUICore_TUIPluginNotify_PluginViewDidAddToSuperviewSubKey_PluginViewHeight] floatValue];
        
        self.messageController.view.frame = CGRectMake(0, [self topMarginByCustomView],
                                                       self.view.frame.size.width, self.messageController.view.mm_h - height);
        [self.messageController.view setNeedsLayout];
        [self.messageController.view layoutIfNeeded];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bottomContainerView.frame = CGRectMake(0, self.messageController.view.mm_maxY,
                                                        self.messageController.view.mm_w, height);
        });
        
        NSDictionary *userInfo = @{TUIKitNotification_onMessageVCBottomMarginChanged_Margin: @(height)};
        [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onMessageVCBottomMarginChanged object:nil userInfo:userInfo];
    } else if ([key isEqualToString:TUICore_TUIChatNotify] && [subKey isEqualToString:TUICore_TUIChatNotify_SendMessageSubKey]) {
        int code = [param[TUICore_TUIChatNotify_SendMessageSubKey_Code] intValue];
        NSString *desc = param[TUICore_TUIChatNotify_SendMessageSubKey_Desc];
        BOOL isAIConversation = [self.conversationData isAIConversation];
        if (code == 0) {
            if (isAIConversation) {
                // Create AI placeholder message immediately when user sends message
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.messageController createAITypingMessage];
                });
            }
        }

    }
}

- (void)updateBackgroundImageUrlByConversationID:(NSString *)conversationID {
    if ([[self getConversationID] isEqualToString:conversationID]) {
        self.backgroudView.backgroundColor = UIColor.clearColor;
        NSString *imgUrl = [self getBackgroundImageUrlByConversationID:conversationID];
        if (IS_NOT_EMPTY_NSSTRING(imgUrl)) {
            [self.backgroudView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil];
        } else {
            self.backgroudView.image = nil;
        }
    }
}

- (NSString *)getBackgroundImageUrlByConversationID:(NSString *)targerConversationID {
    if (targerConversationID.length == 0) {
        return nil;
    }
    NSDictionary *dict = [NSUserDefaults.standardUserDefaults objectForKey:@"conversation_backgroundImage_map"];
    if (dict == nil) {
        dict = @{};
    }
    NSString *conversationID_UserID = [NSString stringWithFormat:@"%@_%@", targerConversationID, [TUILogin getUserID]];
    if (![dict isKindOfClass:NSDictionary.class] || ![dict.allKeys containsObject:conversationID_UserID]) {
        return nil;
    }
    return [dict objectForKey:conversationID_UserID];
}

- (NSString *)getConversationID {
    NSString *conversationID = @"";
    if (self.conversationData.conversationID.length > 0) {
        conversationID = self.conversationData.conversationID;
    } else if (self.conversationData.userID.length > 0) {
        conversationID = [NSString stringWithFormat:@"c2c_%@", self.conversationData.userID];
    } else if (self.conversationData.groupID.length > 0) {
        conversationID = [NSString stringWithFormat:@"group_%@", self.conversationData.groupID];
    }
    return conversationID;
}

#pragma mark - TUIInputControllerDelegate
- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height {
    if (!self.responseKeyboard) {
        return;
    }
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        CGRect msgFrame = self.messageController.view.frame;
        CGFloat calHeight = self.view.frame.size.height - height - [self topMarginByCustomView] - self.bottomContainerView.mm_h;
        msgFrame.size.height = MAX(0, calHeight);
        self.messageController.view.frame = msgFrame;
        
        if (self.bottomContainerView.mm_h > 0) {
            CGRect containerFrame = self.bottomContainerView.frame;
            containerFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
            self.bottomContainerView.frame = containerFrame;
            
            CGRect inputFrame = self.inputController.view.frame;
            inputFrame.origin.y = self.bottomContainerView.mm_maxY;
            inputFrame.size.height = height;
            self.inputController.view.frame = inputFrame;
        } else {
            CGRect inputFrame = self.inputController.view.frame;
            inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
            inputFrame.size.height = height;
            self.inputController.view.frame = inputFrame;
        }

        [self.messageController scrollToBottom:NO];
    }
                     completion:nil];
}

- (void)inputController:(TUIInputController *)inputController didSendMessage:(V2TIMMessage *)msg {
    
    BOOL isAIConversation = [self.conversationData isAIConversation];
    
    if (isAIConversation) {
        if (self.inputController.inputBar.aiIsTyping) {
            [self showHudMsgText:TIMCommonLocalizableString(TUIKitAITyping)];
            return;
        }
        [self.inputController setAITyping:YES];
        [self.messageController sendMessage:msg];
    }
    else {
        [self.messageController sendMessage:msg];
    }
}

- (void)inputControllerDidInputAt:(TUIInputController *)inputController {
    /**
     * Handle to GroupChatVC
     */
}

- (void)inputController:(TUIInputController *)inputController didDeleteAt:(NSString *)atText {
    /**
     * Handle to GroupChatVC
     */
}

- (void)inputControllerBeginTyping:(TUIInputController *)inputController {
    // for C2CChatVC
}

- (void)inputControllerEndTyping:(TUIInputController *)inputController {
    // for C2CChatVC
}

- (BOOL)currentUserIsSuperOwnerInGroup {
    //for GroupChatVC
    return NO;
}
- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell {
    cell.disableDefaultSelectAction = NO;
    if (cell.disableDefaultSelectAction) {
        return;
    }
    TUIInputMoreCellData *data = cell.data;
    if (data == nil || data.onClicked == nil) {
        return;
    }

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (self.conversationData.userID.length > 0) {
        param[TUICore_TUIChatExtension_InputViewMoreItem_UserID] = self.conversationData.userID;
    } else if (self.conversationData.groupID.length > 0) {
        param[TUICore_TUIChatExtension_InputViewMoreItem_GroupID] = self.conversationData.groupID;
    }
    if (self.navigationController) {
        param[TUICore_TUIChatExtension_InputViewMoreItem_PushVC] = self.navigationController;
        param[TUICore_TUIChatExtension_InputViewMoreItem_VC] = self;
    }
    data.onClicked(param);
}

- (void)inputControllerDidClickMore:(TUIInputController *)inputController {
    self.moreMenus = [self.dataProvider getMoreMenuCellDataArray:self.conversationData.groupID
                                                          userID:self.conversationData.userID
                                               conversationModel:self.conversationData
                                                actionController:self];
}



- (NSString *)generateMessageKey:(TUIMessageCellData *)messageData {
    if (!messageData || !messageData.innerMessage) {
        return @"";
    }
    
    V2TIMMessage *message = messageData.innerMessage;
    uint64_t msgSeq = message.seq;
    uint64_t random = message.random;
    NSTimeInterval timestamp = message.timestamp ? [message.timestamp timeIntervalSince1970] : 0;
    
    return [NSString stringWithFormat:@"%llu_%llu_%.0f", msgSeq, random, timestamp];
}

- (V2TIMMessage *)buildChatbotInterruptMessage:(TUIMessageCellData *)messageData {
    if (!messageData || !messageData.innerMessage) {
        return nil;
    }
    
    // Build interrupt message content
    NSDictionary *interruptMessageContent = @{
        @"chatbotPlugin": @(2),
        @"src": @(22),
        @"msgKey": [self generateMessageKey:messageData]
    };
    
    // Convert to JSON
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:interruptMessageContent
                                                       options:0
                                                         error:&error];
    if (error || !jsonData) {
        NSLog(@"Failed to create interrupt message JSON: %@", error.localizedDescription);
        return nil;
    }
    
    // Create custom message
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createCustomMessage:jsonData];
    message.isExcludedFromLastMessage = YES;
    message.isExcludedFromUnreadCount = YES;
    return message;
}

- (void)sendChatbotInterruptMessage {
    // Check send interval (1 second minimum)
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    const NSTimeInterval sendInterruputMessageInterval = 1.0;
    
    if (self.lastSendInterruptMessageTime != 0 &&
        currentTime - self.lastSendInterruptMessageTime < sendInterruputMessageInterval) {
        return;
    }
    
    self.lastSendInterruptMessageTime = currentTime;
    
    TUIMessageCellData *messageData = self.receivingChatbotMessage;
    if (!messageData) {
        NSLog(@"No receiving chatbot message found");
        return;
    }
    
    V2TIMMessage *message = [self buildChatbotInterruptMessage:messageData];
    if (!message) {
        NSLog(@"Failed to build interrupt message");
        return;
    }
    
    // Determine conversation type
    NSString *groupID = nil;
    NSString *userID = nil;
    
    if (self.conversationData.groupID.length > 0) {
        groupID = self.conversationData.groupID;
    } else {
        userID = self.conversationData.userID;
    }
    
    __weak typeof(self) weakSelf = self;

    // Send interrupt message
    [[V2TIMManager sharedInstance] sendMessage:message
                                      receiver:userID
                                       groupID:groupID
                                      priority:V2TIM_PRIORITY_DEFAULT
                                onlineUserOnly:YES
                               offlinePushInfo:nil
                                      progress:nil
                                          succ:^{
                                              NSLog(@"sendChatbotInterruptMessage success");
                                          }
                                          fail:^(int code, NSString *desc) {
                                              NSLog(@"sendChatbotInterruptMessage failed %d %@", code, desc);
                                          }];
}

- (void)inputControllerDidTouchAIInterrupt:(TUIInputController *)inputController {
    NSLog(@"inputControllerDidTouchAIInterrupt");
    if (!self.receivingChatbotMessage) {
        NSLog(@"self.receivingChatbotMessage empty");
        return;
    }
    // Send interrupt message
    [self sendChatbotInterruptMessage];
    
}

- (void)setAIStartTyping {
    if ([self.conversationData  isAIConversation]) {
        [_inputController setAITyping:YES];
    }
}

- (void)setAIFinishTyping {
    if ([self.conversationData  isAIConversation]) {
        [_inputController setAITyping:NO];
    }
}

#pragma mark - TUIBaseMessageControllerDelegate
- (void)didTapInMessageController:(TUIBaseMessageController *)controller {
    [self.inputController reset];
}

- (BOOL)messageController:(TUIBaseMessageController *)controller willShowMenuInCell:(TUIMessageCell *)cell {
    if ([self.inputController.inputBar.inputTextView isFirstResponder]) {
        self.inputController.inputBar.inputTextView.overrideNextResponder = cell;
        return YES;
    }
    return NO;
}

- (TUIMessageCellData *)messageController:(TUIBaseMessageController *)controller onNewMessage:(V2TIMMessage *)message {
    return nil;
}

- (TUIMessageCell *)messageController:(TUIBaseMessageController *)controller onShowMessageData:(TUIMessageCellData *)data {
    return nil;
}

- (void)messageController:(TUIBaseMessageController *)controller willDisplayCell:(TUIMessageCell *)cell withData:(TUIMessageCellData *)cellData {
    if ([cell isKindOfClass:[TUIJoinGroupMessageCell class]]) {
        TUIJoinGroupMessageCell *joinCell = (TUIJoinGroupMessageCell *)cell;
        joinCell.joinGroupDelegate = self;
    }
}

- (void)messageController:(TUIBaseMessageController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell {
    NSString *userID = nil;
    if (cell.messageData.innerMessage.groupID.length > 0) {
        userID = cell.messageData.innerMessage.sender;
    } else {
        if (cell.messageData.isUseMsgReceiverAvatar) {
            if (cell.messageData.innerMessage.isSelf) {
                userID = cell.messageData.innerMessage.userID;
            } else {
                userID = V2TIMManager.sharedInstance.getLoginUser;
            }
        } else {
            userID = cell.messageData.innerMessage.sender;
        }
    }
    
    if (userID == nil) {
        return;
    }
    
    // Get extensions first
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (self.conversationData.userID.length > 0) {
        param[TUICore_TUIChatExtension_ClickAvatar_UserID] = self.conversationData.userID;
    } else if (self.conversationData.groupID.length > 0) {
        param[TUICore_TUIChatExtension_ClickAvatar_GroupID] = self.conversationData.groupID;
    }
    if (self.navigationController) {
        param[TUICore_TUIChatExtension_ClickAvatar_PushVC] = self.navigationController;
    }
    
    NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:TUICore_TUIChatExtension_ClickAvatar_ClassicExtensionID param:param];
    if (extensionList.count > 0) {
        TUIExtensionInfo *maxWeightInfo = [TUIExtensionInfo new];
        maxWeightInfo.weight = INT_MIN;
        for (TUIExtensionInfo *info in extensionList) {
            if (maxWeightInfo.weight < info.weight) {
                maxWeightInfo = info;
            }
        }
        if (maxWeightInfo == nil) {
            return;
        }
        if (maxWeightInfo.onClicked) {
            maxWeightInfo.onClicked(param);
        }
    } else {
        [self getUserOrFriendProfileVCWithUserID:userID
                                       succBlock:^(UIViewController *vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }
                                       failBlock:nil];
    }
    
    [self.inputController reset];
}

- (void)messageController:(TUIBaseMessageController *)controller onSelectMessageContent:(TUIMessageCell *)cell {
    cell.disableDefaultSelectAction = NO;
    if (cell.disableDefaultSelectAction) {
        return;
    }
}

- (void)messageController:(TUIBaseMessageController *)controller onSelectMessageMenu:(NSInteger)menuType withData:(TUIMessageCellData *)data {
    [self onSelectMessageMenu:menuType withData:data];
}

- (void)didHideMenuInMessageController:(TUIBaseMessageController *)controller {
    self.inputController.inputBar.inputTextView.overrideNextResponder = nil;
}

- (void)messageController:(TUIBaseMessageController *)controller onReEditMessage:(TUIMessageCellData *)data {
    V2TIMMessage *message = data.innerMessage;
    if (message.elemType == V2TIM_ELEM_TYPE_TEXT) {
        NSString *text = message.textElem.text;
        self.inputController.inputBar.inputTextView.text = text;
        [self.inputController.inputBar.inputTextView becomeFirstResponder];
    }
}

- (CGFloat)getTopMarginByCustomView {
    return [self topMarginByCustomView];
}

- (BOOL)isAICurrentlyTyping {
    return self.inputController.inputBar.aiIsTyping;
}

#pragma mark - TUIChatBaseDataProviderDelegate
- (NSString *)dataProvider:(TUIChatDataProvider *)dataProvider mergeForwardTitleWithMyName:(NSString *)name {
    return [self forwardTitleWithMyName:name];
}

- (NSString *)dataProvider:(TUIChatDataProvider *)dataProvider mergeForwardMsgAbstactForMessage:(V2TIMMessage *)message {
    return @"";
}

- (void)dataProvider:(TUIChatBaseDataProvider *)dataProvider sendMessage:(V2TIMMessage *)message {
    [self.messageController sendMessage:message];
}

- (void)onSelectPhotoMoreCellData {
    [self.mediaProvider selectPhoto];
}

- (void)onTakePictureMoreCellData {
    [self.mediaProvider takePicture];
}

- (void)onTakeVideoMoreCellData {
    [self.mediaProvider takeVideo];
}

- (void)onMultimediaRecordMoreCellData {
    [self.mediaProvider multimediaRecord];
}

- (void)onSelectFileMoreCellData {
    [self.mediaProvider selectFile];
}

#pragma mark - TUINavigationControllerDelegate
- (void)navigationControllerDidClickLeftButton:(TUINavigationController *)controller {
    if (controller.currentShowVC == self) {
        [self.messageController readReport];
    }
}

- (void)navigationControllerDidSideSlideReturn:(TUINavigationController *)controller fromViewController:(UIViewController *)fromViewController {
    if ([fromViewController isEqual:self]) {
        [self.messageController readReport];
    }
}

#pragma mark - :  & 
- (void)onSelectMessageMenu:(NSInteger)menuType withData:(TUIMessageCellData *)data {
    if (menuType == 0) {
        [self openMultiChooseBoard:YES];
    } else if (menuType == 1) {
        if (data == nil) {
            return;
        }
        NSMutableArray *uiMsgs = [NSMutableArray arrayWithArray:@[ data ]];
        [self prepareForwardMessages:uiMsgs];
    }
}

- (void)openMultiChooseBoard:(BOOL)open {
    [self.view endEditing:YES];

    if (_multiChooseView) {
        [_multiChooseView removeFromSuperview];
    }

    if (open) {
        _multiChooseView = [[TUIMessageMultiChooseView alloc] init];
        _multiChooseView.frame = UIScreen.mainScreen.bounds;
        _multiChooseView.delegate = self;
        _multiChooseView.titleLabel.text = self.conversationData.title;
        if (@available(iOS 12.0, *)) {
            if (@available(iOS 13.0, *)) {
                // > ios 12
                [UIApplication.sharedApplication.keyWindow addSubview:_multiChooseView];
            } else {
                // ios = 12
                UIView *view = self.navigationController.view;
                if (view == nil) {
                    view = self.view;
                }
                [view addSubview:_multiChooseView];
            }
        } else {
            // < ios 12
            [UIApplication.sharedApplication.keyWindow addSubview:_multiChooseView];
        }
    } else {
        [self.messageController enableMultiSelectedMode:NO];
    }
}

- (void)messageMultiChooseViewOnCancelClicked:(TUIMessageMultiChooseView *)multiChooseView {
    [self openMultiChooseBoard:NO];
    [self.messageController enableMultiSelectedMode:NO];
}

- (void)messageMultiChooseViewOnRelayClicked:(TUIMessageMultiChooseView *)multiChooseView {
    NSArray *uiMsgs = [self.messageController multiSelectedResult:TUIMultiResultOptionAll];
    [self prepareForwardMessages:uiMsgs];
}

- (void)messageMultiChooseViewOnDeleteClicked:(TUIMessageMultiChooseView *)multiChooseView {
    NSArray *uiMsgs = [self.messageController multiSelectedResult:TUIMultiResultOptionAll];
    if (uiMsgs.count == 0) {
        [TUITool makeToast:TIMCommonLocalizableString(TUIKitRelayNoMessageTips)];
        return;
    }

    [self.messageController deleteMessages:uiMsgs];
    [self openMultiChooseBoard:NO];
    [self.messageController enableMultiSelectedMode:NO];
}

- (void)prepareForwardMessages:(NSArray<TUIMessageCellData *> *)uiMsgs {
    if (uiMsgs.count == 0) {
        [TUITool makeToast:TIMCommonLocalizableString(TUIKitRelayNoMessageTips)];
        return;
    }

    BOOL hasSendFailedMsg = NO;
    BOOL canForwardMsg = YES;
    for (TUIMessageCellData *data in uiMsgs) {
        if (data.status != Msg_Status_Succ) {
            hasSendFailedMsg = YES;
        }
        canForwardMsg &= [data canForward];
        if (hasSendFailedMsg && !canForwardMsg) {
            break;
        }
    }

    if (hasSendFailedMsg) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitRelayUnsupportForward)
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action){

                                                      }]];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }

    if (!canForwardMsg) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitRelayPluginNotAllowed)
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action){

                                                      }]];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }

    __weak typeof(self) weakSelf = self;
    UIAlertController *tipsVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //  Forward one-by-one
    [tipsVc
        tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitRelayOneByOneForward)
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                    if (uiMsgs.count <= 30) {
                                                        [weakSelf selectTarget:NO toForwardMessage:uiMsgs orForwardText:nil];
                                                        return;
                                                    }
                                                    UIAlertController *vc =
                                                        [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitRelayOneByOnyOverLimit)
                                                                                            message:nil
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                                    [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel)
                                                                                                    style:UIAlertActionStyleDefault
                                                                                                  handler:nil]];
                                                    [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitRelayCombineForwad)
                                                                                                    style:UIAlertActionStyleDefault
                                                                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                                                                    [weakSelf selectTarget:YES
                                                                                                          toForwardMessage:uiMsgs
                                                                                                             orForwardText:nil];
                                                                                                  }]];
                                                    [weakSelf presentViewController:vc animated:YES completion:nil];
                                                  }]];
    //  Merge-forward
    [tipsVc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitRelayCombineForwad)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                        [weakSelf selectTarget:YES toForwardMessage:uiMsgs orForwardText:nil];
                                                      }]];
    [tipsVc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:tipsVc animated:YES completion:nil];
}

- (void)selectTarget:(BOOL)mergeForward toForwardMessage:(NSArray<TUIMessageCellData *> *)uiMsgs orForwardText:(NSString *)forwardText {
    __weak typeof(self) weakSelf = self;
    UINavigationController *nav = [[UINavigationController alloc] init];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:TUICore_TUIConversationObjectFactory_ConversationSelectVC_Classic
                          param:nil
                       embbedIn:nav
                      forResult:^(NSDictionary *_Nonnull param) {
                        NSArray<NSDictionary *> *selectList = param[TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList];

                        NSMutableArray<TUIChatConversationModel *> *targetList = [NSMutableArray arrayWithCapacity:selectList.count];
                        for (NSDictionary *selectItem in selectList) {
                            TUIChatConversationModel *model = [[TUIChatConversationModel alloc] init];
                            model.title = selectItem[TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_Title];
                            model.userID = selectItem[TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_UserID];
                            model.groupID = selectItem[TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_GroupID];
                            model.conversationID = selectItem[TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_ConversationID];
                            [targetList addObject:model];
                        }

                        if (uiMsgs.count > 0) {
                            [weakSelf forwardMessages:uiMsgs toTargets:targetList merge:mergeForward];
                        } else if (forwardText.length > 0) {
                            [weakSelf forwardText:forwardText toConverations:targetList];
                        }
                      }];
}

- (void)forwardMessages:(NSArray<TUIMessageCellData *> *)uiMsgs toTargets:(NSArray<TUIChatConversationModel *> *)targets merge:(BOOL)merge {
    if (uiMsgs.count == 0 || targets.count == 0) {
        return;
    }

    @weakify(self);
    [self.dataProvider getForwardMessageWithCellDatas:uiMsgs
        toTargets:targets
        Merge:merge
        ResultBlock:^(TUIChatConversationModel *_Nonnull targetConversation, NSArray<V2TIMMessage *> *_Nonnull msgs) {
          @strongify(self);

          TUIChatConversationModel *convCellData = targetConversation;
          NSTimeInterval timeInterval = convCellData.groupID.length ? 0.09 : 0.05;

          /**
           * 
           * Forward to currernt chat vc
           */
          if ([convCellData.conversationID isEqualToString:self.conversationData.conversationID]) {
              dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
              dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
              dispatch_async(queue, ^{
                  for (V2TIMMessage *imMsg in msgs) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.messageController sendMessage:imMsg];
                          dispatch_semaphore_signal(semaphore);
                      });

                      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                      [NSThread sleepForTimeInterval:timeInterval];
                  }
              });
              return;
          }

          /**
           * 
           * Forward to other chat user
           */
        TUISendMessageAppendParams *appendParams = [[TUISendMessageAppendParams alloc] init];
        appendParams.isSendPushInfo = YES;
        appendParams.isOnlineUserOnly = NO;
        appendParams.priority = V2TIM_PRIORITY_NORMAL;
          for (V2TIMMessage *message in msgs) {
              message.needReadReceipt = self.conversationData.msgNeedReadReceipt && [TUIChatConfig defaultConfig].msgNeedReadReceipt;
              [TUIMessageDataProvider sendMessage:message
                  toConversation:convCellData
                  appendParams:appendParams
                  Progress:nil
                  SuccBlock:^{
                    /**
                     * Messages sent to other chats need to broadcast the message sending status, which is convenient to refresh the message status after
                     * entering the corresponding chat
                     */
                    [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged object:message];
                  }
                  FailBlock:^(int code, NSString *desc) {
                    [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged object:message];
                  }];

              /**
               * The delay here is to ensure the order of the receiving end as much as possible when forwarding in batches one by one
               */
              [NSThread sleepForTimeInterval:timeInterval];
          }
        }
        fail:^(int code, NSString *desc) {
          NSLog(@"%@", desc);
          NSAssert(NO, desc);
        }];
}

- (NSString *)forwardTitleWithMyName:(NSString *)nameStr {
    return @"";
}

#pragma mark - Message reply
- (void)messageController:(TUIBaseMessageController *)controller onRelyMessage:(nonnull TUIMessageCellData *)data {
    @weakify(self);
    [self.inputController exitReplyAndReference:^{
      @strongify(self);
      NSString *desc = @"";
      desc = [self replyReferenceMessageDesc:data];

      TUIReplyPreviewData *replyData = [[TUIReplyPreviewData alloc] init];
      replyData.msgID = data.msgID;
      replyData.msgAbstract = desc;
      replyData.sender = data.senderName;
      replyData.type = (NSInteger)data.innerMessage.elemType;
      replyData.originMessage = data.innerMessage;

      NSMutableDictionary *cloudResultDic = [[NSMutableDictionary alloc] initWithCapacity:5];
      if (replyData.originMessage.cloudCustomData) {
          NSDictionary *originDic = [TUITool jsonData2Dictionary:replyData.originMessage.cloudCustomData];
          if (originDic && [originDic isKindOfClass:[NSDictionary class]]) {
              [cloudResultDic addEntriesFromDictionary:originDic];
          }
      }
      NSString *messageParentReply = cloudResultDic[@"messageReply"];
      NSString *messageRootID = [messageParentReply valueForKey:@"messageRootID"];
      if (!IS_NOT_EMPTY_NSSTRING(messageRootID)) {
          /**
           * If the original message does not have messageRootID, you need to make the msgID of the current original message as the root
           */
          if (IS_NOT_EMPTY_NSSTRING(replyData.originMessage.msgID)) {
              messageRootID = replyData.originMessage.msgID;
          }
      }

      replyData.messageRootID = messageRootID;
      [self.inputController showReplyPreview:replyData];
    }];
}
- (NSString *)replyReferenceMessageDesc:(TUIMessageCellData *)data {
    NSString *desc = @"";
    if (data.innerMessage.elemType == V2TIM_ELEM_TYPE_FILE) {
        desc = data.innerMessage.fileElem.filename;
    } else if (data.innerMessage.elemType == V2TIM_ELEM_TYPE_MERGER) {
        desc = data.innerMessage.mergerElem.title;
    } else if (data.innerMessage.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        desc = [TUIMessageDataProvider getDisplayString:data.innerMessage];
    } else if (data.innerMessage.elemType == V2TIM_ELEM_TYPE_TEXT) {
        desc = data.innerMessage.textElem.text;
    }
    return desc;
}
#pragma mark - Message quote
- (void)messageController:(TUIBaseMessageController *)controller onReferenceMessage:(TUIMessageCellData *)data {
    @weakify(self);
    [self.inputController exitReplyAndReference:^{
      @strongify(self);
      NSString *desc = @"";
      desc = [self replyReferenceMessageDesc:data];

      TUIReferencePreviewData *referenceData = [[TUIReferencePreviewData alloc] init];
      referenceData.msgID = data.msgID;
      referenceData.msgAbstract = desc;
      referenceData.sender = data.senderName;
      referenceData.type = (NSInteger)data.innerMessage.elemType;
      referenceData.originMessage = data.innerMessage;
      [self.inputController showReferencePreview:referenceData];
    }];
}

#pragma mark - Message translation forward
- (void)messageController:(TUIBaseMessageController *)controller onForwardText:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    [self selectTarget:NO toForwardMessage:nil orForwardText:text];
}

- (void)forwardText:(NSString *)text toConverations:(NSArray<TUIChatConversationModel *> *)conversations {
    TUISendMessageAppendParams *appendParams = [[TUISendMessageAppendParams alloc] init];
    appendParams.isSendPushInfo = YES;
    appendParams.isOnlineUserOnly = NO;
    appendParams.priority = V2TIM_PRIORITY_NORMAL;
    for (TUIChatConversationModel *conversation in conversations) {
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createTextMessage:text];
        dispatch_async(dispatch_get_main_queue(), ^{
          if ([conversation.conversationID isEqualToString:self.conversationData.conversationID]) {
              // Send forward text to myself
              [self.messageController sendMessage:message];
          } else {
              // Send to other conversation
              message.needReadReceipt = self.conversationData.msgNeedReadReceipt && [TUIChatConfig defaultConfig].msgNeedReadReceipt;
              [TUIMessageDataProvider sendMessage:message
                  toConversation:conversation
                  appendParams:appendParams
                  Progress:nil
                  SuccBlock:^{
                    [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged object:message];
                  }
                  FailBlock:^(int code, NSString *desc) {
                    [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged object:message];
                  }];
          }
        });
    }
}

#pragma mark - Private Methods
+ (void)createCachePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:TUIKit_Image_Path]) {
        [fileManager createDirectoryAtPath:TUIKit_Image_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:TUIKit_Video_Path]) {
        [fileManager createDirectoryAtPath:TUIKit_Video_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:TUIKit_Voice_Path]) {
        [fileManager createDirectoryAtPath:TUIKit_Voice_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:TUIKit_File_Path]) {
        [fileManager createDirectoryAtPath:TUIKit_File_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:TUIKit_DB_Path]) {
        [fileManager createDirectoryAtPath:TUIKit_DB_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - TUIJoinGroupMessageCellDelegate
- (void)didTapOnRestNameLabel:(TUIJoinGroupMessageCell *)cell withIndex:(NSInteger)index {
    NSString *userId = cell.joinData.userIDList[index];

    [self getUserOrFriendProfileVCWithUserID:userId
        succBlock:^(UIViewController *vc) {
          [self.navigationController pushViewController:vc animated:YES];
        }
        failBlock:^(int code, NSString *desc) {
          [TUITool makeToastError:code msg:desc];
        }];
}

#pragma mark - V2TIMConversationListener
- (void)onConversationChanged:(NSArray<V2TIMConversation *> *)conversationList {
    for (V2TIMConversation *conv in conversationList) {
        if ([conv.conversationID isEqualToString:self.conversationData.conversationID]) {
            if (!self.conversationData.otherSideTyping) {
                self.conversationData.title = conv.showName;
            }
            break;
        }
    }
}

#pragma mark - FriendInfoChangedNotification
- (void)onFriendInfoChanged:(NSNotification *)notice {
    [self checkTitle:YES];
}

#pragma mark - Media Provider
- (void)sendPlaceHolderUIMessage:(TUIMessageCellData *)cellData {
    [self.messageController sendPlaceHolderUIMessage:cellData];
}
- (TUIChatMediaDataProvider *)mediaProvider {
    if (_mediaProvider == nil) {
        _mediaProvider = [[TUIChatMediaDataProvider alloc] init];
        _mediaProvider.listener = self;
        _mediaProvider.presentViewController = self;
        _mediaProvider.conversationID = _conversationData.conversationID;
    }
    return _mediaProvider;
}

- (void)onProvideImage:(NSString *)imageUrl {
    V2TIMMessage *message = [V2TIMManager.sharedInstance createImageMessage:imageUrl];
    [self sendMessage:message];
}

- (void)onProvideImageError:(NSString *)errorMessage {
    [TUITool makeToast:errorMessage];
}

- (void)onProvidePlaceholderVideoSnapshot:(NSString *)snapshotUrl
                        SnapImage:(UIImage *)image
                       Completion:(void (^__nullable)(BOOL finished, TUIMessageCellData *placeHolderCellData))completion {
    TUIMessageCellData *videoCellData = [TUIVideoMessageCellData placeholderCellDataWithSnapshotUrl:snapshotUrl thubImage:image];
    [self.messageController sendPlaceHolderUIMessage:videoCellData];
    if (completion) {
        completion(YES,videoCellData);
    }
}
- (void)onProvideVideo:(NSString *)videoUrl
               snapshot:(NSString *)snapshotUrl
               duration:(NSInteger)duration
    placeHolderCellData:(TUIMessageCellData *)placeHolderCellData {
    V2TIMMessage *message = [V2TIMManager.sharedInstance createVideoMessage:videoUrl
                                                                       type:videoUrl.pathExtension
                                                                   duration:(int)duration
                                                               snapshotPath:snapshotUrl];
    [self sendMessage:message placeHolderCellData:placeHolderCellData];
}
- (void)onProvideVideoError:(NSString *)errorMessage {
    [TUITool makeToast:errorMessage];
}

- (void)onProvideFile:(NSString *)fileUrl filename:(NSString *)filename fileSize:(NSInteger)fileSize {
    V2TIMMessage *message = [V2TIMManager.sharedInstance createFileMessage:fileUrl fileName:filename];
    [self sendMessage:message];
}

- (void)onProvideFileError:(NSString *)errorMessage {
    [TUITool makeToast:errorMessage];
}

- (NSString *)currentConversationID {
    return self.conversationData.conversationID;
}

- (BOOL)isPageAppears {
    return self.responseKeyboard;
}

- (void)onChatbotLoadingAnimationDidStop:(NSNotification *)notification {
    // Handle the notification when AI loading animation stops
    NSLog(@"AI loading animation did stop");
    
    // Check if this is an AI conversation
    BOOL isAIConversation = [self.conversationData isAIConversation];
    
    if (isAIConversation) {
        // Call finishAITypingWithMessage to complete the AI typing process
        [self setAIFinishTyping];
        
        // Clear the receiving chatbot message
        self.receivingChatbotMessage = nil;
    }
}

#pragma mark - HUD Methods

- (void)showHudMsgText:(NSString *)msgText {
    [self hideHud];
    
    if (!msgText || msgText.length == 0) {
        return;
    }
    
    // Create container view
    self.hudContainerView = [[UIView alloc] init];
    self.hudContainerView.backgroundColor = [UIColor clearColor];
    self.hudContainerView.alpha = 0.0;
    [self.view addSubview:self.hudContainerView];
    
    // Create background view with design specs
    self.hudBackgroundView = [[UIView alloc] init];
    self.hudBackgroundView.backgroundColor = [UIColor colorWithRed:0.92 green:0.95 blue:1.0 alpha:1.0]; // #EBF3FF
    self.hudBackgroundView.layer.cornerRadius = 6.0;
    self.hudBackgroundView.layer.masksToBounds = NO;
    
    // Add shadow effects as per design
    self.hudBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.hudBackgroundView.layer.shadowOffset = CGSizeMake(0, 8);
    self.hudBackgroundView.layer.shadowRadius = 13;
    self.hudBackgroundView.layer.shadowOpacity = 0.06;
    
    // Additional shadow layers for multiple shadow effect
    CALayer *shadowLayer1 = [CALayer layer];
    shadowLayer1.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer1.shadowOffset = CGSizeMake(0, 12);
    shadowLayer1.shadowRadius = 13;
    shadowLayer1.shadowOpacity = 0.06;
    [self.hudBackgroundView.layer insertSublayer:shadowLayer1 atIndex:0];
    
    CALayer *shadowLayer2 = [CALayer layer];
    shadowLayer2.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer2.shadowOffset = CGSizeMake(0, 1);
    shadowLayer2.shadowRadius = 2.5;
    shadowLayer2.shadowOpacity = 0.06;
    [self.hudBackgroundView.layer insertSublayer:shadowLayer2 atIndex:0];
    
    [self.hudContainerView addSubview:self.hudBackgroundView];
    
    // Create label with design specs
    self.hudLabel = [[UILabel alloc] init];
    self.hudLabel.text = msgText;
    self.hudLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]; // rgba(0, 0, 0, 0.9)
    self.hudLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.0];
    if (!self.hudLabel.font) {
        self.hudLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    }
    self.hudLabel.textAlignment = NSTextAlignmentCenter;
    self.hudLabel.numberOfLines = 0;
    self.hudLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.hudBackgroundView addSubview:self.hudLabel];
    
    // Layout constraints
    self.hudContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.hudBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.hudLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Container view constraints (center in parent view)
    [NSLayoutConstraint activateConstraints:@[
        [self.hudContainerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.hudContainerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.hudContainerView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:40],
        [self.hudContainerView.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-40]
    ]];
    
    // Background view constraints (hug content)
    [NSLayoutConstraint activateConstraints:@[
        [self.hudBackgroundView.topAnchor constraintEqualToAnchor:self.hudContainerView.topAnchor],
        [self.hudBackgroundView.leadingAnchor constraintEqualToAnchor:self.hudContainerView.leadingAnchor],
        [self.hudBackgroundView.trailingAnchor constraintEqualToAnchor:self.hudContainerView.trailingAnchor],
        [self.hudBackgroundView.bottomAnchor constraintEqualToAnchor:self.hudContainerView.bottomAnchor]
    ]];
    
    // Label constraints (8px 20px padding as per design)
    [NSLayoutConstraint activateConstraints:@[
        [self.hudLabel.topAnchor constraintEqualToAnchor:self.hudBackgroundView.topAnchor constant:8],
        [self.hudLabel.leadingAnchor constraintEqualToAnchor:self.hudBackgroundView.leadingAnchor constant:20],
        [self.hudLabel.trailingAnchor constraintEqualToAnchor:self.hudBackgroundView.trailingAnchor constant:-20],
        [self.hudLabel.bottomAnchor constraintEqualToAnchor:self.hudBackgroundView.bottomAnchor constant:-8]
    ]];
    
    // Animate in
    [UIView animateWithDuration:0.3 animations:^{
        self.hudContainerView.alpha = 1.0;
    }];
    
    // Auto hide after 2 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideHud];
    });
}

- (void)hideHud {
    if (self.hudContainerView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.hudContainerView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.hudContainerView removeFromSuperview];
            self.hudContainerView = nil;
            self.hudBackgroundView = nil;
            self.hudLabel = nil;
        }];
    }
}

@end
