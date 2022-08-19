//
//  TInputController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIInputController.h"
#import "TUIMenuCell.h"
#import "TUIMenuCellData.h"
#import "TUIInputMoreCell.h"
#import "TUICommonModel.h"
#import "TUIFaceMessageCell.h"
#import "TUITextMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIDefine.h"
#import "TUIDefine.h"
#import "TUIDarkModel.h"
#import "TUIMessageDataProvider.h"
#import "NSString+emoji.h"
#import <AVFoundation/AVFoundation.h>
#import "TUIThemeManager.h"
#import "TUICloudCustomDataTypeCenter.h"
#import "TUIChatDataProvider.h"
#import "TUIChatModifyMessageHelper.h"

@interface TUIInputController () <TTextViewDelegate, TMenuViewDelegate, TFaceViewDelegate, TMoreViewDelegate>
@property (nonatomic, assign) InputStatus status;
@property (nonatomic, assign) CGRect keyboardFrame;

@property (nonatomic, copy) void(^modifyRootReplyMsgBlock)(TUIMessageCellData *);
@end

@implementation TUIInputController
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
    self.view.backgroundColor = TUIChatDynamicColor(@"chat_input_controller_bg_color", @"#EBF0F6");
    _status = Input_Status_Input;
    
    _inputBar = [[TUIInputBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.replyPreviewBar.frame), self.view.frame.size.width, TTextView_Height)];
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
    [self.view addSubview:self.faceView];
    [self.view addSubview:self.menuView];

    self.faceView.hidden = NO;
    CGRect frame = self.faceView.frame;
    frame.origin.y = Screen_Height;
    self.faceView.frame = frame;

    self.menuView.hidden = NO;
    frame = self.menuView.frame;
    frame.origin.y = self.faceView.frame.origin.y + self.faceView.frame.size.height;
    self.menuView.frame = frame;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.faceView.frame;
        newFrame.origin.y = CGRectGetMaxY(ws.inputBar.frame); //ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
        ws.faceView.frame = newFrame;

        newFrame = ws.menuView.frame;
        newFrame.origin.y = ws.faceView.frame.origin.y + ws.faceView.frame.size.height;
        ws.menuView.frame = newFrame;
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

- (void)inputBarDidTouchVoice:(TUIInputBar *)textView
{
    if(_status == Input_Status_Input_Talk){
        return;
    }
    [_inputBar.inputTextView resignFirstResponder];
    [self hideFaceAnimation];
    [self hideMoreAnimation];
    _status = Input_Status_Input_Talk;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        CGFloat inputContainerBottom = [self getInputContainerBottom];
        [_delegate inputController:self didChangeHeight:inputContainerBottom + Bottom_SafeHeight];
    }
}

- (void)inputBarDidTouchMore:(TUIInputBar *)textView
{
    if(_status == Input_Status_Input_More){
        return;
    }
    if(_status == Input_Status_Input_Face){
        [self hideFaceAnimation];
    }
    [_inputBar.inputTextView resignFirstResponder];
    [self showMoreAnimation];
    _status = Input_Status_Input_More;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:CGRectGetMaxY(_inputBar.frame) + self.moreView.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)inputBarDidTouchFace:(TUIInputBar *)textView
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
        [_delegate inputController:self didChangeHeight:CGRectGetMaxY(_inputBar.frame) + self.faceView.frame.size.height + self.menuView.frame.size.height + Bottom_SafeHeight];
    }
    [self showFaceAnimation];
}

- (void)inputBarDidTouchKeyboard:(TUIInputBar *)textView
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

- (void)inputBar:(TUIInputBar *)textView didChangeInputHeight:(CGFloat)offset
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

- (void)inputBar:(TUIInputBar *)textView didSendText:(NSString *)text
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
        [TUIChatDataProvider findMessages:@[messageRootID] callback:^(BOOL succ, NSString * _Nonnull error_message, NSArray * _Nonnull msgs) {
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

- (void)inputBar:(TUIInputBar *)textView didSendVoice:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    int duration = (int)CMTimeGetSeconds(audioAsset.duration);
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createSoundMessage:path duration:duration];
    if (message && _delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:message];
    }
}

- (void)inputBarDidInputAt:(TUIInputBar *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputControllerDidInputAt:)]) {
        [_delegate inputControllerDidInputAt:self];
    }
}

- (void)inputBar:(TUIInputBar *)textView didDeleteAt:(NSString *)atText
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didDeleteAt:)]) {
        [_delegate inputController:self didDeleteAt:atText];
    }
}

- (void)inputBarDidDeleteBackward:(TUIInputBar *)textView
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

- (void)showReferencePreview:(TUIReferencePreviewData *)data {
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
    } else if (self.status == Input_Status_Input_Face ||
               self.status == Input_Status_Input_Talk) {
        [self.inputBar changeToKeyboard];
    } else {
        [self.inputBar.inputTextView becomeFirstResponder];
    }
}
- (void)showReplyPreview:(TUIReplyPreviewData *)data
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
    } else if (self.status == Input_Status_Input_Face ||
               self.status == Input_Status_Input_Talk) {
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

- (void)menuView:(TUIMenuView *)menuView didSelectItemAtIndex:(NSInteger)index
{
    [self.faceView scrollToFaceGroupIndex:index];
}

- (void)menuViewDidSendMessage:(TUIMenuView *)menuView
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

#pragma mark - more view delegate
- (void)moreView:(TUIMoreView *)moreView didSelectMoreCell:(TUIInputMoreCell *)cell
{
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSelectMoreCell:)]){
        [_delegate inputController:self didSelectMoreCell:cell];
    }
}

#pragma mark - lazy load
- (TUIFaceView *)faceView
{
    if(!_faceView){
        _faceView = [[TUIFaceView alloc] initWithFrame:CGRectMake(0, _inputBar.frame.origin.y + _inputBar.frame.size.height, self.view.frame.size.width, TFaceView_Height)];
        _faceView.delegate = self;
        [_faceView setData:[TUIConfig defaultConfig].faceGroups];
    }
    return _faceView;
}

- (TUIMoreView *)moreView
{
    if(!_moreView){
        _moreView = [[TUIMoreView alloc] initWithFrame:CGRectMake(0, _inputBar.frame.origin.y + _inputBar.frame.size.height, self.faceView.frame.size.width, 0)];
        _moreView.delegate = self;
    }
    return _moreView;
}

- (TUIMenuView *)menuView
{
    if(!_menuView){
        _menuView = [[TUIMenuView alloc] initWithFrame:CGRectMake(0, self.faceView.frame.origin.y + self.faceView.frame.size.height, self.view.frame.size.width, TMenuView_Menu_Height)];
        _menuView.delegate = self;

        TUIConfig *config = [TUIConfig defaultConfig];
        NSMutableArray *menus = [NSMutableArray array];
        for (NSInteger i = 0; i < config.faceGroups.count; ++i) {
            TUIFaceGroup *group = config.faceGroups[i];
            TUIMenuCellData *data = [[TUIMenuCellData alloc] init];
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

- (TUIReplyPreviewBar *)replyPreviewBar
{
    if (_replyPreviewBar == nil) {
        _replyPreviewBar = [[TUIReplyPreviewBar alloc] init];
        __weak typeof(self) weakSelf = self;
        _replyPreviewBar.onClose = ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf exitReply];
        };
    }
    return _replyPreviewBar;
}

- (TUIReferencePreviewBar *)referencePreviewBar {
    if (_referencePreviewBar == nil) {
        _referencePreviewBar = [[TUIReferencePreviewBar alloc] init];
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
