//
//  TUIChatController.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIChatController.h"
#import "THeader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIGroupPendencyViewModel.h"
#import "TUIMessageController.h"
#import "TUIGroupPendencyController.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "Toast/Toast.h"

@interface TUIChatController () <TMessageControllerDelegate, TInputControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) TIMConversation *conversation;
@property UIView *tipsView;
@property UILabel *pendencyLabel;
@property UIButton *pendencyBtn;
@property TUIGroupPendencyViewModel *pendencyViewModel;
@property RACSubject *sendMediaSignal;
@end

@implementation TUIChatController

- (instancetype)initWithConversation:(TIMConversation *)conversation;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _conversation = conversation;
        
        NSMutableArray *moreMenus = [NSMutableArray array];
        [moreMenus addObject:[TUIInputMoreCellData photoData]];
        [moreMenus addObject:[TUIInputMoreCellData pictureData]];
        [moreMenus addObject:[TUIInputMoreCellData videoData]];
        [moreMenus addObject:[TUIInputMoreCellData fileData]];
        _moreMenus = moreMenus;
        
        if (_conversation.getType == TIM_GROUP) {
            _pendencyViewModel = [TUIGroupPendencyViewModel new];
            _pendencyViewModel.groupId = [_conversation getReceiver];
        }
        
        @weakify(self)
        _sendMediaSignal = [RACSubject subject];
        [[_sendMediaSignal throttle:1] subscribeNext:^(NSDictionary *info) {
            @strongify(self)
            NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
            if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
                UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                UIImageOrientation imageOrientation=  image.imageOrientation;
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
                
                [self sendImageMessage:image];
            }
            else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
                NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
                [self sendVideoMessage:url];
            }
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [self saveDraft];
    }
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    @weakify(self)
    //message
    _messageController = [[TUIMessageController alloc] init];
    _messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TTextView_Height - Bottom_SafeHeight);
    _messageController.delegate = self;
    [self addChildViewController:_messageController];
    [self.view addSubview:_messageController.view];
    [_messageController setConversation:_conversation];
    
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
    
    TIMMessageDraft *draft = [self.conversation getDraft];
    if(draft){
        for (int i = 0; i < draft.elemCount; ++i) {
            TIMElem *elem = [draft getElem:i];
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                _inputController.inputBar.inputTextView.text = text.text;
                [self.conversation setDraft:nil];
                break;
            }
        }
    }
    

    self.tipsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tipsView.backgroundColor = RGB(246, 234, 190);
    [self.view addSubview:self.tipsView];
    self.tipsView.mm_height(24).mm_width(self.view.mm_w);
    
    self.pendencyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.tipsView addSubview:self.pendencyLabel];
    self.pendencyLabel.font = [UIFont systemFontOfSize:12];
    
    
    self.pendencyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.tipsView addSubview:self.pendencyBtn];
    [self.pendencyBtn setTitle:@"点击处理" forState:UIControlStateNormal];
    [self.pendencyBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.pendencyBtn addTarget:self action:@selector(openPendency:) forControlEvents:UIControlEventTouchUpInside];
    [self.pendencyBtn sizeToFit];
    self.tipsView.hidden = YES;

    
    [RACObserve(self.pendencyViewModel, unReadCnt) subscribeNext:^(NSNumber *unReadCnt) {
        @strongify(self)
        if ([unReadCnt intValue]) {
            self.pendencyLabel.text = [NSString stringWithFormat:@"%@条入群请求", unReadCnt];
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
}

- (void)getPendencyList
{
    if (self.conversation.getType == TIM_GROUP)
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
    [_messageController sendMessage:msg];
}

- (void)sendMessage:(TUIMessageCellData *)message
{
    [_messageController sendMessage:message];
}

- (void)saveDraft
{
    NSString *draft = self.inputController.inputBar.inputTextView.text;
    draft = [draft stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (draft.length) {
        TIMMessageDraft *msg = [TIMMessageDraft new];
        TIMTextElem *text = [TIMTextElem new];
        [text setText:draft];
        [msg addElem:text];
        [self.conversation setDraft:msg];
    }
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell
{
    if (cell.data == [TUIInputMoreCellData photoData]) {
        [self selectPhotoForSend];
    }
    if (cell.data == [TUIInputMoreCellData videoData]) {
        [self takeVideoForSend];
    }
    if (cell.data == [TUIInputMoreCellData fileData]) {
        [self selectFileForSend];
    }
    if (cell.data == [TUIInputMoreCellData pictureData]) {
        [self takePictureForSend];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(chatController:onSelectMoreCell:)]){
        [_delegate chatController:self onSelectMoreCell:cell];
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

- (TUIMessageCellData *)messageController:(TUIMessageController *)controller onNewMessage:(TIMMessage *)data
{
    if ([self.delegate respondsToSelector:@selector(chatController:onNewMessage:)]) {
        return [self.delegate chatController:self onNewMessage:data];
    }
    return nil;
}

- (TUIMessageCell *)messageController:(TUIMessageController *)controller onShowMessageData:(TUIMessageCellData *)data
{
    if ([self.delegate respondsToSelector:@selector(chatController:onShowMessageData:)]) {
        return [self.delegate chatController:self onShowMessageData:data];
    }
    return nil;
}

- (void)messageController:(TUIMessageController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell
{
    if (cell.messageData.identifier == nil)
        return;
    
    @weakify(self)
    TIMFriend *friend = [[TIMFriendshipManager sharedInstance] queryFriend:cell.messageData.identifier];
    if (friend) {
        id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
        if ([vc isKindOfClass:[UIViewController class]]) {
            vc.friendProfile = friend;
            [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
            return;
        }
    }
        
    [[TIMFriendshipManager sharedInstance] getUsersProfile:@[cell.messageData.identifier] forceUpdate:YES succ:^(NSArray<TIMUserProfile *> *profiles) {
        @strongify(self)
        if (profiles.count > 0) {
            id<TUIUserProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
            if ([vc isKindOfClass:[UIViewController class]]) {
                vc.userProfile = profiles[0];
                vc.actionType = PCA_ADD_FRIEND;
                [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                return;
            }
        }
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.view makeToast:msg];
    }];
}


- (void)didHideMenuInMessageController:(TUIMessageController *)controller
{
    _inputController.inputBar.inputTextView.overrideNextResponder = nil;
}


- (void)sendImageMessage:(UIImage *)image;
{
    [_messageController sendImageMessage:image];
}

- (void)sendVideoMessage:(NSURL *)url
{
    [_messageController sendVideoMessage:url];
}

- (void)sendFileMessage:(NSURL *)url
{
    [_messageController sendFileMessage:url];
}

// ----------------------------------
- (void)selectPhotoForSend
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)takePictureForSend
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraCaptureMode =UIImagePickerControllerCameraCaptureModePhoto;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)takeVideoForSend
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            picker.cameraCaptureMode =UIImagePickerControllerCameraCaptureModeVideo;
            picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [picker setVideoMaximumDuration:15];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)selectFileForSend
{
            UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeData] inMode:UIDocumentPickerModeOpen];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 快速点的时候会回调多次
    [_sendMediaSignal sendNext:info];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    [self sendFileMessage:url];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end
