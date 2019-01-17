//
//  TInputController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TInputController.h"
#import "TMenuCell.h"
#import "TMoreCell.h"
#import "TFaceCell.h"
#import "TFaceMessageCell.h"
#import "TTextMessageCell.h"
#import "TVoiceMessageCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSUInteger, InputStatus) {
    Input_Status_Input,
    Input_Status_Input_Face,
    Input_Status_Input_More,
    Input_Status_Input_Keyboard,
    Input_Status_Input_Talk,
};

@interface TInputController () <TTextViewDelegate, TMenuViewDelegate, TFaceViewDelegate, TMoreViewDelegate>
@property (nonatomic, assign) InputStatus status;
@end

@implementation TInputController
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

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews
{
    self.view.backgroundColor = TInputView_Background_Color;
    _status = Input_Status_Input;
    
    _textView = [[TTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TTextView_Height)];
    _textView.delegate = self;
    [self.view addSubview:_textView];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
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
        [_delegate inputController:self didChangeHeight:keyboardFrame.size.height + _textView.frame.size.height];
    }
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
        newFrame.origin.y = ws.textView.frame.origin.y + ws.textView.frame.size.height;
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
        newFrame.origin.y = ws.textView.frame.origin.y + ws.textView.frame.size.height;
        ws.moreView.frame = newFrame;
    } completion:nil];
}

- (void)textViewDidTouchVoice:(TTextView *)textView
{
    if(_status == Input_Status_Input_Talk){
        return;
    }
    [_textView.inputTextView resignFirstResponder];
    [self hideFaceAnimation];
    [self hideMoreAnimation];
    _status = Input_Status_Input_Talk;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:TTextView_Height + Bottom_SafeHeight];
    }
}

- (void)textViewDidTouchMore:(TTextView *)textView
{
    if([[TUIKit sharedInstance] getConfig].moreMenus.count == 0){
        return;
    }
    if(_status == Input_Status_Input_More){
        return;
    }
    if(_status == Input_Status_Input_Face){
        [self hideFaceAnimation];
    }
    [_textView.inputTextView resignFirstResponder];
    [self showMoreAnimation];
    _status = Input_Status_Input_More;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_textView.frame.size.height + self.moreView.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)textViewDidTouchFace:(TTextView *)textView
{
    if([[TUIKit sharedInstance] getConfig].faceGroups.count == 0){
        return;
    }
    if(_status == Input_Status_Input_Face){
        return;
    }
    if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    [_textView.inputTextView resignFirstResponder];
    [self showFaceAnimation];
    _status = Input_Status_Input_Face;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_textView.frame.size.height + self.faceView.frame.size.height + self.menuView.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)textView:(TTextView *)textView didChangeInputHeight:(CGFloat)offset
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

- (void)textView:(TTextView *)textView didSendMessage:(NSString *)text
{
    TTextMessageCellData *data = [[TTextMessageCellData alloc] init];
    data.head = TUIKitResource(@"default_head");
    data.content = text;
    data.isSelf = YES;
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:data];
    }
}

- (void)textView:(TTextView *)textView didSendVoice:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    int duration = (int)CMTimeGetSeconds(audioAsset.duration);
    int length = (int)[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    
    TVoiceMessageCellData *voice = [[TVoiceMessageCellData alloc] init];
    voice.path = path;
    voice.duration = duration;
    voice.length = length;
    voice.isSelf = YES;
    voice.head = TUIKitResource(@"default_head");
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:voice];
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
    [_textView.inputTextView resignFirstResponder];
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_textView.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)menuView:(TMenuView *)menuView didSelectItemAtIndex:(NSInteger)index
{
    [self.faceView scrollToFaceGroupIndex:index];
}

- (void)menuViewDidSendMessage:(TMenuView *)menuView
{
    NSString *text = [_textView getInput];
    if([text isEqualToString:@""]){
        return;
    }
    [_textView clearInput];
    TTextMessageCellData *data = [[TTextMessageCellData alloc] init];
    data.head = TUIKitResource(@"default_head");
    data.content = text;
    data.isSelf = YES;
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:data];
    }
}

- (void)faceView:(TFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index
{
    [self.menuView scrollToMenuIndex:index];
}

- (void)faceViewDidBackDelete:(TFaceView *)faceView
{
    [_textView backDelete];
}

- (void)faceView:(TFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFaceGroup *group = [[TUIKit sharedInstance] getConfig].faceGroups[indexPath.section];
    TFaceCellData *face = group.faces[indexPath.row];
    if(indexPath.section == 0){
        [_textView addEmoji:face.name];
    }
    else{
        TFaceMessageCellData *data = [[TFaceMessageCellData alloc] init];
        data.groupIndex = group.groupIndex;
        data.head = TUIKitResource(@"default_head");
        data.path = face.path;
        data.faceName = face.name;
        data.isSelf = YES;
        if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
            [_delegate inputController:self didSendMessage:data];
        }
    }
}

#pragma mark - more view delegate
- (void)moreView:(TMoreView *)moreView didSelectMoreAtIndex:(NSInteger)index
{
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSelectMoreAtIndex:)]){
        [_delegate inputController:self didSelectMoreAtIndex:index];
    }
}

#pragma mark - lazy load
- (TFaceView *)faceView
{
    if(!_faceView){
        _faceView = [[TFaceView alloc] initWithFrame:CGRectMake(0, _textView.frame.origin.y + _textView.frame.size.height, self.view.frame.size.width, TFaceView_Height)];
        _faceView.delegate = self;
        [_faceView setData:[[TUIKit sharedInstance] getConfig].faceGroups];
    }
    return _faceView;
}

- (TMoreView *)moreView
{
    if(!_moreView){
        _moreView = [[TMoreView alloc] initWithFrame:CGRectMake(0, _textView.frame.origin.y + _textView.frame.size.height, self.faceView.frame.size.width, 0)];
        _moreView.delegate = self;
        [_moreView setData:[[TUIKit sharedInstance] getConfig].moreMenus];
    }
    return _moreView;
}

- (TMenuView *)menuView
{
    if(!_menuView){
        _menuView = [[TMenuView alloc] initWithFrame:CGRectMake(0, self.faceView.frame.origin.y + self.faceView.frame.size.height, self.view.frame.size.width, TMenuView_Menu_Height)];
        _menuView.delegate = self;
        
        TUIKitConfig *config = [[TUIKit sharedInstance] getConfig];
        NSMutableArray *menus = [NSMutableArray array];
        for (NSInteger i = 0; i < config.faceGroups.count; ++i) {
            TFaceGroup *group = config.faceGroups[i];
            TMenuCellData *data = [[TMenuCellData alloc] init];
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
@end
