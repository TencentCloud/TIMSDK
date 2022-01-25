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

@interface TUIInputController () <TTextViewDelegate, TMenuViewDelegate, TFaceViewDelegate, TMoreViewDelegate>
@property (nonatomic, assign) InputStatus status;
@property (nonatomic, assign) CGRect keyboardFrame;
// 当前正在回复的消息
@property (nonatomic, strong) TUIReplyPreviewData *replyData;
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
        [_delegate inputController:self didChangeHeight:CGRectGetMaxY(_inputBar.frame) + Bottom_SafeHeight];
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
        [_delegate inputController:self didChangeHeight:keyboardFrame.size.height + CGRectGetMaxY(_inputBar.frame)];
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
        [_delegate inputController:self didChangeHeight:CGRectGetMaxY(_inputBar.frame) + Bottom_SafeHeight];
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
    }
}

- (void)inputBar:(TUIInputBar *)textView didSendText:(NSString *)text
{
    // 表情国际化 --> 恢复成实际的中文 key
    NSString *content = [text getInternationalStringWithfaceContent];
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createTextMessage:content];
    [self appendReplyDataIfNeeded:message];
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:message];
    }
}

- (void)appendReplyDataIfNeeded:(V2TIMMessage *)message
{
    if (self.replyData) {
        NSDictionary *dict = @{
            @"messageReply": @{
                    @"messageID"       : self.replyData.msgID?:@"",
                    @"messageAbstract" : [self.replyData.msgAbstract?:@"" getInternationalStringWithfaceContent],
                    @"messageSender"   : self.replyData.sender?:@"",
                    @"messageType"     : @(self.replyData.type),
                    @"version"         : @(kMessageReplyVersion)
            }
        };
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if (error == nil) {
            message.cloudCustomData = data;
        }
        [self exitReply];
    }
}

- (void)inputBar:(TUIInputBar *)textView didSendVoice:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    int duration = (int)CMTimeGetSeconds(audioAsset.duration);
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createSoundMessage:path duration:duration];
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
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
    // 点击键盘上的删除按钮
    if (textView.inputTextView.text.length == 0) {
        [self exitReply];
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
        [_delegate inputController:self didChangeHeight:CGRectGetMaxY(_inputBar.frame) + Bottom_SafeHeight];
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
    if (self.replyData == nil) {
        return;
    }
    self.replyData = nil;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.replyPreviewBar.hidden = YES;
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
        weakSelf.replyPreviewBar = nil;
        self.inputBar.lineView.hidden = NO;
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
    // 表情国际化 --> 恢复成实际的中文 key
    NSString *content = [text getInternationalStringWithfaceContent];
    [_inputBar clearInput];
    V2TIMMessage *message = [[V2TIMManager sharedInstance] createTextMessage:content];
    [self appendReplyDataIfNeeded:message];
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
        // 表情本地化 - 将中文 key 转换成 对应的 本地化语言。eg,英文环境下 [大哭] --> [Cry]
        NSString *localizableFaceName = face.localizableName.length ? face.localizableName : face.name;
        [_inputBar addEmoji:localizableFaceName];
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
            [weakSelf exitReply];
        };
    }
    return _replyPreviewBar;
}

@end
