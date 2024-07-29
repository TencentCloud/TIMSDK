//
//  TUIBaseChatViewController_Minimalist.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIBaseChatViewController_Minimalist.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TIMInputViewMoreActionProtocol.h>
#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import <TIMCommon/TUIFloatViewController.h>
#import <TIMCommon/TUIGroupAvatar+Helper.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUITool.h>
#import <TUICore/NSString+TUIUtil.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIAIDenoiseSignatureManager.h"
#import "TUIBaseMessageController_Minimalist.h"
#import "TUICameraViewController.h"
#import "TUIChatConfig.h"
#import "TUIChatDataProvider.h"
#import "TUIChatMediaDataProvider.h"
#import "TUIChatModifyMessageHelper.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIFileMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIJoinGroupMessageCell_Minimalist.h"
#import "TUIMessageController_Minimalist.h"
#import "TUIMessageDataProvider.h"
#import "TUIMessageMultiChooseView_Minimalist.h"
#import "TUIMessageReadViewController_Minimalist.h"
#import "TUIReplyMessageCellData.h"
#import "TUITextMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "UIAlertController+TUICustomStyle.h"

static UIView *gCustomTopView;
static UIView *gTopExentsionView;
static UIView *gGroupPinTopView;
static CGRect gCustomTopViewRect;

@interface TUIBaseChatViewController_Minimalist () <TUIBaseMessageControllerDelegate_Minimalist,
                                                    TUIInputControllerDelegate_Minimalist,
                                                    UIImagePickerControllerDelegate,
                                                    UIDocumentPickerDelegate,
                                                    UINavigationControllerDelegate,
                                                    TUIMessageMultiChooseViewDelegate_Minimalist,
                                                    TUIChatBaseDataProviderDelegate,
                                                    TUINotificationProtocol,
                                                    TUIJoinGroupMessageCellDelegate_Minimalist,
                                                    V2TIMConversationListener,
                                                    TUINavigationControllerDelegate,
                                                    V2TIMSDKListener,
                                                    TUIChatMediaDataListener,
                                                    TIMInputViewMoreActionProtocol>

@property(nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property(nonatomic, strong) TUIMessageMultiChooseView_Minimalist *multiChooseView;
@property(nonatomic, assign) BOOL responseKeyboard;
@property(nonatomic, strong) TUIChatDataProvider *dataProvider;

@property(nonatomic, assign) BOOL firstAppear;

@property(nonatomic, copy) NSString *mainTitle;

@property(nonatomic, strong) UIImageView *backgroudView;

@property(nonatomic, strong) UIImageView *avatarView;

@property(nonatomic, strong) UILabel *mainTitleLabel;

@property(nonatomic, strong) UILabel *subTitleLabel;

@property(nonatomic, strong) TUIChatMediaDataProvider *mediaProvider;

@end

@implementation TUIBaseChatViewController_Minimalist

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [TUIBaseChatViewController_Minimalist createCachePath];
        [[TUIAIDenoiseSignatureManager sharedInstance] updateSignature];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTopViewsAndMessagePage)
                                                     name:TUICore_TUIChatExtension_ChatViewTopArea_ChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    self.mainTitle = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTopViews];
    
    self.firstAppear = YES;
    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#FFFFFF");
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self configBackgroundView];

    [self configNotify];

    // setup UI
    [self setupNavigator];
    if (gCustomTopView) {
        [self setupCustomTopView];
    }
    [self setupMessageController];
    [self setupInputController];

    // data provider
    self.dataProvider = [[TUIChatDataProvider alloc] init];
    self.dataProvider.delegate = self;

    [[V2TIMManager sharedInstance] addIMSDKListener:self];
}

- (void)dealloc {
    [TUICore unRegisterEventByObject:self];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self saveDraft];
    }
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.responseKeyboard = YES;
    if (self.firstAppear) {
        [self loadDraft];
        self.firstAppear = NO;
    }
    self.mainTitleLabel.text = [self getMainTitleLabelText];
    [self configHeadImageView:self.conversationData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.responseKeyboard = NO;
    [self openMultiChooseBoard:NO];
    [self.messageController enableMultiSelectedMode:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupNavigator {
    TUINavigationController *naviController = (TUINavigationController *)self.navigationController;
    if ([naviController isKindOfClass:TUINavigationController.class]) {
        naviController.uiNaviDelegate = self;
        UIImage *backimg = TIMCommonDynamicImage(@"nav_back_img", TIMCommonImagePath(@"nav_back"));
        backimg = [backimg rtl_imageFlippedForRightToLeftLayoutDirection];
        naviController.navigationItemBackArrowImage =  backimg;
    }

    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIImage *imgicon = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"vc_back")];
    imgicon  = [imgicon rtl_imageFlippedForRightToLeftLayoutDirection];
    [backButton setImage:imgicon forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScale390(200), 40)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightBarButtonClick)];
    [infoView addGestureRecognizer:tap];

    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    avatarView.image = self.conversationData.avatarImage;
    avatarView.layer.cornerRadius = avatarView.frame.size.width / 2.0;
    avatarView.layer.masksToBounds = YES;
    [infoView addSubview:avatarView];
    self.avatarView = avatarView;

    UILabel *mainTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(avatarView.mm_x + avatarView.mm_w + kScale390(8), 0, kScale390(200), 20)];
    mainTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    mainTitleLabel.text = [self getMainTitleLabelText];
    mainTitleLabel.rtlAlignment = TUITextRTLAlignmentLeading;
    [infoView addSubview:mainTitleLabel];
    self.mainTitleLabel = mainTitleLabel;

    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainTitleLabel.mm_x, 20, mainTitleLabel.mm_w, 20)];
    self.subTitleLabel.font = [UIFont systemFontOfSize:12];
    self.subTitleLabel.rtlAlignment = TUITextRTLAlignmentLeading;
    [self updateSubTitleLabelText];
    [infoView addSubview:self.subTitleLabel];

    if (isRTL()) {
        [avatarView resetFrameToFitRTL];
        [mainTitleLabel resetFrameToFitRTL];
        [self.subTitleLabel resetFrameToFitRTL];
    }
    
    __weak typeof(self) weakSelf = self;

    [[RACObserve(_conversationData, otherSideTyping) distinctUntilChanged] subscribeNext:^(id otherSideTyping) {
      BOOL otherSideTypingFlag = [otherSideTyping boolValue];
      if (!otherSideTypingFlag) {
          [weakSelf updateSubTitleLabelText];
      }
      else {
          NSString *typingText = [NSString stringWithFormat:@"%@...", TIMCommonLocalizableString(TUIKitTyping)];
          weakSelf.subTitleLabel.text = typingText;
      }
    }];
    
    UIBarButtonItem *infoViewItem = [[UIBarButtonItem alloc] initWithCustomView:infoView];

    self.navigationItem.leftBarButtonItems = @[ backButtonItem, infoViewItem ];

    CGSize itemSize = CGSizeMake(30, 24);
    NSMutableArray *rightBarButtonList = [NSMutableArray array];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (self.conversationData.userID.length > 0) {
        param[TUICore_TUIChatExtension_NavigationMoreItem_UserID] = self.conversationData.userID;
    } else if (self.conversationData.groupID.length > 0) {
        param[TUICore_TUIChatExtension_NavigationMoreItem_GroupID] = self.conversationData.groupID;
    }
    param[TUICore_TUIChatExtension_NavigationMoreItem_ItemSize] = NSStringFromCGSize(itemSize);
    param[TUICore_TUIChatExtension_NavigationMoreItem_FilterVideoCall] = @(!TUIChatConfig.defaultConfig.enableVideoCall);
    param[TUICore_TUIChatExtension_NavigationMoreItem_FilterAudioCall] = @(!TUIChatConfig.defaultConfig.enableAudioCall);
    NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:TUICore_TUIChatExtension_NavigationMoreItem_MinimalistExtensionID param:param];
    for (TUIExtensionInfo *info in extensionList) {
        if (info.icon && info.onClicked) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
            button.tui_extValueObj = info;
            [button addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:info.icon forState:UIControlStateNormal];
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            [rightBarButtonList addObject:rightItem];
        }
    }
    if (rightBarButtonList.count > 0) {
        self.navigationItem.rightBarButtonItems = rightBarButtonList.reverseObjectEnumerator.allObjects;
    }
}

- (NSString *)getMainTitleLabelText {
    if (self.conversationData.title.length > 0) {
        return self.conversationData.title;
    } else if (self.conversationData.groupID.length > 0) {
        return self.conversationData.groupID;
    } else {
        return self.conversationData.userID;
    }
}

- (void)updateSubTitleLabelText {
    if (![TUIConfig defaultConfig].displayOnlineStatusIcon) {
        self.subTitleLabel.text = @"";
        return;
    }
    if (self.conversationData.userID.length > 0) {
        [[V2TIMManager sharedInstance] getUserStatus:@[ self.conversationData.userID ]
                                                succ:^(NSArray<V2TIMUserStatus *> *result) {
                                                  V2TIMUserStatus *status = result.firstObject;
                                                  self.subTitleLabel.text = [self getUserStatus:status];
                                                }
                                                fail:nil];
    } else if (self.conversationData.groupID.length > 0) {
        [[V2TIMManager sharedInstance] getGroupMemberList:self.conversationData.groupID
                                                   filter:V2TIM_GROUP_MEMBER_FILTER_ALL
                                                  nextSeq:0
                                                     succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
                                                       NSMutableString *title = [NSMutableString string];
                                                       int memberCount = 0;
                                                       for (V2TIMGroupMemberFullInfo *info in memberList) {
                                                           NSString *name = (info.nameCard ?: info.nickName) ?: info.userID;
                                                           [title appendString:[NSString stringWithFormat:@"%@，", name]];
                                                           if (++memberCount >= 5) {
                                                               break;
                                                           }
                                                       }
                                                       if (title.length > 0) {
                                                           title = [NSMutableString stringWithString:[title substringToIndex:title.length - 1]];
                                                       }
                                                       self.subTitleLabel.text = title;
                                                     }
                                                     fail:nil];
    }
}

- (void)onUserStatusChanged:(NSArray<V2TIMUserStatus *> *)userStatusList {
    if (!self.conversationData.userID) {
        return;
    }
    for (V2TIMUserStatus *status in userStatusList) {
        if ([status.userID isEqualToString:self.conversationData.userID]) {
            self.subTitleLabel.text = [self getUserStatus:status];
            break;
        }
    }
}

- (NSString *)getUserStatus:(V2TIMUserStatus *)status {
    NSString *title = nil;
    switch (status.statusType) {
        case V2TIM_USER_STATUS_UNKNOWN: {
            title = TIMCommonLocalizableString(TUIKitUserStatusUnknown);
        } break;
        case V2TIM_USER_STATUS_ONLINE: {
            title = TIMCommonLocalizableString(TUIKitUserStatusOnline);
        } break;
        case V2TIM_USER_STATUS_OFFLINE: {
            title = TIMCommonLocalizableString(TUIKitUserStatusOffline);
        } break;
        case V2TIM_USER_STATUS_UNLOGINED: {
            title = TIMCommonLocalizableString(TUIKitUserStatusUnlogined);
        } break;
        default:
            break;
    }
    return title;
}

- (void)backButtonClick {
    [self.messageController readReport];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonClick:(UIButton *)button {
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

- (void)setupMessageController {
    TUIMessageController_Minimalist *vc = [[TUIMessageController_Minimalist alloc] init];
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
    [TUICore raiseExtension:TUICore_TUIChatExtension_ChatViewTopArea_MinimalistExtensionID parentView:gTopExentsionView param:param];

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

- (void)setupInputController {
    _inputController = [[TUIInputController_Minimalist alloc] init];
    _inputController.delegate = self;
    _inputController.view.frame =
        CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addChildViewController:_inputController];
    [self.view addSubview:_inputController.view];
    _inputController.view.hidden = !TUIChatConfig.defaultConfig.enableMainPageInputBar;

}
- (void)configHeadImageView:(TUIChatConversationModel *)convData {
    /**
     * Setup default avatar
     */
    if (convData.groupID.length > 0) {
        /**
         * If it is a group, change the group default avatar to the last used avatar
         */
        convData.avatarImage = [TUIGroupAvatar getNormalGroupCacheAvatar:convData.groupID groupType:convData.groupType];
    }

    @weakify(self);

    [[RACObserve(convData, faceUrl) distinctUntilChanged] subscribeNext:^(NSString *faceUrl) {
      @strongify(self);
      NSString *groupID = convData.groupID ?: @"";
      NSString *pFaceUrl = convData.faceUrl ?: @"";
      NSString *groupType = convData.groupType ?: @"";
      UIImage *originAvatarImage = nil;
      if (convData.groupID.length > 0) {
          originAvatarImage = convData.avatarImage ?: DefaultGroupAvatarImageByGroupType(groupType);
      } else {
          originAvatarImage = convData.avatarImage ?: DefaultAvatarImage;
      }
      NSDictionary *param = @{
          @"groupID" : groupID,
          @"faceUrl" : pFaceUrl,
          @"groupType" : groupType,
          @"originAvatarImage" : originAvatarImage,
      };
      [TUIGroupAvatar configAvatarByParam:param targetView:self.avatarView];
    }];
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

    [TUICore registerEvent:TUICore_TUIContactNotify subKey:TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey object:self];
    [TUICore registerEvent:TUICore_TUIGroupNotify subKey:TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey object:self];
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
     * Display draft
     */
    NSString *draftContent = [jsonDict.allKeys containsObject:@"content"] ? jsonDict[@"content"] : @"";

    NSMutableAttributedString *formatEmojiString = [draftContent getAdvancedFormatEmojiStringWithFont:kTUIInputNoramlFont
                                                                                            textColor:kTUIInputNormalTextColor
                                                                                       emojiLocations:nil];

    [self.inputController.inputBar addDraftToInputBar:formatEmojiString];

    NSString *messageRootID = [jsonDict.allKeys containsObject:@"messageRootID"] ? jsonDict[@"messageRootID"] : @"";

    /**
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
    if (!IS_NOT_EMPTY_NSSTRING(_conversationData.title) || !IS_NOT_EMPTY_NSSTRING(conversationData.faceUrl)) {
        [self checkTitle:YES];
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
                                                                self.conversationData.faceUrl = friendInfoResult.friendInfo.userFullInfo.faceURL;
                                                            } else {
                                                                [TUIChatDataProvider
                                                                    getUserInfoWithUserId:self.conversationData.userID
                                                                                SuccBlock:^(V2TIMUserFullInfo *_Nonnull userInfo) {
                                                                                  if (userInfo.nickName.length > 0) {
                                                                                      self.conversationData.title = userInfo.nickName;
                                                                                      self.conversationData.faceUrl = userInfo.faceURL;
                                                                                  }
                                                                                }
                                                                                failBlock:nil];
                                                            }
                                                          }
                                                          failBlock:nil];
        } else if (self.conversationData.groupID.length > 0) {
            [TUIChatDataProvider getGroupInfoWithGroupID:self.conversationData.groupID
                                                          SuccBlock:^(V2TIMGroupInfoResult *_Nonnull groupResult) {
                                                            if (groupResult.info.groupName.length > 0) {
                                                                self.conversationData.title = groupResult.info.groupName;
                                                                self.conversationData.faceUrl = groupResult.info.faceURL;
                                                                self.conversationData.groupType = groupResult.info.groupType;
                                                            }
                                                          }
                                                          failBlock:nil];
        }
    }
}

- (void)leftBarButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonClick {
    if (_conversationData.userID.length > 0) {
        [self getUserOrFriendProfileVCWithUserID:self.conversationData.userID
            succBlock:^(UIViewController *_Nonnull vc) {
              [self.navigationController pushViewController:vc animated:YES];
            }
            failBlock:^(int code, NSString *_Nonnull desc) {
              [TUITool makeToastError:code msg:desc];
            }];
    } else {
        NSDictionary *param = @{TUICore_TUIGroupObjectFactory_GetGroupInfoVC_GroupID : self.conversationData.groupID};
        [self.navigationController pushViewController:TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Minimalist param:param forResult:nil];
    }
}

- (void)getUserOrFriendProfileVCWithUserID:(NSString *)userID succBlock:(void (^)(UIViewController *vc))succ failBlock:(nullable V2TIMFail)fail {
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ ? : ^(UIViewController *vc){},
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail ? : ^(int code, NSString * desc){}
    };
    [TUICore createObject:TUICore_TUIContactObjectFactory_Minimalist key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];
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
    } else if ([key isEqualToString:TUICore_TUIGroupNotify] && [subKey isEqualToString:TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey]) {
        NSString *conversationID = param[TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey_ConversationID];
        if (IS_NOT_EMPTY_NSSTRING(conversationID)) {
            [self updateBackgroundImageUrlByConversationID:conversationID];
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
- (void)inputController:(TUIInputController_Minimalist *)inputController didChangeHeight:(CGFloat)height {
    if (!self.responseKeyboard) {
        return;
    }
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       CGRect msgFrame = self.messageController.view.frame;
                       msgFrame.size.height = self.view.frame.size.height - height - [self topMarginByCustomView];
                       self.messageController.view.frame = msgFrame;

                       CGRect inputFrame = self.inputController.view.frame;
                       inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
                       inputFrame.size.height = height;
                       self.inputController.view.frame = inputFrame;
                       [self.messageController scrollToBottom:NO];
                     }
                     completion:nil];
}

- (void)inputController:(TUIInputController_Minimalist *)inputController didSendMessage:(V2TIMMessage *)msg {
    [self.messageController sendMessage:msg];
}

- (void)inputControllerDidSelectMoreButton:(TUIInputController_Minimalist *)inputController {
    NSArray *items = [self.dataProvider getInputMoreActionItemList:self.conversationData.userID
                                                           groupID:self.conversationData.groupID
                                                 conversationModel:self.conversationData
                                                            pushVC:self.navigationController
                                                  actionController:self];
    if (items.count) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertVC configItems:items];
        [alertVC addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)inputControllerDidSelectCamera:(TUIInputController_Minimalist *)inputController {
    [self.mediaProvider takePicture];
}

- (void)inputControllerDidInputAt:(TUIInputController_Minimalist *)inputController {
    /**
     * Handle to GroupChatVC
     */
}

- (void)inputController:(TUIInputController_Minimalist *)inputController didDeleteAt:(NSString *)atText {
    /**
     * Handle to GroupChatVC
     */
}

- (void)inputControllerBeginTyping:(TUIInputController_Minimalist *)inputController {
    // for C2CChatVC
}

- (void)inputControllerEndTyping:(TUIInputController_Minimalist *)inputController {
    // for C2CChatVC
}

#pragma mark - TUIBaseMessageControllerDelegate
- (void)didTapInMessageController:(TUIBaseMessageController_Minimalist *)controller {
    [self.inputController reset];
}

- (BOOL)messageController:(TUIBaseMessageController_Minimalist *)controller willShowMenuInCell:(TUIMessageCell *)cell {
    if ([self.inputController.inputBar.inputTextView isFirstResponder]) {
        self.inputController.inputBar.inputTextView.overrideNextResponder = cell;
        return YES;
    }
    return NO;
}

- (TUIMessageCellData *)messageController:(TUIBaseMessageController_Minimalist *)controller onNewMessage:(V2TIMMessage *)message {
    return nil;
}

- (TUIMessageCell *)messageController:(TUIBaseMessageController_Minimalist *)controller onShowMessageData:(TUIMessageCellData *)data {
    return nil;
}

- (void)messageController:(TUIBaseMessageController_Minimalist *)controller willDisplayCell:(TUIMessageCell *)cell withData:(TUIMessageCellData *)cellData {
    if ([cell isKindOfClass:[TUIJoinGroupMessageCell_Minimalist class]]) {
        TUIJoinGroupMessageCell_Minimalist *joinCell = (TUIJoinGroupMessageCell_Minimalist *)cell;
        joinCell.joinGroupDelegate = self;
    }
}

- (void)messageController:(TUIBaseMessageController_Minimalist *)controller onSelectMessageAvatar:(TUIMessageCell *)cell {
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
    [self getUserOrFriendProfileVCWithUserID:userID
                                   succBlock:^(UIViewController *vc) {
                                     [self.navigationController pushViewController:vc animated:YES];
                                   }
                                   failBlock:nil];
}

- (void)messageController:(TUIBaseMessageController_Minimalist *)controller onSelectMessageContent:(TUIMessageCell *)cell {
    cell.disableDefaultSelectAction = NO;
    if (cell.disableDefaultSelectAction) {
        return;
    }
}

- (void)messageController:(TUIBaseMessageController_Minimalist *)controller onSelectMessageMenu:(NSInteger)menuType withData:(TUIMessageCellData *)data {
    [self onSelectMessageMenu:menuType withData:data];
}

- (void)didHideMenuInMessageController:(TUIBaseMessageController_Minimalist *)controller {
    self.inputController.inputBar.inputTextView.overrideNextResponder = nil;
}

- (void)messageController:(TUIBaseMessageController_Minimalist *)controller onReEditMessage:(TUIMessageCellData *)data {
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

- (void)messageController:(TUIBaseMessageController_Minimalist *)controller onSelectMessageWhenMultiCheckboxAppear:(TUIMessageCellData *)data {
    if (_multiChooseView) {
        NSArray *uiMsgs = [self.messageController multiSelectedResult:TUIMultiResultOptionAll];
        _multiChooseView.selectedCountLabel.text =
            [NSString stringWithFormat:@"%lu %@", (unsigned long)uiMsgs.count, TIMCommonLocalizableString(TUIKitSelected)];
    }
}
#pragma mark - TUIChatBaseDataProviderDelegate
- (NSString *)dataProvider:(TUIChatBaseDataProvider *)dataProvider mergeForwardTitleWithMyName:(NSString *)name {
    return [self forwardTitleWithMyName:name];
}

- (NSString *)dataProvider:(TUIChatBaseDataProvider *)dataProvider mergeForwardMsgAbstactForMessage:(V2TIMMessage *)message {
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

#pragma mark - MessageMenu
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
        _multiChooseView = [[TUIMessageMultiChooseView_Minimalist alloc] init];
        _multiChooseView.frame = UIScreen.mainScreen.bounds;
        _multiChooseView.delegate = self;
        _multiChooseView.titleLabel.text = self.conversationData.title;
        _multiChooseView.selectedCountLabel.text = [NSString stringWithFormat:@"%d %@", 1, TIMCommonLocalizableString(TUIKitSelected)];
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

- (void)messageMultiChooseViewOnCancelClicked:(TUIMessageMultiChooseView_Minimalist *)multiChooseView {
    [self openMultiChooseBoard:NO];
    [self.messageController enableMultiSelectedMode:NO];
}

- (void)messageMultiChooseViewOnRelayClicked:(TUIMessageMultiChooseView_Minimalist *)multiChooseView {
    NSArray *uiMsgs = [self.messageController multiSelectedResult:TUIMultiResultOptionAll];
    [self prepareForwardMessages:uiMsgs];
}

- (void)messageMultiChooseViewOnDeleteClicked:(TUIMessageMultiChooseView_Minimalist *)multiChooseView {
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

    BOOL hasUnsupportMsg = NO;
    for (TUIMessageCellData *data in uiMsgs) {
        if (data.status != Msg_Status_Succ) {
            hasUnsupportMsg = YES;
            break;
        }
    }

    if (hasUnsupportMsg) {
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
    [tipsVc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:tipsVc animated:YES completion:nil];
}

- (void)selectTarget:(BOOL)mergeForward toForwardMessage:(NSArray<TUIMessageCellData *> *)uiMsgs orForwardText:(NSString *)forwardText {
    __weak typeof(self) weakSelf = self;
    UIViewController *vc = (UIViewController *)[TUICore createObject:TUICore_TUIConversationObjectFactory_Minimalist
                                                                 key:TUICore_TUIConversationObjectFactory_ConversationSelectVC_Minimalist
                                                               param:nil];
    vc.navigateValueCallback = ^(NSDictionary *param) {
      NSArray<NSDictionary *> *selectList = param[TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList];
      NSMutableArray<TUIChatConversationModel *> *targetList = [NSMutableArray arrayWithCapacity:selectList.count];
      for (NSDictionary *selectItem in selectList) {
          TUIChatConversationModel *model = [TUIChatConversationModel new];
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
    };
    TUIFloatViewController *floatVC = [[TUIFloatViewController alloc] init];
    [floatVC appendChildViewController:(id)vc topMargin:kScale390(87.5)];
    [floatVC.topGestureView setTitleText:@""
                            subTitleText:@""
                             leftBtnText:TIMCommonLocalizableString(TUIKitCreateCancel)
                            rightBtnText:TIMCommonLocalizableString(MultiSelect)];
    floatVC.topGestureView.subTitleLabel.hidden = YES;
    [self presentViewController:floatVC
                       animated:YES
                     completion:^{
                       [weakSelf openMultiChooseBoard:NO];
                       [weakSelf.messageController enableMultiSelectedMode:NO];
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
          TUISendMessageAppendParams *appendParams = [[TUISendMessageAppendParams alloc] init];
          appendParams.isSendPushInfo = YES;
          appendParams.isOnlineUserOnly = NO;
          appendParams.priority = V2TIM_PRIORITY_NORMAL;
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
           * Forward to other chat user
           */
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
- (void)messageController:(TUIBaseMessageController_Minimalist *)controller onRelyMessage:(nonnull TUIMessageCellData *)data {
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
- (void)messageController:(TUIBaseMessageController_Minimalist *)controller onReferenceMessage:(TUIMessageCellData *)data {
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

#pragma mark - Translation forward
- (void)messageController:(TUIBaseMessageController_Minimalist *)controller onForwardText:(NSString *)text {
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
              // Send text to myself
              [self.messageController sendMessage:message];
          } else {
              // Send to other conversation
              message.needReadReceipt = self.conversationData.msgNeedReadReceipt && [TUIChatConfig defaultConfig].msgNeedReadReceipt;
              [TUIMessageBaseDataProvider sendMessage:message
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
- (void)didTapOnRestNameLabel:(TUIJoinGroupMessageCell_Minimalist *)cell withIndex:(NSInteger)index {
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
- (TUIChatMediaDataProvider *)mediaProvider {
    if (_mediaProvider == nil) {
        _mediaProvider = [[TUIChatMediaDataProvider alloc] init];
        _mediaProvider.listener = self;
        _mediaProvider.presentViewController = self;
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

@end
