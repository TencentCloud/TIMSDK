//
//  TInputController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "TUIInputController_Minimalist.h"
#import "TUIMenuCell_Minimalist.h"
#import "TUIMenuCellData_Minimalist.h"
#import "TUIInputMoreCell_Minimalist.h"
#import "TUICommonModel.h"
#import "TUIFaceMessageCell_Minimalist.h"
#import "TUITextMessageCell_Minimalist.h"
#import "TUIVoiceMessageCell_Minimalist.h"
#import "TUIDefine.h"
#import "TUIDarkModel.h"
#import "TUIMessageDataProvider_Minimalist.h"
#import "NSString+TUIEmoji.h"
#import "TUIThemeManager.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIChatDataProvider_Minimalist.h"
#import "TUIChatModifyMessageHelper.h"
#import "UIAlertController+TUICustomStyle.h"

@interface TUIInputController_Minimalist () <TUIInputBarDelegate_Minimalist, TUIMenuViewDelegate_Minimalist, TUIFaceViewDelegate, TUIMoreViewDelegate_Minimalist>
@property (nonatomic, assign) InputStatus status;
@property (nonatomic, assign) CGRect keyboardFrame;

@property (nonatomic, copy) void(^modifyRootReplyMsgBlock)(TUIMessageCellData *);
@end

@implementation TUIInputController_Minimalist
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
}
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputMessageStatusChanged:) name:@"kTUINotifyMessageStatusChanged" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (UIGestureRecognizer *gesture in self.view.window.gestureRecognizers) {
        NSLog(@"gesture = %@",gesture);
        gesture.delaysTouchesBegan = NO;
        NSLog(@"delaysTouchesBegan = %@",gesture.delaysTouchesBegan?@"YES":@"NO");
        NSLog(@"delaysTouchesEnded = %@",gesture.delaysTouchesEnded?@"YES":@"NO");
    }
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews
{
    self.view.backgroundColor = RGBA(255, 255, 255, 1);
    _status = Input_Status_Input;
    
    _inputBar = [[TUIInputBar_Minimalist alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.replyPreviewBar.frame), self.view.frame.size.width, TTextView_Height)];
    _inputBar.delegate = self;
    [self.view addSubview:_inputBar];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        CGFloat inputContainerBottom = [self getInputContainerBottom];
        [_delegate inputController:self didChangeHeight:inputContainerBottom + Bottom_SafeHeight];
    }
    if (_status == Input_Status_Input_Keyboard) {
        _status = Input_Status_Input;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if(_status == Input_Status_Input_Face){
        [self hideFaceAnimation];
    }
    else if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    else{
        //[self hideFaceAnimation:NO];
        //[self hideMoreAnimation:NO];
    }
    _status = Input_Status_Input_Keyboard;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        CGFloat inputContainerBottom = [self getInputContainerBottom];
        [_delegate inputController:self didChangeHeight:keyboardFrame.size.height + inputContainerBottom];
    }
    self.keyboardFrame = keyboardFrame;
}

- (void)hideFaceAnimation
{
    self.faceView.hidden = NO;
    self.faceView.alpha = 1.0;
    self.menuView.hidden = NO;
    self.menuView.alpha = 1.0;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.faceView.alpha = 0.0;
        ws.menuView.alpha = 0.0;
    } completion:^(BOOL finished) {
        ws.faceView.hidden = YES;
        ws.faceView.alpha = 1.0;
        ws.menuView.hidden = YES;
        ws.menuView.alpha = 1.0;
        [ws.menuView removeFromSuperview];
        [ws.faceView removeFromSuperview];
    }];
}

- (void)showFaceAnimation
{
    [self.view addSubview:self.menuView];
    [self.view addSubview:self.faceView];

    self.menuView.hidden = NO;
    CGRect frame = self.menuView.frame;
    frame.origin.y = Screen_Height;
    self.menuView.frame = frame;

    self.faceView.hidden = NO;
    frame = self.faceView.frame;
    frame.origin.y = self.menuView.mm_maxY;
    self.faceView.frame = frame;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.menuView.frame;
        newFrame.origin.y = ws.inputBar.mm_maxY;
        ws.menuView.frame = newFrame;

        newFrame = ws.faceView.frame;
        newFrame.origin.y = ws.menuView.mm_maxY;
        ws.faceView.frame = newFrame;
    } completion:nil];
}

- (void)hideMoreAnimation
{
    self.moreView.hidden = NO;
    self.moreView.alpha = 1.0;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.moreView.alpha = 0.0;
    } completion:^(BOOL finished) {
        ws.moreView.hidden = YES;
        ws.moreView.alpha = 1.0;
        [ws.moreView removeFromSuperview];
    }];
}

- (void)showMoreAnimation
{
    [self.view addSubview:self.moreView];

    self.moreView.hidden = NO;
    CGRect frame = self.moreView.frame;
    frame.origin.y = Screen_Height;
    self.moreView.frame = frame;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.moreView.frame;
        newFrame.origin.y = ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
        ws.moreView.frame = newFrame;
    } completion:nil];
}

- (void)inputBarDidTouchCamera:(TUIInputBar_Minimalist *)textView
{
    [_inputBar.inputTextView resignFirstResponder];
    [self hideFaceAnimation];
    [self hideMoreAnimation];
    _status = Input_Status_Input_Camera;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        CGFloat inputContainerBottom = [self getInputContainerBottom];
        [_delegate inputController:self didChangeHeight:inputContainerBottom + Bottom_SafeHeight];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(inputControllerDidSelectCamera:)]){
        [_delegate inputControllerDidSelectCamera:self];
    }
}

- (void)inputBarDidTouchMore:(TUIInputBar_Minimalist *)textView
{
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *titles = @[TUIKitLocalizableString(TUIKitMorePhoto),
                        TUIKitLocalizableString(TUIKitMoreCamera),
                        TUIKitLocalizableString(TUIKitMoreVideo),
                        TUIKitLocalizableString(TUIKitMoreFile),
                        TUIKitLocalizableString(TUIKitMoreLink)];
    
    NSArray *images = @[[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_photo")],
                        [UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_camera")],
                        [UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_video")],
                        [UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_document")],
                        [UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_more_custom")],
    ];

    NSArray *actionHandles = @[
                               
                               ^(UIAlertAction *action){
                                   [self excuteAction:@"Album"];
                               },
                                ^(UIAlertAction *action){
                                    [self excuteAction:@"TakePhoto"];
                                },
                                ^(UIAlertAction *action){
                                    [self excuteAction:@"RecordVideo"];
                                },
                                ^(UIAlertAction *action){
                                    [self excuteAction:@"File"];
                                },
                                ^(UIAlertAction *action){
                                    [self excuteAction:TUIInputMoreCellKey_Link];
                                },
    ];
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0 ; i< titles.count; i++) {
        TUICustomActionSheetItem *item = [[TUICustomActionSheetItem alloc] initWithTitle:titles[i] leftMark:images[i] withActionHandler:actionHandles[i]];
        item.actionStyle = UIAlertActionStyleDefault;
        [items addObject:item];
    }
    
    [ac configItems:items];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:  ^(UIAlertAction *action){
        NSLog(@"Cancel");
    }];
    [ac addAction:cancelAction];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)excuteAction:(NSString *)actionName {
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSelectMoreCellAction:)]){
        [_delegate inputController:self didSelectMoreCellAction:actionName];
    }
}
- (void)inputBarDidTouchFace:(TUIInputBar_Minimalist *)textView
{
    if([TUIConfig defaultConfig].faceGroups.count == 0){
        return;
    }
    if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    [_inputBar.inputTextView resignFirstResponder];
    _status = Input_Status_Input_Face;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:CGRectGetMaxY(_inputBar.frame) + self.menuView.frame.size.height + self.faceView.frame.size.height + Bottom_SafeHeight];
    }
    [self showFaceAnimation];
}

- (void)inputBarDidTouchKeyboard:(TUIInputBar_Minimalist *)textView
{
    if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    if (_status == Input_Status_Input_Face) {
        [self hideFaceAnimation];
    }
    _status = Input_Status_Input_Keyboard;
    [_inputBar.inputTextView becomeFirstResponder];
}

- (void)inputBar:(TUIInputBar_Minimalist *)textView didChangeInputHeight:(CGFloat)offset
{
    if(_status == Input_Status_Input_Face){
        [self showFaceAnimation];
    }
    else if(_status == Input_Status_Input_More){
        [self showMoreAnimation];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:self.view.frame.size.height + offset];
        if (_referencePreviewBar) {
            CGRect referencePreviewBarFrame = _referencePreviewBar.frame;
            _referencePreviewBar.frame = CGRectMake(referencePreviewBarFrame.origin.x, referencePreviewBarFrame.origin.y + offset, referencePreviewBarFrame.size.width, referencePreviewBarFrame.size.height);
        }
    }
}

- (void)inputBar:(TUIInputBar_Minimalist *)textView didSendText:(NSString *)text
{
    /**
     * 表情国际化 --> 恢复成实际的中文 key
     * Emoticon internationalization --> restore to actual Chinese key
     */
    NSString *content = [text getInternationalStringWithfaceContent];
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createTextMessage:content];
    [self appendReplyDataIfNeeded:message];
    [self appendReferenceDataIfNeeded:message];
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:message];
    }
}

- (void)inputMessageStatusChanged:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
    TUIMessageCellData *msg = userInfo[@"msg"];
    long status = [userInfo[@"status"] intValue];
    if ([msg isKindOfClass:TUIMessageCellData.class] && status == Msg_Status_Succ ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.modifyRootReplyMsgBlock) {
                self.modifyRootReplyMsgBlock(msg);
            }
        });
    }
}

- (void)appendReplyDataIfNeeded:(V2TIMMessage *)message
{
    if (self.replyData) {
        V2TIMMessage * parentMsg = self.replyData.originMessage;
        NSMutableDictionary  * simpleReply = [NSMutableDictionary dictionary];
        [simpleReply addEntriesFromDictionary:@{
            @"messageID"       : self.replyData.msgID?:@"",
            @"messageAbstract" : [self.replyData.msgAbstract?:@"" getInternationalStringWithfaceContent],
            @"messageSender"   : self.replyData.sender?:@"",
            @"messageType"     : @(self.replyData.type),
            @"messageTime"     : @(self.replyData.originMessage.timestamp ? [self.replyData.originMessage.timestamp timeIntervalSince1970] : 0),
            @"messageSequence" : @(self.replyData.originMessage.seq),
            @"version"         : @(kMessageReplyVersion),
        }];
        
        NSMutableDictionary *cloudResultDic = [[NSMutableDictionary alloc] initWithCapacity:5];
        if (parentMsg.cloudCustomData) {
            NSDictionary * originDic = [TUITool jsonData2Dictionary:parentMsg.cloudCustomData];
            if (originDic && [originDic isKindOfClass:[NSDictionary class]]) {
                [cloudResultDic addEntriesFromDictionary:originDic];
            }
            /**
             * 接受 parent 里的数据，但是不能保存 messageReplies\messageReact，因为根消息话题创建者才有这个字段。
             * 当前发送的新消息里不能存 messageReplies\messageReact
             *
             * Accept the data in the parent, but cannot save messageReplies\messageReact, because the root message topic creator has this field.
             * messageReplies\messageReact cannot be stored in the new message currently sent
             */
            [cloudResultDic removeObjectForKey:@"messageReplies"];
            [cloudResultDic removeObjectForKey:@"messageReact"];
        }
        NSString * messageParentReply = cloudResultDic[@"messageReply"];
        NSString * messageRootID = [messageParentReply valueForKey:@"messageRootID"];
        if (self.replyData.messageRootID.length > 0) {
            messageRootID = self.replyData.messageRootID;
        }
        if (!IS_NOT_EMPTY_NSSTRING(messageRootID)) {
            /**
             * 如果源消息没有 messageRootID， 则需要将当前源消息的 msgID 作为 root
             * If the original message does not have a messageRootID, you need to use the msgID of the current original message as root
             */
            if (IS_NOT_EMPTY_NSSTRING(parentMsg.msgID)) {
                messageRootID = parentMsg.msgID;
            }
        }
        [simpleReply setObject:messageRootID forKey:@"messageRootID"];
        [cloudResultDic setObject:simpleReply forKey:@"messageReply"];
        NSData *data = [TUITool dictionary2JsonData:cloudResultDic];
        if (data) {
            message.cloudCustomData = data;
        }

        [self exitReplyAndReference:nil];
        
        __weak typeof(self) weakSelf = self;
        self.modifyRootReplyMsgBlock = ^(TUIMessageCellData *cellData) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf modifyRootReplyMsgByID:messageRootID currentMsg:cellData];
            strongSelf.modifyRootReplyMsgBlock = nil;
        };

    }
}

- (void)modifyRootReplyMsgByID:(NSString *)messageRootID  currentMsg:(TUIMessageCellData *)messageCellData{
    
    
    NSDictionary *simpleCurrentContent = @{
        @"messageID"       : messageCellData.innerMessage.msgID?:@"",
        @"messageAbstract" : [messageCellData.innerMessage.textElem.text?:@"" getInternationalStringWithfaceContent],
        @"messageSender"   : messageCellData.innerMessage.sender?:@"",
        @"messageType"     : @(messageCellData.innerMessage.elemType),
        @"messageTime"     : @(messageCellData.innerMessage.timestamp ? [messageCellData.innerMessage.timestamp timeIntervalSince1970] : 0),
        @"messageSequence" : @(messageCellData.innerMessage.seq),
        @"version"         : @(kMessageReplyVersion)
    };
    if (messageRootID) {
        [TUIChatDataProvider_Minimalist findMessages:@[messageRootID] callback:^(BOOL succ, NSString * _Nonnull error_message, NSArray * _Nonnull msgs) {
            if (succ) {
                if (msgs.count >0) {
                    V2TIMMessage *rootMsg = msgs.firstObject;
                    [[TUIChatModifyMessageHelper defaultHelper] modifyMessage:rootMsg  simpleCurrentContent:simpleCurrentContent];
                }
            }
        }];
    }
}

- (void)appendReferenceDataIfNeeded:(V2TIMMessage *)message
{
    if (self.referenceData) {
        NSDictionary *dict = @{
            @"messageReply": @{
                    @"messageID"       : self.referenceData.msgID?:@"",
                    @"messageAbstract" : [self.referenceData.msgAbstract?:@"" getInternationalStringWithfaceContent],
                    @"messageSender"   : self.referenceData.sender?:@"",
                    @"messageType"     : @(self.referenceData.type),
                    @"messageTime"     : @(self.referenceData.originMessage.timestamp ? [self.referenceData.originMessage.timestamp timeIntervalSince1970] : 0),
                    @"messageSequence" : @(self.referenceData.originMessage.seq),
                    @"version"         : @(kMessageReplyVersion)
            }
        };
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if (error == nil) {
            message.cloudCustomData = data;
        }
        [self exitReplyAndReference:nil];
    }
}

- (void)inputBar:(TUIInputBar_Minimalist *)textView didSendVoice:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    int duration = (int)CMTimeGetSeconds(audioAsset.duration);
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createSoundMessage:path duration:duration];
    if (message && _delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:message];
    }
}

- (void)inputBarDidInputAt:(TUIInputBar_Minimalist *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputControllerDidInputAt:)]) {
        [_delegate inputControllerDidInputAt:self];
    }
}

- (void)inputBar:(TUIInputBar_Minimalist *)textView didDeleteAt:(NSString *)atText
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didDeleteAt:)]) {
        [_delegate inputController:self didDeleteAt:atText];
    }
}

- (void)inputBarDidDeleteBackward:(TUIInputBar_Minimalist *)textView
{
    if (textView.inputTextView.text.length == 0) {
        [self exitReplyAndReference:nil];
    }
}


- (void)inputTextViewShouldBeginTyping:(UITextView *)textView {
    
    if (_delegate && [_delegate respondsToSelector:@selector(inputControllerBeginTyping:)]) {
        [_delegate inputControllerBeginTyping:self];
    }
}

- (void)inputTextViewShouldEndTyping:(UITextView *)textView {
    
    if (_delegate && [_delegate respondsToSelector:@selector(inputControllerEndTyping:)]) {
        [_delegate inputControllerEndTyping:self];
    }
    
}




- (void)reset
{
    if(_status == Input_Status_Input){
        return;
    }
    else if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    else if(_status == Input_Status_Input_Face){
        [self hideFaceAnimation];
    }
    _status = Input_Status_Input;
    [_inputBar.inputTextView resignFirstResponder];
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        CGFloat inputContainerBottom = [self getInputContainerBottom];
        [_delegate inputController:self didChangeHeight:inputContainerBottom + Bottom_SafeHeight];
    }
}

- (void)showReferencePreview:(TUIReferencePreviewData_Minimalist *)data {
    self.referenceData = data;
    [self.referencePreviewBar removeFromSuperview];
    [self.view addSubview:self.referencePreviewBar];
    self.inputBar.lineView.hidden = YES;
    
    self.referencePreviewBar.previewReferenceData = data;
    
    self.inputBar.mm_y = 0 ;
        
    self.referencePreviewBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, TMenuView_Menu_Height);
    self.referencePreviewBar.mm_y = CGRectGetMaxY(self.inputBar.frame);
    if (self.status == Input_Status_Input_Keyboard) {
        CGFloat keyboradHeight = self.keyboardFrame.size.height;
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
            [self.delegate inputController:self didChangeHeight:CGRectGetMaxY(self.referencePreviewBar.frame) + keyboradHeight];
        }
    } else if (self.status == Input_Status_Input_Face) {
        [self.inputBar changeToKeyboard];
    } else {
        [self.inputBar.inputTextView becomeFirstResponder];
    }
}
- (void)showReplyPreview:(TUIReplyPreviewData_Minimalist *)data
{
    self.replyData = data;
    [self.replyPreviewBar removeFromSuperview];
    [self.view addSubview:self.replyPreviewBar];
    self.inputBar.lineView.hidden = YES;
    
    self.replyPreviewBar.previewData = data;
    
    self.replyPreviewBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, TMenuView_Menu_Height);
    self.inputBar.mm_y = CGRectGetMaxY(self.replyPreviewBar.frame);
    if (self.status == Input_Status_Input_Keyboard) {
        CGFloat keyboradHeight = self.keyboardFrame.size.height;
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
            [self.delegate inputController:self didChangeHeight:CGRectGetMaxY(self.inputBar.frame) + keyboradHeight];
        }
    } else if (self.status == Input_Status_Input_Face) {
        [self.inputBar changeToKeyboard];
    } else {
        [self.inputBar.inputTextView becomeFirstResponder];
    }
}

- (void)exitReply
{
    if (self.replyData == nil && self.referenceData == nil) {
        return;
    }
    self.replyData = nil;
    self.referenceData = nil;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.replyPreviewBar.hidden = YES;
        weakSelf.referencePreviewBar.hidden = YES;
        weakSelf.inputBar.mm_y = 0;
        
        if (weakSelf.status == Input_Status_Input_Keyboard) {
            CGFloat keyboradHeight = weakSelf.keyboardFrame.size.height;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
                [weakSelf.delegate inputController:weakSelf didChangeHeight:CGRectGetMaxY(weakSelf.inputBar.frame) + keyboradHeight];
            }
        } else {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
                [weakSelf.delegate inputController:weakSelf didChangeHeight:CGRectGetMaxY(weakSelf.inputBar.frame) + Bottom_SafeHeight];
            }
        }
        
    } completion:^(BOOL finished) {
        [weakSelf.replyPreviewBar removeFromSuperview];
        [weakSelf.referencePreviewBar removeFromSuperview];
        weakSelf.replyPreviewBar = nil;
        weakSelf.referencePreviewBar = nil;
        [weakSelf hideFaceAnimation];
        weakSelf.inputBar.lineView.hidden = NO;
    }];
}

- (void)exitReplyAndReference:(void (^ __nullable)(void))finishedCallback {
    if (self.replyData == nil && self.referenceData == nil) {
        if (finishedCallback) {
            finishedCallback();
        }
        return;
    }
    self.replyData = nil;
    self.referenceData = nil;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.replyPreviewBar.hidden = YES;
        weakSelf.referencePreviewBar.hidden = YES;
        weakSelf.inputBar.mm_y = 0;
        
        if (weakSelf.status == Input_Status_Input_Keyboard) {
            CGFloat keyboradHeight = weakSelf.keyboardFrame.size.height;
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
                [weakSelf.delegate inputController:weakSelf didChangeHeight:CGRectGetMaxY(weakSelf.inputBar.frame) + keyboradHeight];
            }
        } else {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
                [weakSelf.delegate inputController:weakSelf didChangeHeight:CGRectGetMaxY(weakSelf.inputBar.frame) + Bottom_SafeHeight];
            }
        }
        
    } completion:^(BOOL finished) {
        [weakSelf.replyPreviewBar removeFromSuperview];
        [weakSelf.referencePreviewBar removeFromSuperview];
        weakSelf.replyPreviewBar = nil;
        weakSelf.referencePreviewBar = nil;
        [weakSelf hideFaceAnimation];
        weakSelf.inputBar.lineView.hidden = NO;
        if (finishedCallback) {
            finishedCallback();
        }
    }];
}

- (void)menuView:(TUIMenuView_Minimalist *)menuView didSelectItemAtIndex:(NSInteger)index
{
    [self.faceView scrollToFaceGroupIndex:index];
}

- (void)menuViewDidSendMessage:(TUIMenuView_Minimalist *)menuView
{
    NSString *text = [_inputBar getInput];
    if([text isEqualToString:@""]){
        return;
    }
    /**
     * 表情国际化 --> 恢复成实际的中文 key
     * Emoticon internationalization --> restore to actual Chinese key
     */
    NSString *content = [text getInternationalStringWithfaceContent];
    [_inputBar clearInput];
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createTextMessage:content];
    [self appendReplyDataIfNeeded:message];
    [self appendReferenceDataIfNeeded:message];
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:message];
    }
}

- (void)faceView:(TUIFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index
{
    [self.menuView scrollToMenuIndex:index];
}

- (void)faceViewDidBackDelete:(TUIFaceView *)faceView
{
    [_inputBar backDelete];
}

- (void)faceView:(TUIFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TUIFaceGroup *group = [TUIConfig defaultConfig].faceGroups[indexPath.section];
    TUIFaceCellData *face = group.faces[indexPath.row];
    if(indexPath.section == 0){
        [_inputBar addEmoji:face];
    }
    else{
        if (face.name) {
            V2TIMMessage *message = [[V2TIMManager sharedInstance] createFaceMessage:group.groupIndex data:[face.name dataUsingEncoding:NSUTF8StringEncoding]];
            if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
                [_delegate inputController:self didSendMessage:message];
            }
        }
    }
}


#pragma mark - lazy load
- (TUIFaceView *)faceView
{
    if(!_faceView){
        _faceView = [[TUIFaceView alloc] initWithFrame:CGRectMake(0, _menuView.mm_maxY, self.view.mm_w, TFaceView_Height)];
        _faceView.backgroundColor = [UIColor whiteColor];
        _faceView.faceCollectionView.backgroundColor = _faceView.backgroundColor;
        _faceView.delegate = self;
        [_faceView setData:[TUIConfig defaultConfig].faceGroups];
    }
    return _faceView;
}

- (TUIMoreView_Minimalist *)moreView
{
    if(!_moreView){
        _moreView = [[TUIMoreView_Minimalist alloc] initWithFrame:CGRectMake(0, _inputBar.frame.origin.y + _inputBar.frame.size.height, self.view.mm_w, 0)];
        _moreView.delegate = self;
    }
    return _moreView;
}

- (TUIMenuView_Minimalist *)menuView
{
    if(!_menuView){
        _menuView = [[TUIMenuView_Minimalist alloc] initWithFrame:CGRectMake(0, _inputBar.mm_maxY, self.view.mm_w, TMenuView_Menu_Height)];
        _menuView.delegate = self;

        TUIConfig *config = [TUIConfig defaultConfig];
        NSMutableArray *menus = [NSMutableArray array];
        for (NSInteger i = 0; i < config.faceGroups.count; ++i) {
            TUIFaceGroup *group = config.faceGroups[i];
            TUIMenuCellData_Minimalist *data = [[TUIMenuCellData_Minimalist alloc] init];
            data.path = group.menuPath;
            data.isSelected = NO;
            if(i == 0){
                data.isSelected = YES;
            }
            [menus addObject:data];
        }
        [_menuView setData:menus];
    }
    return _menuView;
}

- (TUIReplyPreviewBar_Minimalist *)replyPreviewBar
{
    if (_replyPreviewBar == nil) {
        _replyPreviewBar = [[TUIReplyPreviewBar_Minimalist alloc] init];
        __weak typeof(self) weakSelf = self;
        _replyPreviewBar.onClose = ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf exitReply];
        };
    }
    return _replyPreviewBar;
}

- (TUIReferencePreviewBar_Minimalist *)referencePreviewBar {
    if (_referencePreviewBar == nil) {
        _referencePreviewBar = [[TUIReferencePreviewBar_Minimalist alloc] init];
        __weak typeof(self) weakSelf = self;
        _referencePreviewBar.onClose = ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf exitReply];
        };
    }
    return _referencePreviewBar;
}

- (CGFloat)getInputContainerBottom {
    CGFloat inputHeight = CGRectGetMaxY(_inputBar.frame);
    if (_referencePreviewBar) {
        inputHeight = CGRectGetMaxY(_referencePreviewBar.frame) ;
    }
    return inputHeight;
}

@end
