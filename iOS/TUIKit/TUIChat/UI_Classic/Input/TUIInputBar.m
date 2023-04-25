//
//  TUIInputBar.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIInputBar.h"
#import "TUIRecordView.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUITool.h>
#import <TIMCommon/TIMDefine.h>

#import "ReactiveObjC/ReactiveObjC.h"
#import <TUICore/UIView+TUILayout.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIGlobalization.h>
#import <TIMCommon/NSTimer+TUISafe.h>
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TUICore/TUICore.h>
#import "TUIAudioRecorder.h"

@interface TUIInputBar() <UITextViewDelegate, TUIAudioRecorderDelegate>
@property (nonatomic, strong) TUIRecordView *recordView;
@property (nonatomic, strong) NSDate *recordStartTime;

@property (nonatomic, strong) TUIAudioRecorder *recorder;

@property (nonatomic, assign) BOOL isFocusOn;
@property (nonatomic, strong) NSTimer *sendTypingStatusTimer;
@property (nonatomic, assign) BOOL allowSendTypingStatusByChangeWord;
@end

@implementation TUIInputBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];
    }
    return self;
}

- (void)dealloc {
    if (_sendTypingStatusTimer) {
        [_sendTypingStatusTimer invalidate];
        _sendTypingStatusTimer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = TUIChatDynamicColor(@"chat_input_controller_bg_color", @"#EBF0F6");

    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#FFFFFF");

    _micButton = [[UIButton alloc] init];
    [_micButton addTarget:self action:@selector(onMicButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_micButton setImage:TUIChatBundleThemeImage(@"chat_ToolViewInputVoice_img",@"ToolViewInputVoice")         forState:UIControlStateNormal];
    [_micButton setImage: TUIChatBundleThemeImage(@"chat_ToolViewInputVoiceHL_img", @"ToolViewInputVoiceHL")
                forState:UIControlStateHighlighted];
    [self addSubview:_micButton];

    _faceButton = [[UIButton alloc] init];
    [_faceButton addTarget:self action:@selector(onFaceEmojiButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_faceButton setImage: TUIChatBundleThemeImage(@"chat_ToolViewEmotion_img", @"ToolViewEmotion")
                 forState:UIControlStateNormal];
    [_faceButton setImage: TUIChatBundleThemeImage(@"chat_ToolViewEmotionHL_img",@"ToolViewEmotionHL")
                 forState:UIControlStateHighlighted];
    [self addSubview:_faceButton];
    
    _keyboardButton = [[UIButton alloc] init];
    [_keyboardButton addTarget:self action:@selector(onKeyboardButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardButton setImage:TUIChatBundleThemeImage(@"chat_ToolViewKeyboard_img", @"ToolViewKeyboard") forState:UIControlStateNormal];
    [_keyboardButton setImage:TUIChatBundleThemeImage(@"chat_ToolViewKeyboardHL_img", @"ToolViewKeyboardHL")
                     forState:UIControlStateHighlighted];
    _keyboardButton.hidden = YES;
    [self addSubview:_keyboardButton];

    _moreButton = [[UIButton alloc] init];
    [_moreButton addTarget:self action:@selector(onMoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_moreButton setImage:TUIChatBundleThemeImage(@"chat_TypeSelectorBtn_Black_img",@"TypeSelectorBtn_Black")          forState:UIControlStateNormal];
    [_moreButton setImage:TUIChatBundleThemeImage(@"chat_TypeSelectorBtnHL_Black_img",@"TypeSelectorBtnHL_Black")
                 forState:UIControlStateHighlighted];
    [self addSubview:_moreButton];

    _recordButton = [[UIButton alloc] init];
    [_recordButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [_recordButton addTarget:self action:@selector(onRecordButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(onRecordButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(onRecordButtonTouchCancel:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [_recordButton addTarget:self action:@selector(onRecordButtonTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [_recordButton addTarget:self action:@selector(onRecordButtonTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [_recordButton setTitle:TIMCommonLocalizableString(TUIKitInputHoldToTalk) forState:UIControlStateNormal];
    [_recordButton setTitleColor:TUIChatDynamicColor(@"chat_input_text_color", @"#000000") forState:UIControlStateNormal];
    _recordButton.hidden = YES;
    [self addSubview:_recordButton];

    _inputTextView = [[TUIResponderTextView alloc] init];
    _inputTextView.delegate = self;
    [_inputTextView setFont:kTUIInputNoramlFont];
    _inputTextView.backgroundColor = TUIChatDynamicColor(@"chat_input_bg_color", @"#FFFFFF");
    _inputTextView.textColor = TUIChatDynamicColor(@"chat_input_text_color", @"#000000");
    [_inputTextView setReturnKeyType:UIReturnKeySend];
    [self addSubview:_inputTextView];

    [self applyBorderTheme];
}

- (void)onThemeChanged {
    [self applyBorderTheme];
}

- (void)applyBorderTheme {
    if (_recordButton) {
        [_recordButton.layer setMasksToBounds:YES];
        [_recordButton.layer setCornerRadius:4.0f];
        [_recordButton.layer setBorderWidth:0.5f];
        [_recordButton.layer setBorderColor:TIMCommonDynamicColor(@"separator_color", @"#DBDBDB").CGColor];
    }
    
    if (_inputTextView) {
        [_inputTextView.layer setMasksToBounds:YES];
        [_inputTextView.layer setCornerRadius:4.0f];
        [_inputTextView.layer setBorderWidth:0.5f];
        [_inputTextView.layer setBorderColor:TIMCommonDynamicColor(@"separator_color", @"#DBDBDB").CGColor];
    }
}

- (void)defaultLayout {
    _lineView.frame = CGRectMake(0, 0, Screen_Width, TLine_Heigh);
    CGSize buttonSize = TTextView_Button_Size;
    CGFloat buttonOriginY = (TTextView_Height - buttonSize.height) * 0.5;
    _micButton.frame = CGRectMake(TTextView_Margin, buttonOriginY, buttonSize.width, buttonSize.height);
    _keyboardButton.frame = _micButton.frame;
    _moreButton.frame = CGRectMake(Screen_Width - buttonSize.width - TTextView_Margin, buttonOriginY, buttonSize.width, buttonSize.height);
    _faceButton.frame = CGRectMake(_moreButton.frame.origin.x - buttonSize.width - TTextView_Margin, buttonOriginY, buttonSize.width, buttonSize.height);

    CGFloat beginX = _micButton.frame.origin.x + _micButton.frame.size.width + TTextView_Margin;
    CGFloat endX = _faceButton.frame.origin.x - TTextView_Margin;
    _recordButton.frame = CGRectMake(beginX, (TTextView_Height - TTextView_TextView_Height_Min) * 0.5, endX - beginX, TTextView_TextView_Height_Min);
    _inputTextView.frame = _recordButton.frame;
}

- (void)layoutButton:(CGFloat)height {
    CGRect frame = self.frame;
    CGFloat offset = height - frame.size.height;
    frame.size.height = height;
    self.frame = frame;

    CGSize buttonSize = TTextView_Button_Size;
    CGFloat bottomMargin = (TTextView_Height - buttonSize.height) * 0.5;
    CGFloat originY = frame.size.height - buttonSize.height - bottomMargin;

    CGRect faceFrame = _faceButton.frame;
    faceFrame.origin.y = originY;
    _faceButton.frame = faceFrame;

    CGRect moreFrame = _moreButton.frame;
    moreFrame.origin.y = originY;
    _moreButton.frame = moreFrame;

    CGRect voiceFrame = _micButton.frame;
    voiceFrame.origin.y = originY;
    _micButton.frame = voiceFrame;

    _keyboardButton.frame = _faceButton.frame;

    if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didChangeInputHeight:)]){
        [_delegate inputBar:self didChangeInputHeight:offset];
    }
}

#pragma mark - Event response
- (void)onMicButtonClicked:(UIButton *)sender {
    _recordButton.hidden = NO;
    _inputTextView.hidden = YES;
    _micButton.hidden = YES;
    _keyboardButton.hidden = NO;
    _faceButton.hidden = NO;
    [_inputTextView resignFirstResponder];
    [self layoutButton:TTextView_Height];
    if (_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchMore:)]) {
        [_delegate inputBarDidTouchVoice:self];
    }
    _keyboardButton.frame = _micButton.frame;
}

- (void)onKeyboardButtonClicked:(UIButton *)sender {
    _micButton.hidden = NO;
    _keyboardButton.hidden = YES;
    _recordButton.hidden = YES;
    _inputTextView.hidden = NO;
    _faceButton.hidden = NO;
    [self layoutButton:_inputTextView.frame.size.height + 2 * TTextView_Margin];
    if (_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchKeyboard:)]) {
        [_delegate inputBarDidTouchKeyboard:self];
    }
}

- (void)onFaceEmojiButtonClicked:(UIButton *)sender {
    _micButton.hidden = NO;
    _faceButton.hidden = YES;
    _keyboardButton.hidden = NO;
    _recordButton.hidden = YES;
    _inputTextView.hidden = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchFace:)]) {
        [_delegate inputBarDidTouchFace:self];
    }
    _keyboardButton.frame = _faceButton.frame;
}

- (void)onMoreButtonClicked:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchMore:)]) {
        [_delegate inputBarDidTouchMore:self];
    }
}

- (void)onRecordButtonTouchDown:(UIButton *)sender {
    [self.recorder record];
}

- (void)onRecordButtonTouchUpInside:(UIButton *)sender {
    self.recordButton.backgroundColor = [UIColor clearColor];
    [self.recordButton setTitle:TIMCommonLocalizableString(TUIKitInputHoldToTalk)
                       forState:UIControlStateNormal];
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.recordStartTime];
    @weakify(self);
    if (interval < 1) {
        [self.recordView setStatus:Record_Status_TooShort];
        [self.recorder cancel];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.recordView removeFromSuperview];
        });
    } else if (interval > 60) {
        [self.recordView setStatus:Record_Status_TooLong];
        [self.recorder cancel];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.recordView removeFromSuperview];
        });
    } else {
        dispatch_queue_t main_queue = dispatch_get_main_queue();
        dispatch_async(main_queue, ^{
            @strongify(self);
            /// TUICallKit may need some time to stop all services, so remove UI immediately then stop the recorder.
            [self.recordView removeFromSuperview];
            self.recordView = nil;
            dispatch_async(main_queue, ^{
                [self.recorder stop];
                NSString *path = self.recorder.recordedFilePath;
                if (path) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:didSendVoice:)]){
                        [self.delegate inputBar:self didSendVoice:path];
                    }
                }
            });
        });
    }
}

- (void)onRecordButtonTouchCancel:(UIButton *)sender {
    [self.recordView removeFromSuperview];
    self.recordButton.backgroundColor = [UIColor clearColor];
    [self.recordButton setTitle:TIMCommonLocalizableString(TUIKitInputHoldToTalk) forState:UIControlStateNormal];
    [self.recorder cancel];
}

- (void)onRecordButtonTouchDragExit:(UIButton *)sender {
    [self.recordView setStatus:Record_Status_Cancel];
    [_recordButton setTitle:TIMCommonLocalizableString(TUIKitInputReleaseToCancel) forState:UIControlStateNormal];
}

- (void)onRecordButtonTouchDragEnter:(UIButton *)sender {
    [self.recordView setStatus:Record_Status_Recording];
    [_recordButton setTitle:TIMCommonLocalizableString(TUIKitInputReleaseToSend) forState:UIControlStateNormal];
}

- (void)showHapticFeedback {
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];
            [generator prepare];
            [generator impactOccurred];
        });
        
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - Text input
#pragma mark -- UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.keyboardButton.hidden = YES;
    self.micButton.hidden = NO;
    self.faceButton.hidden = NO;
    
    self.isFocusOn = YES;
    self.allowSendTypingStatusByChangeWord  = YES;
    
    __weak typeof(self) weakSelf = self;
    self.sendTypingStatusTimer = [NSTimer tui_scheduledTimerWithTimeInterval:4 repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.allowSendTypingStatusByChangeWord = YES;
    }];
    
    if (self.isFocusOn &&[textView.textStorage getPlainString].length > 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(inputTextViewShouldBeginTyping:)]) {
            [_delegate inputTextViewShouldBeginTyping:textView];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    self.isFocusOn = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(inputTextViewShouldEndTyping:)]) {
        [_delegate inputTextViewShouldEndTyping:textView];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.allowSendTypingStatusByChangeWord && self.isFocusOn &&[textView.textStorage getPlainString].length > 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(inputTextViewShouldBeginTyping:)]) {
            self.allowSendTypingStatusByChangeWord = NO;
            [_delegate inputTextViewShouldBeginTyping:textView];
        }
    }
    
    if (self.isFocusOn && [textView.textStorage getPlainString].length == 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(inputTextViewShouldEndTyping:)]) {
            [_delegate inputTextViewShouldEndTyping:textView];
        }
    }
    CGSize size = [_inputTextView sizeThatFits:CGSizeMake(_inputTextView.frame.size.width, TTextView_TextView_Height_Max)];
    CGFloat oldHeight = _inputTextView.frame.size.height;
    CGFloat newHeight = size.height;

    if(newHeight > TTextView_TextView_Height_Max){
        newHeight = TTextView_TextView_Height_Max;
    }
    if(newHeight < TTextView_TextView_Height_Min){
        newHeight = TTextView_TextView_Height_Min;
    }
    if(oldHeight == newHeight){
        return;
    }

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect textFrame = ws.inputTextView.frame;
        textFrame.size.height += newHeight - oldHeight;
        ws.inputTextView.frame = textFrame;
        [ws layoutButton:newHeight + 2 * TTextView_Margin];
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text containsString:@"["] && [text containsString:@"]"] ) {
        NSRange selectedRange = textView.selectedRange;
        if (selectedRange.length > 0) {
            [textView.textStorage deleteCharactersInRange:selectedRange];
        }
    
        NSMutableAttributedString *textChange = [text getAdvancedFormatEmojiStringWithFont:kTUIInputNoramlFont textColor:kTUIInputNormalTextColor emojiLocations:nil];
        [textView.textStorage insertAttributedString:textChange atIndex:textView.textStorage.length];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.inputTextView.selectedRange = NSMakeRange(self.inputTextView.textStorage.length + 1, 0);
        });
        return NO;
    }
    
    if([text isEqualToString:@"\n"]){
        if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didSendText:)]) {
            NSString *sp = [[textView.textStorage getPlainString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (sp.length == 0) {
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitInputBlankMessageTitle) message:nil preferredStyle:UIAlertControllerStyleAlert];
                [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm) style:UIAlertActionStyleDefault handler:nil]];
                [self.mm_viewController presentViewController:ac animated:YES completion:nil];
            } else {
                [_delegate inputBar:self didSendText:[textView.textStorage getPlainString]];
                [self clearInput];
            }
        }
        return NO;
    }
    else if ([text isEqualToString:@""]) {
        
        if (textView.textStorage.length > range.location) {
            // 一次性删除 @xxx 这种 @ 消息
            // Delete the @ message like @xxx at one time
            NSAttributedString *lastAttributedStr = [textView.textStorage attributedSubstringFromRange:NSMakeRange(range.location , 1)];
            NSString *lastStr = [lastAttributedStr getPlainString];
            if (lastStr &&  lastStr.length>0 && [lastStr characterAtIndex:0] == ' ') {
                NSUInteger location = range.location;
                NSUInteger length = range.length;
                
                // '@' 对应的ascii码 '@'
                // corresponds to ascii code
                int at = 64;
                // 空格(space) 对应的ascii码
                // Space (space) corresponding ascii code
                int space = 32;
                
                while (location != 0) {
                    location --;
                    length ++ ;
                    // 将字符转成ascii码，复制给int,避免越界
                    // Convert characters to ascii code, copy to int, avoid out of bounds
                    int c = (int)[[[textView.textStorage attributedSubstringFromRange:NSMakeRange(location, 1)] getPlainString] characterAtIndex:0];
                    
                    if (c == at) {
                        NSString *atText = [[textView.textStorage attributedSubstringFromRange:NSMakeRange(location, length)] getPlainString];
                        UIFont *textFont = kTUIInputNoramlFont;
                        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: textFont}];
                        [textView.textStorage replaceCharactersInRange:NSMakeRange(location, length) withAttributedString:spaceString];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:didDeleteAt:)]) {
                            [self.delegate inputBar:self didDeleteAt:atText];
                        }
                        return NO;
                    }
                    else if (c == space) {
                        // 避免出现 "@昵称 你好，很高兴认识 你(space)  "" 在空格后按del 过度删除到@
                        // Avoid "@nickname Hello, nice to meet you (space) "" Press del after a space to over-delete to @
                        break;
                    }
                }
            }

        }
    }
    // 监听 @ 字符的输入，包含全角/半角
    // Monitor the input of @ character, including full-width/half-width
    else if ([text isEqualToString:@"@"] || [text isEqualToString:@"＠"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarDidInputAt:)]) {
            [self.delegate inputBarDidInputAt:self];
        }
    }
    return YES;
}

- (void)onDeleteBackward:(TUIResponderTextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarDidDeleteBackward:)]) {
        [self.delegate inputBarDidDeleteBackward:self];
    }
}

- (void)clearInput
{
    [_inputTextView.textStorage deleteCharactersInRange:NSMakeRange(0, _inputTextView.textStorage.length)];
    [self textViewDidChange:_inputTextView];
}

- (NSString *)getInput
{
    return [_inputTextView.textStorage getPlainString];
}

- (void)addEmoji:(TUIFaceCellData *)emoji
{
    //Create emoji attachment
    TUIEmojiTextAttachment *emojiTextAttachment = [[TUIEmojiTextAttachment alloc] init];
    emojiTextAttachment.faceCellData = emoji;

    NSString *localizableFaceName = emoji.localizableName.length ? emoji.localizableName : emoji.name;

    //Set tag and image
    emojiTextAttachment.emojiTag = localizableFaceName;
    emojiTextAttachment.image =  [[TUIImageCache sharedInstance] getFaceFromCache:emoji.path];
    
    //Set emoji size
    emojiTextAttachment.emojiSize = kChatDefaultEmojiSize;
    NSAttributedString *str = [NSAttributedString attributedStringWithAttachment:emojiTextAttachment];

    NSRange selectedRange = _inputTextView.selectedRange;
    if (selectedRange.length > 0) {
        [_inputTextView.textStorage deleteCharactersInRange:selectedRange];
    }
    //Insert emoji image
    [_inputTextView.textStorage insertAttributedString:str atIndex:_inputTextView.selectedRange.location];
    
    _inputTextView.selectedRange = NSMakeRange(_inputTextView.selectedRange.location+1, 0);
    [self resetTextStyle];

    if(_inputTextView.contentSize.height > TTextView_TextView_Height_Max){
        float offset = _inputTextView.contentSize.height - _inputTextView.frame.size.height;
        [_inputTextView scrollRectToVisible:CGRectMake(0, offset, _inputTextView.frame.size.width, _inputTextView.frame.size.height) animated:YES];
    }
    [self textViewDidChange:_inputTextView];
}

- (void)resetTextStyle {
    //After changing text selection, should reset style.
    NSRange wholeRange = NSMakeRange(0, _inputTextView.textStorage.length);

    [_inputTextView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    
    [_inputTextView.textStorage removeAttribute:NSForegroundColorAttributeName range:wholeRange];

    [_inputTextView.textStorage addAttribute:NSForegroundColorAttributeName value:kTUIInputNormalTextColor range:wholeRange];

    [_inputTextView.textStorage addAttribute:NSFontAttributeName value:kTUIInputNoramlFont range:wholeRange];
    [_inputTextView setFont:kTUIInputNoramlFont];
    
    // In iOS 15.0 and later, you need set styles again as belows
    _inputTextView.textColor = kTUIInputNormalTextColor;
    _inputTextView.font = kTUIInputNoramlFont;
}

- (void)backDelete {
    if (_inputTextView.textStorage.length > 0) {
        [_inputTextView.textStorage deleteCharactersInRange:NSMakeRange(_inputTextView.textStorage.length - 1, 1)];
        [self textViewDidChange:_inputTextView];
    }
}

- (void)updateTextViewFrame {
    [self textViewDidChange:[UITextView new]];
}

- (void)changeToKeyboard {
    [self onKeyboardButtonClicked:self.keyboardButton];
}

#pragma mark - TUIAudioRecorderDelegate
- (void)audioRecorder:(TUIAudioRecorder *)recorder
   didCheckPermission:(BOOL)isGranted
          isFirstTime:(BOOL)isFirstTime {
    if (isFirstTime) {
        if (!isGranted) {
            [self showRequestMicAuthorizationAlert];
        }
        return;
    }
    
    [self updateViewsToRecordingStatus];
}

- (void)showRequestMicAuthorizationAlert {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitInputNoMicTitle) message:TIMCommonLocalizableString(TUIKitInputNoMicTips) preferredStyle:UIAlertControllerStyleAlert];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitInputNoMicOperateLater) style:UIAlertActionStyleCancel handler:nil]];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(TUIKitInputNoMicOperateEnable) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([app canOpenURL:settingsURL]) {
            [app openURL:settingsURL];
        }
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mm_viewController presentViewController:ac animated:YES completion:nil];
    });
}

- (void)updateViewsToRecordingStatus {
    [self.window addSubview:self.recordView];
    self.recordStartTime = [NSDate date];
    [self.recordView setStatus:Record_Status_Recording];
    self.recordButton.backgroundColor = [UIColor lightGrayColor];
    [self.recordButton setTitle:TIMCommonLocalizableString(TUIKitInputReleaseToSend) forState:UIControlStateNormal];
    [self showHapticFeedback];
}

- (void)audioRecorder:(TUIAudioRecorder *)recorder didPowerChanged:(float)power {
    if (!self.recordView.hidden) {
        [self.recordView setPower:power];
    }
}

- (void)audioRecorder:(TUIAudioRecorder *)recorder didRecordTimeChanged:(NSTimeInterval)time {
    if (time >= 55 && time < 60) {
        NSInteger seconds = 60 - time;
        /**
         * 此处强转了 long 型，是为了消除编译器警告。
         * 此处 +1 是为了向上取整，优化时间逻辑。
         *
         * The long type is cast here to eliminate compiler warnings.
         * Here +1 is to round up and optimize the time logic.
         */
        self.recordView.title.text = [NSString stringWithFormat:TIMCommonLocalizableString(TUIKitInputWillFinishRecordInSeconds), (long)seconds + 1];
    } else if (time >= 60) {
        [self.recorder stop];
        NSString *path = self.recorder.recordedFilePath;
        [self.recordView setStatus:Record_Status_TooLong];

        @weakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.recordView removeFromSuperview];
        });
        if (path) {
            if (_delegate && [_delegate respondsToSelector:@selector(inputBar:didSendVoice:)]) {
                [_delegate inputBar:self didSendVoice:path];
            }
        }
    }
}

#pragma mark - Getter
- (TUIAudioRecorder *)recorder {
    if (!_recorder) {
        _recorder = [[TUIAudioRecorder alloc] init];
        _recorder.delegate = self;
    }
    return _recorder;
}

- (TUIRecordView *)recordView {
    if (!_recordView) {
        _recordView = [[TUIRecordView alloc] init];
        _recordView.frame = [UIScreen mainScreen].bounds;
    }
    return _recordView;
}

@end
