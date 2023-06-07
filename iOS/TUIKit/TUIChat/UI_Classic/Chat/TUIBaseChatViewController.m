//
//  TUIBaseChatViewController.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIBaseChatViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIBaseMessageController.h"
#import "TUIImageMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "TUITextMessageCellData.h"
#import "TUIReplyMessageCellData.h"
#import <TIMCommon/TIMDefine.h>
#import "TUIMessageMultiChooseView.h"
#import "TUIMessageController.h"
#import "TUIChatDataProvider.h"
#import "TUIMessageDataProvider.h"
#import "TUICameraViewController.h"
#import <TUICore/TUITool.h>
#import <TUICore/TUICore.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIChatMediaDataProvider.h"
#import "TUIMessageReadViewController.h"
#import "TUIJoinGroupMessageCell.h"
#import "TUICloudCustomDataTypeCenter.h"
#import <TUICore/TUILogin.h>
#import "TUIChatConfig.h"
#import "TUIChatModifyMessageHelper.h"
#import "TUIAIDenoiseSignatureManager.h"
#import <TIMCommon/NSString+TUIEmoji.h>

static UIView *customTopView;

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
                                         TUIChatMediaDataListener>

@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) TUIMessageMultiChooseView *multiChooseView;
@property (nonatomic, assign) BOOL responseKeyboard;
@property (nonatomic, strong) TUIChatDataProvider *dataProvider;

@property (nonatomic, weak) UIViewController *forwardConversationSelectVC;
@property (nonatomic) NSArray<TUIMessageCellData *> *forwardSelectUIMsgs;
@property (nonatomic) BOOL isMergeForward;

@property (nonatomic, assign) BOOL firstAppear;

@property (nonatomic, copy) NSString *mainTitle;

@property (nonatomic, strong) UIImageView *backgroudView;

@property (nonatomic, copy) NSString *forwardText;

@property (nonatomic, strong) TUIChatMediaDataProvider *mediaProvider;

@end

@implementation TUIBaseChatViewController

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [TUIBaseChatViewController createCachePath];
        [[TUIAIDenoiseSignatureManager sharedInstance] updateSignature];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    self.mainTitle = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // data provider
    self.dataProvider = [[TUIChatDataProvider alloc] init];
    self.dataProvider.delegate = self;
    
    // setupUI
    self.firstAppear = YES;
    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#FFFFFF");
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self configBackgroundView];
    [self setupNavigator];
    if (customTopView) {
        [self setupCustomTopView];
    }
    [self setupMessageController];
    [self setupInputController];

    // Notify
    [self configNotify];
}

- (void)dealloc {
    [TUICore unRegisterEventByObject:self];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self saveDraft];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.responseKeyboard = YES;
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
    [self openMultiChooseBoard:NO];
    [self.messageController enableMultiSelectedMode:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.inputController.status == Input_Status_Input ||
        self.inputController.status == Input_Status_Input_Keyboard) {
        CGPoint offset = self.messageController.tableView.contentOffset;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.responseKeyboard = YES;
            [UIApplication.sharedApplication.keyWindow endEditing:YES];
            [strongSelf inputController:strongSelf.inputController didChangeHeight:CGRectGetMaxY(strongSelf.inputController.inputBar.frame) + Bottom_SafeHeight];
            [strongSelf.messageController.tableView setContentOffset:offset];
        });
    }
}

- (void)setupNavigator {
    TUINavigationController *naviController = (TUINavigationController *)self.navigationController;
    if ([naviController isKindOfClass:TUINavigationController.class]) {
        naviController.uiNaviDelegate = self;
    }
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"    ";
    __weak typeof (self)weakSelf = self;
    [[RACObserve(_conversationData, title) distinctUntilChanged] subscribeNext:^(NSString *title) {
        [weakSelf.titleView setTitle:title];
    }];
    
    [[RACObserve(_conversationData, otherSideTyping) distinctUntilChanged] subscribeNext:^(id otherSideTyping) {
        BOOL otherSideTypingFlag =  [otherSideTyping boolValue];
        if (!otherSideTypingFlag) {
            [weakSelf checkTitle:YES];
        }
    }];
    
    [self checkTitle:NO];
    
    [TUIChatDataProvider getTotalUnreadMessageCountWithSuccBlock:^(UInt64 totalCount) {
        [weakSelf onChangeUnReadCount:totalCount];
    } fail:nil];
    
    _unRead = [[TUIUnReadView alloc] init];

    CGSize itemSize = CGSizeMake(30, 30);
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
    NSArray<TUIExtensionInfo *> *extensionList = [TUICore getExtensionList:TUICore_TUIChatExtension_NavigationMoreItem_ClassicExtensionID param:param];
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

- (void)setupMessageController {
    TUIMessageController *vc = [[TUIMessageController alloc] init];
    vc.hightlightKeyword = self.highlightKeyword;
    vc.locateMessage = self.locateMessage;
    vc.isMsgNeedReadReceipt = [TUIChatConfig defaultConfig].msgNeedReadReceipt;
    _messageController = vc;
    _messageController.delegate = self;
    [_messageController setConversation:self.conversationData];
    _messageController.view.frame = CGRectMake(0,  [self topMarginByCustomView],
                                               self.view.frame.size.width,
                                               self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight - [self topMarginByCustomView]);
    [self addChildViewController:_messageController];
    [self.view addSubview:_messageController.view];
    [_messageController didMoveToParentViewController:self];
}

- (void)setupCustomTopView {
    [self.view addSubview:customTopView];
    customTopView.mm_top(0).mm_left(0);
}

- (void)setupInputController {
    _inputController = [[TUIInputController alloc] init];
    _inputController.delegate = self;
    @weakify(self)
    [RACObserve(self, moreMenus) subscribeNext:^(NSArray *x) {
        @strongify(self)
        [self.inputController.moreView setData:x];
    }];
    _inputController.view.frame = CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addChildViewController:_inputController];
    [self.view addSubview:_inputController.view];
    
    self.moreMenus = [self.dataProvider moreMenuCellDataArray:self.conversationData.groupID
                                                       userID:self.conversationData.userID
                                              isNeedVideoCall:[TUIChatConfig defaultConfig].enableVideoCall
                                              isNeedAudioCall:[TUIChatConfig defaultConfig].enableAudioCall
                                              isNeedGroupLive:NO
                                                   isNeedLink:[TUIChatConfig defaultConfig].enableWelcomeCustomMessage];
}

- (void)configBackgroundView {
    self.backgroudView = [[UIImageView alloc] init];
    self.backgroudView.backgroundColor = TUIChatConfig.defaultConfig.backgroudColor ? TUIChatConfig.defaultConfig.backgroudColor : TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    NSString *conversationID = [self getConversationID];
    NSString *imgUrl = [self getBackgroundImageUrlByConversationID:conversationID];

    if (TUIChatConfig.defaultConfig.backgroudImage) {
        self.backgroudView.backgroundColor = UIColor.clearColor;
        self.backgroudView.image = TUIChatConfig.defaultConfig.backgroudImage;
    }
    else if (IS_NOT_EMPTY_NSSTRING(imgUrl)) {
        [self.backgroudView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil];
    }
    self.backgroudView.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight);
    
    [self.view insertSubview:self.backgroudView atIndex:0];
}

- (void)configNotify {

    [[V2TIMManager sharedInstance] addConversationListener:self];
    [TUICore registerEvent:TUICore_TUIConversationNotify subKey:TUICore_TUIConversationNotify_SelectConversationSubKey object:self];
    [TUICore registerEvent:TUICore_TUIConversationNotify subKey:TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];

    [TUICore registerEvent:TUICore_TUIContactNotify subKey:TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey object:self];
    [TUICore registerEvent:TUICore_TUIGroupNotify subKey:TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey object:self];
}

#pragma mark - Public Methods

- (void)sendMessage:(V2TIMMessage *)message {
    [self.messageController sendMessage:message];
}

- (void)saveDraft {
    NSString *content = [self.inputController.inputBar.inputTextView.textStorage getPlainString];
    
    TUIReplyPreviewData * previewData = nil;
    if (self.inputController.referenceData) {
        previewData  = self.inputController.referenceData;
    }
    else if(self.inputController.replyData) {
        previewData  = self.inputController.replyData;
    }
    if (previewData) {
        
        NSDictionary *dict = @{
            @"content" : content?:@"",
            @"messageReply" : @{
                    @"messageID"       : previewData.msgID?:@"",
                    @"messageAbstract" : [previewData.msgAbstract?:@"" getInternationalStringWithfaceContent],
                    @"messageSender"   : previewData.sender?:@"",
                    @"messageType"     : @(previewData.type),
                    @"messageTime"     : @(previewData.originMessage.timestamp ? [previewData.originMessage.timestamp timeIntervalSince1970] : 0),  // Compatible for web
                    @"messageSequence" : @(previewData.originMessage.seq),// Compatible for web
                    @"version"         : @(kDraftMessageReplyVersion),
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
                
        NSMutableAttributedString *formatEmojiString = [draft getAdvancedFormatEmojiStringWithFont:kTUIInputNoramlFont textColor:kTUIInputNormalTextColor emojiLocations:nil];

        
        [self.inputController.inputBar.inputTextView.textStorage insertAttributedString:formatEmojiString atIndex:0];
        return;
    }
    
    /**
     * 显示草稿
     * Display draft
     */
    NSString *draftContent = [jsonDict.allKeys containsObject:@"content"] ? jsonDict[@"content"] : @"";
    
    NSMutableAttributedString *formatEmojiString = [draftContent getAdvancedFormatEmojiStringWithFont:kTUIInputNoramlFont textColor:kTUIInputNormalTextColor emojiLocations:nil];

    [self.inputController.inputBar.inputTextView.textStorage insertAttributedString:formatEmojiString atIndex:0];
    
    NSString *messageRootID = [jsonDict.allKeys containsObject:@"messageRootID"] ? jsonDict[@"messageRootID"] : @"";

    /**
     * 显示消息回复预览
     * Display message reply preview bar
     */
    if ([jsonDict isKindOfClass:NSDictionary.class] && [jsonDict.allKeys containsObject:@"messageReply"]) {
        NSDictionary *reply = jsonDict[@"messageReply"];
        if ([reply isKindOfClass:NSDictionary.class] &&
            [reply.allKeys containsObject:@"messageID"] &&
            [reply.allKeys containsObject:@"messageAbstract"] &&
            [reply.allKeys containsObject:@"messageSender"] &&
            [reply.allKeys containsObject:@"messageType"] &&
            [reply.allKeys containsObject:@"version"]) {
            NSInteger version = [reply[@"version"] integerValue];
            if (version <= kDraftMessageReplyVersion) {

                if (IS_NOT_EMPTY_NSSTRING(messageRootID)) {
                    TUIReplyPreviewData *replyData = [[TUIReplyPreviewData alloc] init];
                    replyData.msgID       = reply[@"messageID"];
                    replyData.msgAbstract = reply[@"messageAbstract"];
                    replyData.sender      = reply[@"messageSender"];
                    replyData.type        = [reply[@"messageType"] integerValue];
                    replyData.messageRootID = messageRootID;
                    [self.inputController showReplyPreview:replyData];
                }
                else {
                    TUIReferencePreviewData *replyData = [[TUIReferencePreviewData alloc] init];
                    replyData.msgID       = reply[@"messageID"];
                    replyData.msgAbstract = reply[@"messageAbstract"];
                    replyData.sender      = reply[@"messageSender"];
                    replyData.type        = [reply[@"messageType"] integerValue];
                    [self.inputController showReferencePreview:replyData];
                }
            }
        }
    }
}

+ (void)setCustomTopView:(UIView *)view {
    customTopView = view;
}

+ (UIView *)customTopView {
    return customTopView;
}

#pragma mark - Getters & Setters

- (void)setConversationData:(TUIChatConversationModel *)conversationData {
    _conversationData = conversationData;
}

- (CGFloat)topMarginByCustomView {
    return customTopView ? customTopView.mm_h: 0;
}

#pragma mark - Event Response
- (void)onChangeUnReadCount:(UInt64)totalCount {
    /**
     * 此处异步的原因：当前聊天页面连续频繁收到消息，可能还没标记已读，此时也会收到未读数变更。理论上此时未读数不会包括当前会话的。
     * The reason for the asynchrony here: The current chat page receives messages continuously and frequently, it may not be marked as read, and unread changes will also be received at this time. In theory, the unreads at this time will not include the current session.
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
                                             SuccBlock:^(V2TIMFriendInfoResult * _Nonnull friendInfoResult) {
                @strongify(self);
                if (friendInfoResult.relation & V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST
                    && friendInfoResult.friendInfo.friendRemark.length > 0) {
                    self.conversationData.title = friendInfoResult.friendInfo.friendRemark;
                } else {
                    [TUIChatDataProvider getUserInfoWithUserId:friendInfoResult.friendInfo.userID
                                                   SuccBlock:^(V2TIMUserFullInfo * _Nonnull userInfo) {
                        if (userInfo.nickName.length > 0) {
                            self.conversationData.title = userInfo.nickName;
                        }
                    } failBlock:nil];
                }
            } failBlock:nil];
        }
        else if (self.conversationData.groupID.length > 0) {
            [TUIChatDataProvider getGroupInfoWithGroupID:self.conversationData.groupID
                                             SuccBlock:^(V2TIMGroupInfoResult * _Nonnull groupResult) {
                if (groupResult.info.groupName.length > 0) {
                    self.conversationData.title = groupResult.info.groupName;
                }
            } failBlock:nil];
        }
    }
}

-(void)leftBarButtonClick {
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

- (void)getUserOrFriendProfileVCWithUserID:(NSString *)userID
                                 succBlock:(void(^)(UIViewController *vc))succ
                                 failBlock:(nullable V2TIMFail)fail {
    NSDictionary *param = @{
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userID ? : @"",
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ ? : ^(UIViewController *vc){},
        TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail ? : ^(int code, NSString * desc){}
    };
    [TUICore createObject:TUICore_TUIContactObjectFactory key:TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod param:param];
}

#pragma mark - TUICore notify

- (void)onNotifyEvent:(NSString *)key subKey:(NSString *)subKey object:(id)anObject param:(NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIConversationNotify]
        && [subKey isEqualToString:TUICore_TUIConversationNotify_SelectConversationSubKey]
        && self.forwardConversationSelectVC == anObject) {
        NSArray<NSDictionary *> *selectList = param[TUICore_TUIConversationNotify_SelectConversationSubKey_ConversationListKey];
        
        NSMutableArray<TUIChatConversationModel *> *targetList = [NSMutableArray arrayWithCapacity:selectList.count];
        for (NSDictionary *selectItem in selectList) {
            TUIChatConversationModel *model = [TUIChatConversationModel new];
            model.title = selectItem[TUICore_TUIConversationNotify_SelectConversationSubKey_ItemTitleKey];
            model.userID = selectItem[TUICore_TUIConversationNotify_SelectConversationSubKey_ItemUserIDKey];
            model.groupID = selectItem[TUICore_TUIConversationNotify_SelectConversationSubKey_ItemGroupIDKey];
            model.conversationID = selectItem[TUICore_TUIConversationNotify_SelectConversationSubKey_ItemConversationIDKey];
            [targetList addObject:model];
        }
        
        [self forwardMessages:self.forwardSelectUIMsgs toTargets:targetList merge:self.isMergeForward];
        self.forwardSelectUIMsgs = nil;
        
        if (self.forwardText.length > 0) {
            [self forwardText:self.forwardText toConverations:targetList];
            self.forwardText = nil;
        }
    }
    
    else if ([key isEqualToString:TUICore_TUIConversationNotify] && [subKey isEqualToString:TUICore_TUIConversationNotify_ClearConversationUIHistorySubKey]) {
        [self.messageController clearUImsg];
    }
    else if ([key isEqualToString:TUICore_TUIContactNotify]
             && [subKey isEqualToString:TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey]) {
        NSString *conversationID = param[TUICore_TUIContactNotify_UpdateConversationBackgroundImageSubKey_ConversationID];
        if (IS_NOT_EMPTY_NSSTRING(conversationID)) {
            [self updateBackgroundImageUrlByConversationID:conversationID];
        }
    }
    else if ([key isEqualToString:TUICore_TUIGroupNotify]
             && [subKey isEqualToString:TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey]) {
        NSString *conversationID = param[TUICore_TUIGroupNotify_UpdateConversationBackgroundImageSubKey_ConversationID];
        if (IS_NOT_EMPTY_NSSTRING(conversationID)) {
            [self updateBackgroundImageUrlByConversationID:conversationID];
        }
    }
}

- (void)updateBackgroundImageUrlByConversationID:(NSString *)conversationID {
    if ([[self getConversationID]  isEqualToString:conversationID]) {
        self.backgroudView.backgroundColor = UIColor.clearColor;
        NSString *imgUrl = [self getBackgroundImageUrlByConversationID:conversationID];
        if (IS_NOT_EMPTY_NSSTRING(imgUrl)) {
             [self.backgroudView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil];
        }
        else {
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
    NSString *conversationID_UserID = [NSString stringWithFormat:@"%@_%@",targerConversationID,[TUILogin getUserID]];
    if (![dict isKindOfClass:NSDictionary.class] || ![dict.allKeys containsObject:conversationID_UserID]) {
        return nil;
    }
    return [dict objectForKey:conversationID_UserID];
}

- (NSString *)getConversationID {
    NSString *conversationID = @"";
    if (self.conversationData.conversationID.length > 0) {
        conversationID = self.conversationData.conversationID;
    }
    else if (self.conversationData.userID.length > 0) {
        conversationID = [NSString stringWithFormat:@"c2c_%@",self.conversationData.userID];
    }
    else if (self.conversationData.groupID.length > 0) {
        conversationID = [NSString stringWithFormat:@"group_%@",self.conversationData.groupID];
    }
    return conversationID;
}

#pragma mark - TUIInputControllerDelegate
- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height {
    if (!self.responseKeyboard) {
        return;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = self.messageController.view.frame;
        msgFrame.size.height = self.view.frame.size.height - height - [self topMarginByCustomView];
        self.messageController.view.frame = msgFrame;

        CGRect inputFrame = self.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        self.inputController.view.frame = inputFrame;
        [self.messageController scrollToBottom:NO];
    } completion:nil];
}

- (void)inputController:(TUIInputController *)inputController didSendMessage:(V2TIMMessage *)msg {
    [self.messageController sendMessage:msg];
}

- (void)inputControllerDidInputAt:(TUIInputController *)inputController {
    /**
     * 交给 GroupChatVC 去处理
     * Handle to GroupChatVC
     */
}

- (void)inputController:(TUIInputController *)inputController didDeleteAt:(NSString *)atText {
    /**
     * 交给 GroupChatVC 去处理
     * Handle to GroupChatVC
     */
}

- (void)inputControllerBeginTyping:(TUIInputController *)inputController {
    
    //for C2CChatVC
}

- (void)inputControllerEndTyping:(TUIInputController *)inputController {
    //for C2CChatVC
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

#pragma mark - TUIBaseMessageControllerDelegate
- (void)didTapInMessageController:(TUIBaseMessageController *)controller {
    [self.inputController reset];
}

- (BOOL)messageController:(TUIBaseMessageController *)controller willShowMenuInCell:(TUIMessageCell *)cell {
    if([self.inputController.inputBar.inputTextView isFirstResponder]){
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
    if([cell isKindOfClass:[TUIJoinGroupMessageCell class]]){
        TUIJoinGroupMessageCell *joinCell = (TUIJoinGroupMessageCell *)cell;
        joinCell.joinGroupDelegate = self;
    }
}

- (void)messageController:(TUIBaseMessageController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell {
    if (cell.messageData.identifier == nil) {
        return;
    }
    [self getUserOrFriendProfileVCWithUserID:cell.messageData.identifier
                                   succBlock:^(UIViewController *vc) {
        [self.navigationController pushViewController:vc animated:YES];
    } failBlock:nil];
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

- (void)onSelectFileMoreCellData {
    [self.mediaProvider selectFile];
}

#pragma mark - TUINavigationControllerDelegate
- (void)navigationControllerDidClickLeftButton:(TUINavigationController *)controller {
    if (controller.currentShowVC == self) {
        [self.messageController readReport];
    }
}

- (void)navigationControllerDidSideSlideReturn:(TUINavigationController *)controller
                            fromViewController:(UIViewController *)fromViewController {
    if ([fromViewController isEqual:self]) {
        [self.messageController readReport];
    }
}

#pragma mark - 消息菜单操作: 多选 & 转发
- (void)onSelectMessageMenu:(NSInteger)menuType withData:(TUIMessageCellData *)data {
    if (menuType == 0) {
        [self openMultiChooseBoard:YES];
    } else if (menuType == 1) {
        if (data == nil) {
            return;
        }
        NSMutableArray *uiMsgs = [NSMutableArray arrayWithArray:@[data]];
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
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitRelayUnsupportForward) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    if (!canForwardMsg) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitRelayPluginNotAllowed) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void(^chooseTarget)(BOOL) = ^(BOOL mergeForward) {
        
        UIViewController * vc = (UIViewController *)[TUICore createObject:TUICore_TUIConversationObjectFactory key:TUICore_TUIConversationObjectFactory_GetConversationSelectControllerMethod param:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:(UIViewController *)vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        weakSelf.forwardConversationSelectVC = (UIViewController *)vc;
        weakSelf.forwardSelectUIMsgs = uiMsgs;
        weakSelf.isMergeForward = mergeForward;
        [weakSelf presentViewController:nav animated:YES completion:nil];
    };
    
    UIAlertController *tipsVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    /**
     * 逐条转发
     * Forward one-by-one
     */
    [tipsVc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitRelayOneByOneForward) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (uiMsgs.count <= 30) {
            chooseTarget(NO);
            return;
        }
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitRelayOneByOnyOverLimit) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleDefault handler:nil]];
        [vc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitRelayCombineForwad) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            chooseTarget(YES);
        }]];
        [weakSelf presentViewController:vc animated:YES completion:nil];
    }]];
    
    /**
     * 合并转发
     * Merge-forward
     */
    [tipsVc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitRelayCombineForwad) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        chooseTarget(YES);
    }]];
    [tipsVc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:tipsVc animated:YES completion:nil];
}

- (void)forwardMessages:(NSArray<TUIMessageCellData *> *)uiMsgs
              toTargets:(NSArray<TUIChatConversationModel *> *)targets
                  merge:(BOOL)merge {
    if (uiMsgs.count == 0 || targets.count == 0) {
        return ;
    }
    
    @weakify(self);
    [self.dataProvider getForwardMessageWithCellDatas:uiMsgs
                                            toTargets:targets
                                                Merge:merge
                                          ResultBlock:^(TUIChatConversationModel * _Nonnull targetConversation, NSArray<V2TIMMessage *> * _Nonnull msgs) {
        @strongify(self);
        
        TUIChatConversationModel *convCellData = targetConversation;
        NSTimeInterval timeInterval = convCellData.groupID.length?0.09:0.05;
        
        /**
         * 发送到当前聊天窗口
         * Forward to currernt chat vc
         */
        if ([convCellData.conversationID isEqualToString:self.conversationData.conversationID]) {
            for (V2TIMMessage *imMsg in msgs) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    /**
                     * 下面的函数涉及到 UI 的刷新，要放在主线程操作
                     * The following functions involve the refresh of the UI and should be called on the main thread
                     */
                    [self.messageController sendMessage:imMsg];
                });
                
                /**
                 * 此处的延时操作是为了在批量逐条转发时，尽可能保证接收端的顺序
                 * The delay here is to ensure the order of the receiving end as much as possible when forwarding in batches one by one
                 */
                [NSThread sleepForTimeInterval:timeInterval];
            }
            return;
        }
        
        /**
         * 发送到其他聊天
         * Forward to other chat user
         */
        for (V2TIMMessage *message in msgs) {
            message.needReadReceipt = [TUIChatConfig defaultConfig].msgNeedReadReceipt;
            [TUIMessageDataProvider sendMessage:message
                                 toConversation:convCellData
                                 isSendPushInfo:YES
                               isOnlineUserOnly:NO
                                       priority:V2TIM_PRIORITY_NORMAL
                                       Progress:nil
                                      SuccBlock:^{
                /**
                 * 发送到其他聊天的消息需要广播消息发送状态，方便进入对应聊天后刷新消息状态
                 * Messages sent to other chats need to broadcast the message sending status, which is convenient to refresh the message status after entering the corresponding chat
                 */
                [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged object:message.msgID];
            } FailBlock:^(int code, NSString *desc) {
                [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged object:message.msgID];
            }];
            
            /**
             * 此处的延时操作是为了在批量逐条转发时，尽可能保证接收端的顺序
             * The delay here is to ensure the order of the receiving end as much as possible when forwarding in batches one by one
             */
            [NSThread sleepForTimeInterval:timeInterval];
        }
    } fail:^(int code, NSString *desc) {
        NSLog(@"%@", desc);
        NSAssert(NO, desc);
    }];
}

- (NSString *)forwardTitleWithMyName:(NSString *)nameStr {
    return @"";
}

#pragma mark - Message reply
- (void)messageController:(TUIBaseMessageController *)controller onRelyMessage:(nonnull TUIMessageCellData *)data {
    @weakify(self)
    [self.inputController exitReplyAndReference:^{
        @strongify(self)
        NSString *desc = @"";
        desc = [self replyReferenceMessageDesc:data];
        
        TUIReplyPreviewData *replyData = [[TUIReplyPreviewData alloc] init];
        replyData.msgID = data.msgID;
        replyData.msgAbstract = desc;
        replyData.sender = data.name;
        replyData.type = (NSInteger)data.innerMessage.elemType;
        replyData.originMessage = data.innerMessage;
        
        NSMutableDictionary *cloudResultDic = [[NSMutableDictionary alloc] initWithCapacity:5];
        if (replyData.originMessage.cloudCustomData) {
            NSDictionary * originDic = [TUITool jsonData2Dictionary:replyData.originMessage.cloudCustomData];
            if (originDic && [originDic isKindOfClass:[NSDictionary class]]) {
                [cloudResultDic addEntriesFromDictionary:originDic];
            }
        }
        NSString * messageParentReply = cloudResultDic[@"messageReply"];
        NSString * messageRootID = [messageParentReply valueForKey:@"messageRootID"];
        if (!IS_NOT_EMPTY_NSSTRING(messageRootID)) {
            /**
             * 源消息没有 messageRootID， 则需要将当前源消息的 msgID 作为 root
             * If the original message does not have messageRootID, you need to make the msgID of the current original message as the root
             */
            if (IS_NOT_EMPTY_NSSTRING(replyData.originMessage.msgID)) {
                messageRootID = replyData.originMessage.msgID;
            }
        }
        
        replyData.messageRootID =  messageRootID;
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
    @weakify(self)
    [self.inputController exitReplyAndReference:^{
        @strongify(self)
        NSString *desc = @"";
        desc = [self replyReferenceMessageDesc:data];
        
        TUIReferencePreviewData *referenceData = [[TUIReferencePreviewData alloc] init];
        referenceData.msgID = data.msgID;
        referenceData.msgAbstract = desc;
        referenceData.sender = data.name;
        referenceData.type = (NSInteger)data.innerMessage.elemType;
        referenceData.originMessage = data.innerMessage;
        [self.inputController showReferencePreview:referenceData];
    }];
}

#pragma mark - Message react
/*
 "messageReact": {
     "reacts": [
         {
             "emojiId1": ["userId1","userId2"]
         },
         {
             "emojiId2": ["userId3","userId4"]
         },
     ],
     "version": "1",
 }
 */
- (void)messageController:(TUIBaseMessageController *)controller modifyMessage:(nonnull TUIMessageCellData *)cellData reactEmoji:(NSString *)emojiName{
    
    V2TIMMessage *rootMsg = cellData.innerMessage;

    [[TUIChatModifyMessageHelper defaultHelper] modifyMessage:rootMsg reactEmoji:emojiName];
}

#pragma mark - Message translation forward
- (void)messageController:(TUIBaseMessageController *)controller onForwardText:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    self.forwardText = text;
    [self presentConverationSelectVC];
}

- (void)presentConverationSelectVC {
    UIViewController *vc = (UIViewController *)[TUICore createObject:TUICore_TUIConversationObjectFactory key:TUICore_TUIConversationObjectFactory_GetConversationSelectControllerMethod param:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:(UIViewController *)vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    self.forwardConversationSelectVC = (UIViewController *)vc;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)forwardText:(NSString *)text toConverations:(NSArray <TUIChatConversationModel *> *)conversations {
    for (TUIChatConversationModel *conversation in conversations) {
        V2TIMMessage *message = [[V2TIMManager sharedInstance] createTextMessage:text];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([conversation.conversationID isEqualToString:self.conversationData.conversationID]) {
                // Send forward text to myself
                [self.messageController sendMessage:message];
            } else {
                // Send to other conversation
                message.needReadReceipt = [TUIChatConfig defaultConfig].msgNeedReadReceipt;
                [TUIMessageDataProvider sendMessage:message
                                     toConversation:conversation
                                     isSendPushInfo:YES
                                   isOnlineUserOnly:NO
                                           priority:V2TIM_PRIORITY_NORMAL
                                           Progress:nil
                                          SuccBlock:^{
                    [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged
                                                                      object:message.msgID];
                } FailBlock:^(int code, NSString *desc) {
                    [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged
                                                                      object:message.msgID];
                }];
            }
        });
    }
}

#pragma mark - Private Methods
+ (void)createCachePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:TUIKit_Image_Path]){
        [fileManager createDirectoryAtPath:TUIKit_Image_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_Video_Path]){
        [fileManager createDirectoryAtPath:TUIKit_Video_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_Voice_Path]){
        [fileManager createDirectoryAtPath:TUIKit_Voice_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_File_Path]){
        [fileManager createDirectoryAtPath:TUIKit_File_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:TUIKit_DB_Path]){
        [fileManager createDirectoryAtPath:TUIKit_DB_Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - TUIJoinGroupMessageCellDelegate
- (void)didTapOnRestNameLabel:(TUIJoinGroupMessageCell *)cell withIndex:(NSInteger)index{
    NSString *userId = cell.joinData.userIDList[index];
    
    [self getUserOrFriendProfileVCWithUserID:userId succBlock:^(UIViewController *vc) {
        [self.navigationController pushViewController:vc animated:YES];
    } failBlock:^(int code, NSString *desc) {
        [TUITool makeToastError:code msg:desc];
    }];
}

#pragma mark - V2TIMConversationListener
- (void)onConversationChanged:(NSArray<V2TIMConversation*> *) conversationList {
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

- (void)onProvideVideo:(NSString *)videoUrl snapshot:(NSString *)snapshotUrl duration:(NSInteger)duration {
    V2TIMMessage *message = [V2TIMManager.sharedInstance createVideoMessage:videoUrl type:videoUrl.pathExtension duration:(int)duration snapshotPath:snapshotUrl];
    [self sendMessage:message];
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
