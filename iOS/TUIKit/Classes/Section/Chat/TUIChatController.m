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

@interface TUIChatController () <TMessageControllerDelegate, TInputControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) TIMConversation *conversation;
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
            picker.videoQuality =UIImagePickerControllerQualityTypeHigh;
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
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageOrientation imageOrientation=  image.imageOrientation;
        if(imageOrientation != UIImageOrientationUp)
        {
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }

        [self sendImageMessage:image];
    }
    else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        [self sendVideoMessage:url];
    }

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
