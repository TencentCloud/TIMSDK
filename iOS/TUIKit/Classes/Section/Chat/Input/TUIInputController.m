//
//  TInputController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIInputController.h"
#import "TUIMenuCell.h"
#import "TUIInputMoreCell.h"
#import "TUIFaceCell.h"
#import "TUIFaceMessageCell.h"
#import "TUITextMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSUInteger, InputStatus) {
    Input_Status_Input,
    Input_Status_Input_Face,
    Input_Status_Input_More,
    Input_Status_Input_Keyboard,
    Input_Status_Input_Talk,
};

@interface TUIInputController () <TTextViewDelegate, TMenuViewDelegate, TFaceViewDelegate, TMoreViewDelegate>
@property (nonatomic, assign) InputStatus status;
@property (nonatomic, strong) NSMutableDictionary *localizableDictionary;
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
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];
    _status = Input_Status_Input;

    _inputBar = [[TUIInputBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TTextView_Height)];
    _inputBar.delegate = self;
    [self.view addSubview:_inputBar];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // http://tapd.oa.com/20398462/bugtrace/bugs/view?bug_id=1020398462072883317&url_cache_key=b8dc0f6bee40dbfe0e702ef8cebd5d81
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + Bottom_SafeHeight];
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
        [_delegate inputController:self didChangeHeight:keyboardFrame.size.height + _inputBar.frame.size.height];
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
        newFrame.origin.y = ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
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
        [_delegate inputController:self didChangeHeight:TTextView_Height + Bottom_SafeHeight];
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
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + self.moreView.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)inputBarDidTouchFace:(TUIInputBar *)textView
{
    if([TUIKit sharedInstance].config.faceGroups.count == 0){
        return;
    }
    if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    [_inputBar.inputTextView resignFirstResponder];
    [self showFaceAnimation];
    _status = Input_Status_Input_Face;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + self.faceView.frame.size.height + self.menuView.frame.size.height + Bottom_SafeHeight];
    }
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
    // 表情本地化 --> 恢复成实际的中文 key
    NSString *content = [self faceContentWithLocalizableString:text];
    TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    data.content = content;
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:data];
    }
}

- (void)inputBar:(TUIInputBar *)textView didSendVoice:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    int duration = (int)CMTimeGetSeconds(audioAsset.duration);
    int length = (int)[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];

    TUIVoiceMessageCellData *voice = [[TUIVoiceMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    voice.path = path;
    voice.duration = duration;
    voice.length = length;
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:voice];
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
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + Bottom_SafeHeight];
    }
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
    NSString *content = [self faceContentWithLocalizableString:text];
    [_inputBar clearInput];
    TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    data.content = content;
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:data];
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
    TFaceGroup *group = [TUIKit sharedInstance].config.faceGroups[indexPath.section];
    TFaceCellData *face = group.faces[indexPath.row];
    if(indexPath.section == 0){
        // 表情本地化 - 将中文 key 转换成 对应的 本地化语言。eg,英文环境下 [大哭] --> [Cry]
        NSString *localizableFaceName = face.localizableName.length ? face.localizableName : face.name;
        @synchronized (self) {
            self.localizableDictionary[localizableFaceName] = face.name;
        }
        [_inputBar addEmoji:localizableFaceName];
    }
    else{
        TUIFaceMessageCellData *data = [[TUIFaceMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
        data.groupIndex = group.groupIndex;
        data.path = face.path;
        data.faceName = face.name;
        if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
            [_delegate inputController:self didSendMessage:data];
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
        [_faceView setData:[TUIKit sharedInstance].config.faceGroups];
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

        TUIKitConfig *config = [TUIKit sharedInstance].config;
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

#pragma mark - 表情国际化
- (NSString *)faceContentWithLocalizableString:(NSString *)localizableString
{
    NSString *content = localizableString;
    NSString *regex_emoji = @"\\[[a-z\\s*A-Z\\s*0-9!-@\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (re) {
        NSArray *resultArray = [re matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        NSMutableArray *waitingReplaceM = [NSMutableArray array];
        for(NSTextCheckingResult *match in resultArray) {
            NSRange range = [match range];
            NSString *subStr = [content substringWithRange:range];
            [waitingReplaceM addObject:@{
                @"range":NSStringFromRange(range),
                @"localizableStr": self.localizableDictionary[subStr]?:subStr
            }];
        }
        
        if (waitingReplaceM.count != 0) {
            // 从后往前替换，否则会引起位置问题
            for (int i = (int)waitingReplaceM.count -1; i >= 0; i--) {
                NSRange range = NSRangeFromString(waitingReplaceM[i][@"range"]);
                NSString *localizableStr = waitingReplaceM[i][@"localizableStr"];
                content = [content stringByReplacingCharactersInRange:range withString:localizableStr];
            }
        }
    }
    return content;
}


- (NSMutableDictionary *)localizableDictionary
{
    if (_localizableDictionary == nil) {
        _localizableDictionary = [NSMutableDictionary dictionary];
    }
    return _localizableDictionary;
}

@end
