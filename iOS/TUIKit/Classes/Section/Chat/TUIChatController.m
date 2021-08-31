//
//  TUIChatController.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIChatController.h"
#import "THeader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIGroupPendencyViewModel.h"
#import "TUIMessageController.h"
#import "TUISelectGroupMemberViewController.h"
#import "TUITextMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIVoiceMessageCellData.h"
#import "TUIGroupPendencyController.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "UIColor+TUIDarkMode.h"
#import "TUIKit.h"
#import "TUIMessageMultiChooseView.h"
#import "TUIConversationSelectController.h"
#import "TUIMessageDataProviderService.h"
#import "TIMMessage+DataProvider.h"
#import "V2TUIMessageController.h"
#import "TUIKitListenerManager.h"
#import "TUICameraViewController.h"

@interface TUIChatController () <TMessageControllerDelegate, TInputControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, TUIMessageMultiChooseViewDelegate, TUICameraViewControllerDelegate>
@property (nonatomic, strong) UIView *tipsView;
@property (nonatomic, strong) UILabel *pendencyLabel;
@property (nonatomic, strong) UIButton *pendencyBtn;
@property (nonatomic, strong) UIButton *atBtn;
@property (nonatomic, strong) TUIMessageMultiChooseView *multiChooseView;
@property (nonatomic, strong) TUIGroupPendencyViewModel *pendencyViewModel;
@property (nonatomic, strong) NSMutableArray<UserModel *> *atUserList;
@property (nonatomic, assign) BOOL responseKeyboard;
// @{@"serviceID" : serviceID, @"title" : @"视频通话", @"image" : image}
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *resgisterParam;
@end

@implementation TUIChatController
{
    TUIConversationCellData *_conversationData;
}

- (void)setConversationData:(TUIConversationCellData *)conversationData {
    _conversationData = conversationData;
    self.resgisterParam = [NSMutableArray array];
    
    NSMutableArray *moreMenus = [NSMutableArray array];
    [moreMenus addObject:[TUIInputMoreCellData photoData]];
    [moreMenus addObject:[TUIInputMoreCellData pictureData]];
    [moreMenus addObject:[TUIInputMoreCellData videoData]];
    [moreMenus addObject:[TUIInputMoreCellData fileData]];
    
    NSMutableArray *highMenus = [NSMutableArray array];
    NSMutableArray *nomalMenus = [NSMutableArray array];
    NSMutableArray *lowMenus = [NSMutableArray array];
    NSMutableArray *lowestMenus = [NSMutableArray array];
    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if (delegate && [delegate respondsToSelector:@selector(chatController:onRegisterMoreCell:)]) {
            MoreCellPriority priority = MoreCellPriority_Low;
            NSArray *menusData = [delegate chatController:self onRegisterMoreCell:&priority];
            BOOL isInvalidData = NO;
            for (NSObject *data in menusData) {
                if (![data isKindOfClass:[TUIInputMoreCellData class]]) {
                    isInvalidData = YES;
                    break;
                }
            }
            if (isInvalidData) {
                NSLog(@"input cell data is invalid");
                continue;
            }
            if (priority == MoreCellPriority_High) {
                [highMenus addObjectsFromArray:menusData];
            } else if (priority == MoreCellPriority_Nomal) {
                [nomalMenus addObjectsFromArray:menusData];
            } else if (priority == MoreCellPriority_Low) {
                [lowMenus addObjectsFromArray:menusData];
            }  else if (priority == MoreCellPriority_Lowest) {
                [lowestMenus addObjectsFromArray:menusData];
            }
        }
    }
    [moreMenus addObjectsFromArray:highMenus];
    [moreMenus addObjectsFromArray:nomalMenus];
    [moreMenus addObjectsFromArray:lowMenus];
    [moreMenus addObjectsFromArray:lowestMenus];
    
    _moreMenus = moreMenus;

    if (self.conversationData.groupID.length > 0) {
        _pendencyViewModel = [TUIGroupPendencyViewModel new];
        _pendencyViewModel.groupId = _conversationData.groupID;
    }
    
    self.atUserList = [NSMutableArray array];
}

- (TUIConversationCellData *)conversationData {
    return _conversationData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.responseKeyboard = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.responseKeyboard = NO;
    [self openMultiChooseBoard:NO];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [self saveDraft];
    }
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    @weakify(self)
    //message
    if (self.locateMessage) {
        V2TUIMessageController *vc = [[V2TUIMessageController alloc] init];
        vc.hightlightKeyword = self.highlightKeyword;
        vc.locateMessage = self.locateMessage;
        _messageController = vc;
        
    }else {
        _messageController = [[TUIMessageController alloc] init];
    }
    _messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight);
    _messageController.delegate = self;
    [self addChildViewController:_messageController];
    [self.view addSubview:_messageController.view];
    [_messageController setConversation:self.conversationData];

    //input
    _inputController = [[TUIInputController alloc] init];
    _inputController.view.frame = CGRectMake(0, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight, self.view.frame.size.width, TTextView_Height + Bottom_SafeHeight);
    _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _inputController.delegate = self;
    [RACObserve(self, moreMenus) subscribeNext:^(NSArray *x) {
        @strongify(self)
        [self.inputController.moreView setData:x];
    }];
    [self addChildViewController:_inputController];
    [self.view addSubview:_inputController.view];
    _inputController.inputBar.inputTextView.text = self.conversationData.draftText;
    self.tipsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tipsView.backgroundColor = RGB(246, 234, 190);
    [self.view addSubview:self.tipsView];
    self.tipsView.mm_height(24).mm_width(self.view.mm_w);

    self.pendencyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.tipsView addSubview:self.pendencyLabel];
    self.pendencyLabel.font = [UIFont systemFontOfSize:12];


    self.pendencyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.tipsView addSubview:self.pendencyBtn];
    [self.pendencyBtn setTitle:TUILocalizableString(TUIKitChatPendencyTitle) forState:UIControlStateNormal];
    [self.pendencyBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.pendencyBtn addTarget:self action:@selector(openPendency:) forControlEvents:UIControlEventTouchUpInside];
    [self.pendencyBtn sizeToFit];
    self.tipsView.hidden = YES;


    [RACObserve(self.pendencyViewModel, unReadCnt) subscribeNext:^(NSNumber *unReadCnt) {
        @strongify(self)
        if ([unReadCnt intValue]) {
            self.pendencyLabel.text = [NSString stringWithFormat:TUILocalizableString(TUIKitChatPendencyRequestToJoinGroupFormat), unReadCnt]; ; // @"%@条入群请求"
            [self.pendencyLabel sizeToFit];
            CGFloat gap = (self.tipsView.mm_w - self.pendencyLabel.mm_w - self.pendencyBtn.mm_w-8)/2;
            self.pendencyLabel.mm_left(gap).mm__centerY(self.tipsView.mm_h/2);
            self.pendencyBtn.mm_hstack(8);

            [UIView animateWithDuration:1.f animations:^{
                self.tipsView.hidden = NO;
                self.tipsView.mm_top(self.navigationController.navigationBar.mm_maxY);
            }];
        } else {
            self.tipsView.hidden = YES;
        }
    }];
    [self getPendencyList];
    
    //监听入群请求通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPendencyList) name:TUIKitNotification_onReceiveJoinApplication object:nil];
    
    //群 @ ,UI 细节比较多，放在二期实现
//    if (self.conversationData.groupID.length > 0 && self.conversationData.atMsgSeqList.count > 0) {
//        self.atBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.mm_w - 100, 100, 100, 40)];
//        [self.atBtn setTitle:@"有人@我" forState:UIControlStateNormal];
//        [self.atBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        [self.atBtn setBackgroundColor:[UIColor whiteColor]];
//        [self.atBtn addTarget:self action:@selector(loadMessageToAT) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_atBtn];
//    }
}

- (void)getPendencyList
{
    if (self.conversationData.groupID.length > 0)
        [self.pendencyViewModel loadData];
}

- (void)openPendency:(id)sender
{
    TUIGroupPendencyController *vc = [[TUIGroupPendencyController alloc] init];
    vc.viewModel = self.pendencyViewModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height
{
    if (!self.responseKeyboard) {
        return;
    }
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = ws.messageController.view.frame;
        msgFrame.size.height = ws.view.frame.size.height - height;
        ws.messageController.view.frame = msgFrame;

        CGRect inputFrame = ws.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        ws.inputController.view.frame = inputFrame;
        [ws.messageController scrollToBottom:NO];
    } completion:nil];
}

- (void)inputController:(TUIInputController *)inputController didSendMessage:(TUIMessageCellData *)msg
{
    if ([msg isKindOfClass:[TUITextMessageCellData class]]) {
        NSMutableArray *userIDList = [NSMutableArray array];
        for (UserModel *model in self.atUserList) {
            [userIDList addObject:model.userId];
        }
        if (userIDList.count > 0) {
            [msg setAtUserList:userIDList];
        }
        //消息发送完后 atUserList 要重置
        [self.atUserList removeAllObjects];
    }
    [_messageController sendMessage:msg];
    
    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if (delegate && [delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
            [delegate chatController:self didSendMessage:msg];
        }
    }
}

- (void)inputControllerDidInputAt:(TUIInputController *)inputController
{
    // 检测到 @ 字符的输入
    if (_conversationData.groupID.length > 0) {
        if ([self.navigationController.topViewController isKindOfClass:TUISelectGroupMemberViewController.class]) {
            return;
        }
        TUISelectGroupMemberViewController *vc = [[TUISelectGroupMemberViewController alloc] init];
        vc.groupId = _conversationData.groupID;
        vc.name = TUILocalizableString(TUIKitAtSelectMemberTitle); // @"选择群成员";
        vc.optionalStyle = TUISelectMemberOptionalStyleAtAll;
        vc.selectedFinished = ^(NSMutableArray<UserModel *> * _Nonnull modelList) {
            NSMutableString *atText = [[NSMutableString alloc] init];
            for (int i = 0; i < modelList.count; i++) {
                UserModel *model = modelList[i];
                [self.atUserList addObject:model];
                if (i == 0) {
                    [atText appendString:[NSString stringWithFormat:@"%@ ",model.name]];
                } else {
                    [atText appendString:[NSString stringWithFormat:@"@%@ ",model.name]];
                }
            }
            NSString *inputText = self.inputController.inputBar.inputTextView.text;
            self.inputController.inputBar.inputTextView.text = [NSString stringWithFormat:@"%@%@ ",inputText,atText];
            [self.inputController.inputBar updateTextViewFrame];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)inputController:(TUIInputController *)inputController didDeleteAt:(NSString *)atText
{
    // 删除了 @ 信息，atText 格式为：@xxx空格
    for (UserModel *user in self.atUserList) {
        if ([atText rangeOfString:user.name].location != NSNotFound) {
            [self.atUserList removeObject:user];
            break;
        }
    }
}

- (void)sendMessage:(TUIMessageCellData *)message
{
    [_messageController sendMessage:message];
}

#pragma mark - TMessageControllerDelegate
- (void)saveDraft
{
    NSString *draft = self.inputController.inputBar.inputTextView.text;
    draft = [draft stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
    [[V2TIMManager sharedInstance] setConversationDraft:self.conversationData.conversationID draftText:draft succ:nil fail:nil];
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell
{
    cell.disableDefaultSelectAction = NO;
    
    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if(delegate && [delegate respondsToSelector:@selector(chatController:onSelectMoreCell:)]){
            [delegate chatController:self onSelectMoreCell:cell];
        }
    }
    
    if (cell.disableDefaultSelectAction) {
        return;
    }
    if (cell.data == [TUIInputMoreCellData photoData]) {
        [self selectPhotoForSend];
    }
    else if (cell.data == [TUIInputMoreCellData videoData]) {
        [self takeVideoForSend];
    }
    else if (cell.data == [TUIInputMoreCellData fileData]) {
        [self selectFileForSend];
    }
    else if (cell.data == [TUIInputMoreCellData pictureData]) {
        [self takePictureForSend];
    }
}

- (void)didTapInMessageController:(TUIMessageController *)controller
{
    [_inputController reset];
}

- (BOOL)messageController:(TUIMessageController *)controller willShowMenuInCell:(TUIMessageCell *)cell
{
    if([_inputController.inputBar.inputTextView isFirstResponder]){
        _inputController.inputBar.inputTextView.overrideNextResponder = cell;
        return YES;
    }
    return NO;
}

- (TUIMessageCellData *)messageController:(TUIMessageController *)controller onNewMessage:(V2TIMMessage *)data
{
    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if ([delegate respondsToSelector:@selector(chatController:onNewMessage:)]) {
            TUIMessageCellData *cellData = [delegate chatController:self onNewMessage:data];
            if (cellData) {
                return cellData;
            }
        }
    }
    return nil;
}

- (TUIMessageCell *)messageController:(TUIMessageController *)controller onShowMessageData:(TUIMessageCellData *)data
{
    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if ([delegate respondsToSelector:@selector(chatController:onShowMessageData:)]) {
            TUIMessageCell *cell = [delegate chatController:self onShowMessageData:data];
            if (cell) {
                return cell;
            }
        }
    }
    return nil;
}

- (void)messageController:(TUIMessageController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell
{
    if (cell.messageData.identifier == nil)
        return;

    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if ([delegate respondsToSelector:@selector(chatController:onSelectMessageAvatar:)]) {
            [delegate chatController:self onSelectMessageAvatar:cell];
            return;
        }
    }

    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendsInfo:@[cell.messageData.identifier] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        V2TIMFriendInfoResult *result = resultList.firstObject;
        if (result.relation == V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST || result.relation == V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY) {
            @strongify(self)
            id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
            if ([vc isKindOfClass:[UIViewController class]]) {
                vc.friendProfile = result.friendInfo;
                [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
            }
        } else {
            [[V2TIMManager sharedInstance] getUsersInfo:@[cell.messageData.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                @strongify(self)
                id<TUIUserProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
                if ([vc isKindOfClass:[UIViewController class]]) {
                    vc.userFullInfo = infoList.firstObject;
                    if ([vc.userFullInfo.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                        vc.actionType = PCA_NONE;
                    } else {
                        vc.actionType = PCA_ADD_FRIEND;
                    }
                    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                }
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)messageController:(TUIMessageController *)controller onSelectMessageContent:(TUIMessageCell *)cell
{
    cell.disableDefaultSelectAction = NO;
    
    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if ([delegate respondsToSelector:@selector(chatController:onSelectMessageContent:)]) {
            [delegate chatController:self onSelectMessageContent:cell];
        }
    }
    if (cell.disableDefaultSelectAction) {
        return;
    }
}

- (void)messageController:(TUIMessageController *)controller onSelectMessageMenu:(NSInteger)menuType withData:(TUIMessageCellData *)data
{
    [self onSelectMessageMenu:menuType withData:data];
}

- (void)didHideMenuInMessageController:(TUIMessageController *)controller
{
    _inputController.inputBar.inputTextView.overrideNextResponder = nil;
}

#pragma mark - Event Response
- (void)selectPhotoForSend
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)takePictureForSend
{
    TUICameraViewController *vc = [[TUICameraViewController alloc] init];
    vc.type = TUICameraMediaTypePhoto;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)takeVideoForSend
{
    TUICameraViewController *vc = [[TUICameraViewController alloc] init];
    vc.type = TUICameraMediaTypeVideo;
    vc.videoMinimumDuration = 1.5;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectFileForSend
{
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeData] inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];

}

#pragma mark - TUICameraViewControllerDelegate
- (void)cameraViewController:(TUICameraViewController *)controller didFinishPickingMediaWithVideoURL:(NSURL *)url {
    [self transcodeIfNeed:url];
}

- (void)cameraViewController:(TUICameraViewController *)controller didFinishPickingMediaWithImage:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 0.75);
    NSString *path = [TUIKit_Image_Path stringByAppendingString:[THelper genImageName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    
    TUIImageMessageCellData *uiImage = [[TUIImageMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    uiImage.path = path;
    uiImage.length = data.length;
    [self sendMessage:uiImage];
    
    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if (delegate && [delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
            [delegate chatController:self didSendMessage:uiImage];
        }
    }
}

- (void)cameraViewControllerDidCancel:(TUICameraViewController *)controller {
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 快速点的时候会回调多次
    @weakify(self)
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation = image.imageOrientation;
            if(imageOrientation != UIImageOrientationUp)
            {
                CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height );
                CGFloat aspectWidth = image.size.width * aspectRatio;
                CGFloat aspectHeight = image.size.height * aspectRatio;

                UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
                [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }

            NSData *data = UIImageJPEGRepresentation(image, 0.75);
            NSString *path = [TUIKit_Image_Path stringByAppendingString:[THelper genImageName:nil]];
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            
            TUIImageMessageCellData *uiImage = [[TUIImageMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            uiImage.path = path;
            uiImage.length = data.length;
            [self sendMessage:uiImage];
            
            for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
                if (delegate && [delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                    [delegate chatController:self didSendMessage:uiImage];
                }
            }
        }
        else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            if (url) {
                [self transcodeIfNeed:url];
                return;
            }
            
            // 在某些情况下，UIImagePickerControllerMediaURL 可能为空，使用 UIImagePickerControllerPHAsset
            PHAsset *asset = nil;
            if (@available(iOS 11.0, *)) {
                asset = [info objectForKey:UIImagePickerControllerPHAsset];
            }
            if (asset) {
                [self originURLWithAsset:asset completion:^(BOOL success, NSURL *URL) {
                    if (success) {
                        [self transcodeIfNeed:URL];
                        return;
                    }
                }];
                return;
            }
            
            // 在 ios 12 的情况下，UIImagePickerControllerMediaURL 及 UIImagePickerControllerPHAsset 可能为空，需要使用其他方式获取视频文件原始路径
            url = [info objectForKey:UIImagePickerControllerReferenceURL];
            if (url) {
                [self originURLWithRefrenceURL:url completion:^(BOOL success, NSURL *URL) {
                    if (success) {
                        [self transcodeIfNeed:URL];
                    }
                }];
                return;
            }
            
            // 其他，不支持
            [self.view makeToast:@"not support this video"];
        }
    }];
}

// 根据 UIImagePickerControllerReferenceURL 获取原始文件路径
- (void)originURLWithRefrenceURL:(NSURL *)URL completion:(void(^)(BOOL success, NSURL *URL))completion
{
    if (completion == nil) {
        return;
    }
    NSDictionary *queryInfo = [self dictionaryWithURLQuery:URL.query];
    NSString *fileName = @"temp.mp4";
    if ([queryInfo.allKeys containsObject:@"id"] && [queryInfo.allKeys containsObject:@"ext"]) {
        fileName = [NSString stringWithFormat:@"%@.%@", queryInfo[@"id"], [queryInfo[@"ext"] lowercaseString]];
    }
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [tempPath stringByAppendingPathComponent:fileName];
    if ([NSFileManager.defaultManager isDeletableFileAtPath:filePath]) {
        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
    }
    NSURL *newUrl = [NSURL fileURLWithPath:filePath];
    ALAssetsLibrary *assetLibrary= [[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:URL resultBlock:^(ALAsset *asset) {
        if (asset == nil) {
            completion(NO, nil);
            return;
        }
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
        BOOL flag = [NSFileManager.defaultManager createFileAtPath:filePath contents:data attributes:nil];
        completion(flag, newUrl);
    } failureBlock:^(NSError *err) {
        completion(NO, nil);
    }];
}

- (void)originURLWithAsset:(PHAsset *)asset completion:(void(^)(BOOL success, NSURL *URL))completion
{
    if (completion == nil) {
        return;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            completion(NO, nil);
            return;
        }
        
        NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
        if (resources.count == 0) {
            completion(NO, nil);
            return;
        }
        
        PHAssetResourceRequestOptions *options = [[PHAssetResourceRequestOptions alloc] init];
        options.networkAccessAllowed = NO;
        __block BOOL invoked = NO;
        [PHAssetResourceManager.defaultManager requestDataForAssetResource:resources.firstObject options:options dataReceivedHandler:^(NSData * _Nonnull data) {
            // 此处会有重复回调的问题
            if (invoked) {
                return;
            }
            invoked = YES;
            if (data == nil) {
                completion(NO, nil);
                return;
            }
            NSString *fileName = @"temp.mp4";
            NSString* tempPath = NSTemporaryDirectory();
            NSString *filePath = [tempPath stringByAppendingPathComponent:fileName];
            if ([NSFileManager.defaultManager isDeletableFileAtPath:filePath]) {
                [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
            }
            NSURL *newUrl = [NSURL fileURLWithPath:filePath];
            BOOL flag = [NSFileManager.defaultManager createFileAtPath:filePath contents:data attributes:nil];
            completion(flag, newUrl);
        } completionHandler:^(NSError * _Nullable error) {
            completion(NO, nil);
        }];
    }];
}

// 获取 NSURL 查询字符串信息
- (NSDictionary *)dictionaryWithURLQuery:(NSString *)query
{
    NSArray *components = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *item in components) {
        NSArray *subs = [item componentsSeparatedByString:@"="];
        if (subs.count == 2) {
            [dict setObject:subs.lastObject forKey:subs.firstObject];
        }
    }
    return [NSDictionary dictionaryWithDictionary:dict];;
}

// 转码
- (void)transcodeIfNeed:(NSURL *)url
{
    if ([url.pathExtension.lowercaseString isEqualToString:@"mp4"]) {
        // mp4 直接发送
        [self sendVideoWithUrl:url];
    } else {
        // 非 mp4 文件 => mp4 文件
        NSString* tempPath = NSTemporaryDirectory();
        NSURL *urlName = [url URLByDeletingPathExtension];
        NSURL *newUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@%@.mp4", tempPath,[urlName.lastPathComponent stringByRemovingPercentEncoding]]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:newUrl.path]){
            NSError *error;
            BOOL success = [fileManager removeItemAtPath:newUrl.path error:&error];
            if (!success || error) {
                NSAssert1(NO, @"removeItemFail: %@", error.localizedDescription);
                return;
            }
        }
        // mov to mp4
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        exportSession.outputURL = newUrl;
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export session failed");
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    //Video conversion finished
                    NSLog(@"Successful!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self sendVideoWithUrl:newUrl];
                    });
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)sendVideoWithUrl:(NSURL*)url
{
    if (!NSThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendVideoWithUrl:url];
        });
        return;
    }
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", TUIKit_Video_Path, [THelper genVideoName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:videoPath contents:videoData attributes:nil];
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset =  [AVURLAsset URLAssetWithURL:url options:opts];
    NSInteger duration = (NSInteger)urlAsset.duration.value / urlAsset.duration.timescale;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(192, 192);
    NSError *error = nil;
    CMTime actualTime;
    CMTime time = CMTimeMakeWithSeconds(0.0, 10);
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imagePath = [TUIKit_Video_Path stringByAppendingString:[THelper genSnapshotName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    
    TUIVideoMessageCellData *uiVideo = [[TUIVideoMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    uiVideo.snapshotPath = imagePath;
    uiVideo.snapshotItem = [[TUISnapshotItem alloc] init];
    UIImage *snapshot = [UIImage imageWithContentsOfFile:imagePath];
    uiVideo.snapshotItem.size = snapshot.size;
    uiVideo.snapshotItem.length = imageData.length;
    uiVideo.videoPath = videoPath;
    uiVideo.videoItem = [[TUIVideoItem alloc] init];
    uiVideo.videoItem.duration = duration;
    uiVideo.videoItem.length = videoData.length;
    uiVideo.videoItem.type = url.pathExtension;
    uiVideo.uploadProgress = 0;
    [self sendMessage:uiVideo];
    
    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if (delegate && [delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
            [delegate chatController:self didSendMessage:uiVideo];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    [url startAccessingSecurityScopedResource];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] init];
    NSError *error;
    @weakify(self)
    [coordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
        @strongify(self)
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        NSString *fileName = [url lastPathComponent];
        NSString *filePath = [TUIKit_File_Path stringByAppendingString:fileName];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
            TUIFileMessageCellData *uiFile = [[TUIFileMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            uiFile.path = filePath;
            uiFile.fileName = fileName;
            uiFile.length = (int)fileSize;
            uiFile.uploadProgress = 0;
            [self sendMessage:uiFile];
            
            for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
                if (delegate && [delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                    [delegate chatController:self didSendMessage:uiFile];
                }
            }
        }
    }];
    [url stopAccessingSecurityScopedResource];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 消息菜单操作: 多选 & 转发
- (void)onSelectMessageMenu:(NSInteger)menuType withData:(TUIMessageCellData *)data {
    if (menuType == 0) {
        // 多选: 打开多选面板
        [self openMultiChooseBoard:YES];
    } else if (menuType == 1) {
        // 转发
        if (data == nil) {
            return;
        }
        
        NSMutableArray *uiMsgs = [NSMutableArray arrayWithArray:@[data]];
        [self prepareForwardMessages:uiMsgs];
        
    }
}

// 打开、关闭 多选面板
- (void)openMultiChooseBoard:(BOOL)open
{
    [self.view endEditing:YES];
    
    if (_multiChooseView) {
        [_multiChooseView removeFromSuperview];
    }
    
    if (open) {
        _multiChooseView = [[TUIMessageMultiChooseView alloc] init];
        _multiChooseView.frame = self.view.bounds;
        _multiChooseView.delegate = self;
        _multiChooseView.titleLabel.text = self.conversationData.title;
        if (@available(iOS 12.0, *)) {
            if (@available(iOS 13.0, *)) {
                // > ios 12
                [UIApplication.sharedApplication.keyWindow addSubview:_multiChooseView];
            } else {
                // ios 12
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

- (void)messageMultiChooseViewOnCancelClicked:(TUIMessageMultiChooseView *)multiChooseView
{
    [self openMultiChooseBoard:NO];
    [self.messageController enableMultiSelectedMode:NO];
}

- (void)messageMultiChooseViewOnRelayClicked:(TUIMessageMultiChooseView *)multiChooseView
{
    NSArray *uiMsgs = [self.messageController multiSelectedResult:TUIMultiResultOptionAll];
    [self prepareForwardMessages:uiMsgs];
}

- (void)messageMultiChooseViewOnDeleteClicked:(TUIMessageMultiChooseView *)multiChooseView
{
    NSArray *uiMsgs = [self.messageController multiSelectedResult:TUIMultiResultOptionAll];
    if (uiMsgs.count == 0) {
        [THelper makeToast:TUILocalizableString(TUIKitRelayNoMessageTips)];
        return;
    }
    
    // 删除
    [self.messageController deleteMessages:uiMsgs];
}

// 准备转发消息
- (void)prepareForwardMessages:(NSArray<TUIMessageCellData *> *)uiMsgs
{
    if (uiMsgs.count == 0) {
        [THelper makeToast:TUILocalizableString(TUIKitRelayNoMessageTips)];
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
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:TUILocalizableString(TUIKitRelayUnsupportForward) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Confirm) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void(^chooseTarget)(BOOL) = ^(BOOL mergeForward){
        TUIConversationSelectController *vc = [TUIConversationSelectController showIn:self];
        __weak typeof(vc) weakVc = vc;
        vc.callback = ^(NSArray<TUIConversationCellData *> * _Nonnull targets, void (^ _Nonnull completHandler)(BOOL)) {
            
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:TUILocalizableString(TUIKitRelayConfirmForward) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertVc addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (completHandler) {
                    completHandler(NO);
                }
            }]];
            [alertVc addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Confirm) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf forwardMessages:uiMsgs toTargets:targets merge:mergeForward];
                if (completHandler) {
                    completHandler(YES);
                }
            }]];
            
            [weakVc presentViewController:alertVc animated:YES completion:nil];
        };
    };
    
    UIAlertController *tipsVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [tipsVc addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitRelayOneByOneForward) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (uiMsgs.count <= 30) {
            chooseTarget(NO);
            return;
        }
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:TUILocalizableString(TUIKitRelayOneByOnyOverLimit) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleDefault handler:nil]];
        [vc addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitRelayCombineForwad) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            chooseTarget(YES);
        }]];
        [weakSelf presentViewController:vc animated:YES completion:nil];
    }]];
    [tipsVc addAction:[UIAlertAction actionWithTitle:TUILocalizableString(TUIKitRelayCombineForwad) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        chooseTarget(YES);
    }]];
    [tipsVc addAction:[UIAlertAction actionWithTitle:TUILocalizableString(Cancel) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:tipsVc animated:YES completion:nil];
}

// 转发消息到目标会话
- (void)forwardMessages:(NSArray<TUIMessageCellData *> *)uiMsgs toTargets:(NSArray<TUIConversationCellData *> *)targets merge:(BOOL)merge
{
    if (uiMsgs.count == 0 || targets.count == 0) {
        return ;
    }
   
    __weak typeof(self) weakSelf = self;
    dispatch_apply(targets.count, dispatch_get_global_queue(0, 0), ^(size_t index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        TUIConversationCellData *convCellData = targets[index];
        NSTimeInterval timeInterval = convCellData.groupID.length?0.09:0.05;
        [strongSelf getForwardOrMergeMessages:merge originMessages:uiMsgs callback:^(BOOL success, NSArray<V2TIMMessage *> *msgs) {
            if (!success) {
                return;
            }
            
            // 发送到当前聊天窗口
            if ([convCellData.conversationID isEqualToString:self.conversationData.conversationID]) {
                for (V2TIMMessage *imMsg in msgs) {
                    TUIMessageCellData *uiMsg = nil;
                    if (imMsg.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
                        uiMsg = [self messageController:self.messageController onNewMessage:imMsg];
                    }
                    if (uiMsg == nil) {
                        uiMsg = imMsg.cellData;
                    }
                    uiMsg.innerMessage = imMsg;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 下面的函数涉及到 UI 的刷新，要放在主线程操作
                        [strongSelf.messageController sendMessage:uiMsg];
                    });
                    // 此处做延时是因为需要保证批量逐条转发时，能够保证接收端的顺序一致
                    [NSThread sleepForTimeInterval:timeInterval];
                }
                return;
            }
            // 发送到其他聊天
            for (V2TIMMessage *message in msgs) {
                // 设置离线推送
                 V2TIMOfflinePushInfo *pushInfo = [[V2TIMOfflinePushInfo alloc] init];
                 NSDictionary *ext = @{
                     @"entity": @{
                             @"action": @1,
                             @"content": message.getDisplayString,
                             @"sender": TUIKit.sharedInstance.userID,
                             @"nickname": TUIKit.sharedInstance.nickName?:TUIKit.sharedInstance.userID,
                             @"faceUrl": TUIKit.sharedInstance.faceUrl?:@"",
                             @"chatType": convCellData.groupID.length?@(V2TIM_GROUP):@(V2TIM_C2C)
                     }
                 };
                NSData *data = [NSJSONSerialization dataWithJSONObject:ext options:NSJSONWritingPrettyPrinted error:nil];
                pushInfo.ext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                pushInfo.AndroidOPPOChannelID = @"tuikit";
                [V2TIMManager.sharedInstance sendMessage:message
                                                receiver:convCellData.userID
                                                 groupID:convCellData.groupID
                                                priority:V2TIM_PRIORITY_NORMAL
                                          onlineUserOnly:nil
                                         offlinePushInfo:pushInfo
                                                progress:nil
                                                    succ:^{
                    // 发送到其他聊天的消息需要广播消息发送状态，方便进入对应聊天后刷新消息状态
                    [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged object:message.msgID];
                }
                                                    fail:^(int code, NSString *desc){
                    [NSNotificationCenter.defaultCenter postNotificationName:TUIKitNotification_onMessageStatusChanged object:message.msgID];
                }];
                // 此处做延时是因为需要保证批量逐条转发时，能够保证接收端的顺序一致
                [NSThread sleepForTimeInterval:timeInterval];
            }
        }];
    });
}

- (void)getForwardOrMergeMessages:(BOOL)merge
                   originMessages:(NSArray<TUIMessageCellData *> *)uiMsgs
                         callback:(void(^)(BOOL success, NSArray<V2TIMMessage *> *results))callback
{
    if (uiMsgs.count == 0) {
        if (callback) {
            callback(NO, @[]);
        }
        return ;
    }
    
    // 获取消息列表
    NSMutableArray *tmpMsgs = [NSMutableArray array];
    for (TUIMessageCellData *uiMsg in uiMsgs) {
        V2TIMMessage *msg = uiMsg.innerMessage;
        if (msg) {
            [tmpMsgs addObject:msg];
        }
    }
    NSArray *msgs = [NSArray arrayWithArray:tmpMsgs];
    
    // 排序-按照时间先后顺序以及seq顺序转发
    msgs = [msgs sortedArrayUsingComparator:^NSComparisonResult(V2TIMMessage *obj1, V2TIMMessage *obj2) {
        if ([obj1.timestamp timeIntervalSince1970] == [obj2.timestamp timeIntervalSince1970]) {
            return obj1.seq > obj2.seq;
        }else {
            return [obj1.timestamp compare:obj2.timestamp];
        }
    }];
    
    // 逐条转发消息
    if (!merge) {
        
        NSMutableArray *forwardMsgs = [NSMutableArray array];
        for (V2TIMMessage *msg in msgs) {
            V2TIMMessage *forwardMessage = [V2TIMManager.sharedInstance createForwardMessage:msg];
            if (forwardMessage) {
                forwardMessage.isExcludedFromUnreadCount = [TUIKit sharedInstance].config.isExcludedFromUnreadCount;
                forwardMessage.isExcludedFromLastMessage = [TUIKit sharedInstance].config.isExcludedFromLastMessage;
                [forwardMsgs addObject:forwardMessage];
            }
        }
        if (callback) {
            callback(YES, forwardMsgs);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSString *loginUserId = [V2TIMManager.sharedInstance getLoginUser];
    [V2TIMManager.sharedInstance getUsersInfo:@[loginUserId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        // 创建转发消息
        NSString *myName = loginUserId;
        if (infoList.firstObject.nickName.length > 0) {
            myName = infoList.firstObject.nickName;
        }
        NSString *title = @"";
        if (weakSelf.conversationData.groupID.length) {
            title = TUILocalizableString(TUIKitRelayGroupChatHistory);
        } else {
            title = [NSString stringWithFormat:TUILocalizableString(TUIKitRelayChatHistoryForSomebodyFormat), weakSelf.conversationData.title, myName];
        }
        NSMutableArray *abstactList = [NSMutableArray array];
        if (uiMsgs.count > 0) {
            [abstactList addObject:[weakSelf abstractDisplayMessage:msgs[0]]];
        }
        if (uiMsgs.count > 1) {
            [abstactList addObject:[weakSelf abstractDisplayMessage:msgs[1]]];
        }
        if (uiMsgs.count > 2) {
            [abstactList addObject:[weakSelf abstractDisplayMessage:msgs[2]]];
        }
        NSString *compatibleText = TUILocalizableString(TUIKitRelayCompatibleText);
        V2TIMMessage *mergeMessage = [V2TIMManager.sharedInstance createMergerMessage:msgs title:title abstractList:abstactList compatibleText:compatibleText];
        if (mergeMessage == nil) {
            if (callback) {
                callback(NO, @[]);
            }
            return;
        }
        mergeMessage.isExcludedFromUnreadCount = [TUIKit sharedInstance].config.isExcludedFromUnreadCount;
        mergeMessage.isExcludedFromLastMessage = [TUIKit sharedInstance].config.isExcludedFromLastMessage;
        if (callback) {
            callback(YES, @[mergeMessage]);
        }
        
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(NO, @[]);
        }
    }];
}

- (NSString *)abstractDisplayMessage:(V2TIMMessage *)msg
{
    // 合并转发的消息只支持 nickName
    NSString *desc = @"";
    if (msg.nickName.length > 0) {
        desc = msg.nickName;
    } else if(msg.sender.length > 0) {
        desc = msg.sender;
    }
    NSString *display = @"";
    for (id<TUIChatControllerListener> delegate in [TUIKitListenerManager sharedInstance].chatListeners) {
        if (delegate && [delegate respondsToSelector:@selector(chatController:onGetMessageAbstact:)]) {
            display = [delegate chatController:self onGetMessageAbstact:msg];
            if (display.length > 0) {
                break;
            }
        }
    }
    if (display.length == 0) {
        display = [TUIMessageDataProviderService.shareInstance getDisplayString:msg];
    }
    if (desc.length > 0 && display.length > 0) {
        desc = [desc stringByAppendingFormat:@":%@", display];
    }
    return desc;
}

@end
