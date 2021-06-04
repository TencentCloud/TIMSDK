//
//  TUILiveCreateAnchorRoomView.m
//  Masonry
//
//  Created by abyyxwang on 2020/9/10.
//

#import "TUILiveCreateAnchorRoomView.h"
#import "TUILiveColor.h"
#import "Masonry.h"
#import "TUILiveUtil.h"
#import "SDWebImage.h"
#import "TLiveHeader.h"
#import "THelper.h"
#import "TUILiveUserProfile.h"
#import <AVFoundation/AVFoundation.h>

#define AUDIO_QUALITY_SELECTED_COLOR [UIColor colorWithRed:250/255.0 green:81/255.0 blue:81/255.0 alpha:1/1.0]
#define AUDIO_QUALITY_DEFAULT_COLOR  [UIColor colorWithWhite:0.5 alpha:0.6]
#define BOTTOM_BTN_ICON_WIDTH  32

@implementation TUILiveRoomPublishParams

@end

@interface TUILiveCreateAnchorRoomView()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong)UIButton *publishBtn;
@property(nonatomic, strong)UIButton *cameraBtn;
@property(nonatomic, strong)UIButton *beautyBtn;
@property(nonatomic, strong)UIButton *closeBtn;
@property(nonatomic, strong)UIView *createTopPanelView;
@property(nonatomic, strong)UIImageView *userAvatar;
@property(nonatomic, strong)UILabel *userNameLabel;
@property(nonatomic, strong)UITextField *roomNameTextField;
@property(nonatomic, strong)UILabel *audioQualityLabel;
@property(nonatomic, strong)UIButton *standardQualityButton;
@property(nonatomic, strong)UIButton *musicQualityButton;

@end

@implementation TUILiveCreateAnchorRoomView{
    BOOL _isViewReady;
    BOOL _cameraSwitch;
    BOOL _isBeautyShow;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self constructSubViews];
        [self bindInteraction];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self constructSubViews];
        [self bindInteraction];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self constructSubViews];
        [self bindInteraction];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // 事件被视频view吃掉了，视频view的事件或者手势暂时没有拿到的办法，只能这样来关闭键盘
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:TUILiveCreateAnchorRoomView.class]) {
        [self.roomNameTextField resignFirstResponder];
    }
    return view;
}

#pragma mark - 视图生命周期
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self->_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self layoutUI];
    self->_isViewReady = YES;
}

// 初始化子视图属性
- (void)constructSubViews {
    _publishBtn = [[UIButton alloc] init];
    [_publishBtn setBackgroundColor:AUDIO_QUALITY_SELECTED_COLOR];
    [[_publishBtn layer] setCornerRadius:8];
    [_publishBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [[_publishBtn titleLabel] setFont:[UIFont systemFontOfSize:22]];
    [_publishBtn.layer setCornerRadius:22];
    
    _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraBtn setImage:[UIImage imageNamed:@"live_start_camera"] forState:UIControlStateNormal];
    
    _beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_beautyBtn setImage:[UIImage imageNamed:@"live_start_beauty"] forState:UIControlStateNormal];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"live_start_close"] forState:UIControlStateNormal];
    
    _createTopPanelView = [[UIView alloc] init];
    [_createTopPanelView setBackgroundColor:[UIColor clearColor]];
    [[_createTopPanelView layer] setCornerRadius:6];
    
    _userAvatar = [[UIImageView alloc] init];
    [[_userAvatar layer] setMasksToBounds:YES];
    [[_userAvatar layer] setCornerRadius:10];
    [_userAvatar sd_setImageWithURL:[NSURL URLWithString:[TUILiveUserProfile getLoginUserInfo].faceURL] placeholderImage:[UIImage imageNamed:@"live_anchor_default_avatar"]];
    _roomNameTextField = [[UITextField alloc] init];
    [_roomNameTextField setBackgroundColor:[UIColor clearColor]];
    [_roomNameTextField setTextColor:[UIColor whiteColor]];
    [_roomNameTextField setReturnKeyType:UIReturnKeyDone];
    [_roomNameTextField setFont:[UIFont boldSystemFontOfSize:22]];
    [_roomNameTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"标题有趣能吸引人气" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.8 alpha:1]}]];
    
    _audioQualityLabel = [[UILabel alloc] init];
    _audioQualityLabel.text = @"直播音质";
    _audioQualityLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    _audioQualityLabel.textColor = [UIColor whiteColor];
    _audioQualityLabel.textAlignment = NSTextAlignmentCenter;
    
    _standardQualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_standardQualityButton setBackgroundColor:AUDIO_QUALITY_DEFAULT_COLOR];
    [_standardQualityButton setTitle:@"标准" forState:UIControlStateNormal];
    _standardQualityButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    _standardQualityButton.layer.cornerRadius = 8;
    
    _musicQualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_musicQualityButton setBackgroundColor:AUDIO_QUALITY_SELECTED_COLOR];
    [_musicQualityButton setTitle:@"音乐" forState:UIControlStateNormal];
    _musicQualityButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    _musicQualityButton.layer.cornerRadius = 8;
    _musicQualityButton.selected = YES;
}

// 初始化视图层级
- (void)constructViewHierarchy {
    [self addSubview:self.publishBtn];
    [self addSubview:self.cameraBtn];
    [self addSubview:self.beautyBtn];
    [self addSubview:self.closeBtn];
    
    [self addSubview:self.createTopPanelView];
    [self.createTopPanelView addSubview:self.userAvatar];
    [self.createTopPanelView addSubview:self.roomNameTextField];
    [self.createTopPanelView addSubview:self.audioQualityLabel];
    [self.createTopPanelView addSubview:self.standardQualityButton];
    [self.createTopPanelView addSubview:self.musicQualityButton];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

// 视图布局
- (void)layoutUI {
    [_beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(12);
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.safeAreaInsets.top).offset(40);
        } else {
            make.top.mas_equalTo(20);
        }
        make.width.height.mas_equalTo(32);
    }];
    [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.safeAreaInsets.top).offset(40);
        } else {
            make.top.mas_equalTo(20);
        }
        make.leading.mas_equalTo(_beautyBtn.mas_trailing).offset(12);
        make.height.width.mas_equalTo(BOTTOM_BTN_ICON_WIDTH);
    }];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.safeAreaInsets.top).offset(40);
        } else {
            make.top.mas_equalTo(20);
        }
        make.trailing.mas_equalTo(-12);
        make.height.width.mas_equalTo(BOTTOM_BTN_ICON_WIDTH);
    }];
    [_publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-(IPHONE_X ? 74 : 40));
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(190);
        make.centerX.mas_equalTo(self);
    }];
    [_createTopPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(0);
        make.trailing.equalTo(self).offset(0);
        make.top.mas_equalTo(110);
        make.bottom.equalTo(self.userAvatar.mas_bottom).offset(10);
    }];
    [_userAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(70);
        make.leading.mas_equalTo(12);
        make.top.mas_equalTo(10);
    }];
    [_roomNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32);
        make.leading.equalTo(_userAvatar.mas_trailing).offset(8);
        make.trailing.mas_equalTo(-12);
        make.top.equalTo(_userAvatar.mas_top).offset(8);
    }];
    [_audioQualityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(56);
        make.height.mas_equalTo(18);
        make.leading.equalTo(_roomNameTextField);
        make.top.mas_equalTo(_roomNameTextField.mas_bottom).offset(6);
    }];
    [_standardQualityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(34);
        make.height.mas_equalTo(18);
        make.leading.equalTo(_audioQualityLabel.mas_trailing).offset(6);
        make.centerY.mas_equalTo(_audioQualityLabel);
    }];
    [_musicQualityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(34);
        make.height.mas_equalTo(18);
        make.leading.equalTo(_standardQualityButton.mas_trailing).offset(8);
        make.centerY.mas_equalTo(_audioQualityLabel);
    }];
}

// 绑定交互
- (void)bindInteraction {
    [_publishBtn addTarget:self action:@selector(startPublish) forControlEvents:UIControlEventTouchUpInside];
    [_cameraBtn addTarget:self action:@selector(clickCamera:) forControlEvents:UIControlEventTouchUpInside];
    [_beautyBtn addTarget:self action:@selector(clickBeauty:) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn addTarget:self action:@selector(taggleCloseVC) forControlEvents:UIControlEventTouchUpInside];
    [_roomNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _roomNameTextField.delegate = self;
    [_standardQualityButton addTarget:self
                               action:@selector(onAudioQualityButtonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    [_musicQualityButton addTarget:self
                            action:@selector(onAudioQualityButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    // 键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    // 键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -键盘监听方法
- (void)keyboardWasShown:(NSNotification *)notification {
    if (self.isHidden) {
        return;
    }
    if (self->_isBeautyShow) {
        [_beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(12);
            if (@available(iOS 11.0, *)) {
                make.top.mas_equalTo(self.safeAreaInsets.top).offset(40);
            } else {
                make.top.mas_equalTo(20);
            }
            make.width.height.mas_equalTo(32);
        }];
        self.publishBtn.hidden = NO;
        self->_isBeautyShow = NO;
        if (self.viewPresenter && [self.viewPresenter respondsToSelector:@selector(showBeautyPanel:)]) {
            [self.viewPresenter showBeautyPanel:NO];
        }
    }
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    
}

#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.roomNameTextField) {
        [self startPublish];
    }
    return YES;
}

#pragma mark - Target-Action
- (void)startPublish {
    
    // 权限检查
    if (![self checkAudioAuthorization]) {
        [self endEditing:YES];
        [THelper makeToast:@"权限验证失败，请打开麦克风权限"];
        return;
    }
    
    if (![self checkVideoAuthorization]) {
        [self endEditing:YES];
        [THelper makeToast:@"权限验证失败，请打开摄像头权限"];
        return;
    }
    
    
    if (self->_isBeautyShow) {
        self->_isBeautyShow = NO;
        [_beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(12);
            if (@available(iOS 11.0, *)) {
                make.top.mas_equalTo(self.safeAreaInsets.top).offset(40);
            } else {
                make.top.mas_equalTo(20);
            }
            make.width.height.mas_equalTo(32);
        }];
        self.publishBtn.hidden = NO;
        if (self.viewPresenter && [self.viewPresenter respondsToSelector:@selector(showBeautyPanel:)]) {
            [self.viewPresenter showBeautyPanel:NO];
        }
    }
    if ([_roomNameTextField isFirstResponder]) {
        [_roomNameTextField resignFirstResponder];
    }
    if (_roomNameTextField.text.length <= 0) {
        [THelper makeToast:@"房间名不能为空"];
        return;
    }
    // 开始组装创建房间参数
    if (self.viewPresenter && [self.viewPresenter respondsToSelector:@selector(startPublish:)]) {
        TUILiveRoomPublishParams *params = [[TUILiveRoomPublishParams alloc] init];
        params.roomName = _roomNameTextField.text;
        params.audioQuality = _musicQualityButton.isSelected ? TUILiveRoomAuidoQualityMusic : TUILiveRoomAuidoQualityStandard;
        [self.viewPresenter startPublish:params];
    }
}

- (void)clickCamera:(UIButton *)button {
    _cameraSwitch = !_cameraSwitch;
    if (self.viewPresenter && [self.viewPresenter respondsToSelector:@selector(switchCamera)]) {
        [self.viewPresenter switchCamera];
    }
}

- (void)clickBeauty:(UIButton *)button {
    [self.beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(0);
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.safeAreaInsets.top).offset(40);
        } else {
            make.top.mas_equalTo(20);
        }
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(32);
    }];
    self.publishBtn.hidden = YES;
    self->_isBeautyShow = YES;
    if (self.viewPresenter && [self.viewPresenter respondsToSelector:@selector(showBeautyPanel:)]) {
        [self.viewPresenter showBeautyPanel:YES];
    }
}

- (void)taggleCloseVC {
    if (self.viewPresenter && [self.viewPresenter respondsToSelector:@selector(closeAction)]) {
        [self.viewPresenter closeAction];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if(textField == _roomNameTextField){
        NSInteger kMaxLength = 10;
        NSString *toBeString = textField.text;
        NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage; //ios7之前使用[UITextInputMode currentInputMode].primaryLanguage
        if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
            UITextRange *selectedRange = [textField markedTextRange];
            //获取高亮部分
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                if (toBeString.length > kMaxLength) {
                    textField.text = [toBeString substringToIndex:kMaxLength];
                }
            }
            else{//有高亮选择的字符串，则暂不对文字进行统计和限制
                
            }
        } else {//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
    }
}

- (void)onAudioQualityButtonClicked:(UIButton *)sender {
    sender.selected = YES;
    if (sender == _standardQualityButton) {
        _musicQualityButton.selected = NO;
        [_musicQualityButton setBackgroundColor:AUDIO_QUALITY_DEFAULT_COLOR];
        [_standardQualityButton setBackgroundColor:AUDIO_QUALITY_SELECTED_COLOR];
    } else {
        _standardQualityButton.selected = NO;
        [_musicQualityButton setBackgroundColor:AUDIO_QUALITY_SELECTED_COLOR];
        [_standardQualityButton setBackgroundColor:AUDIO_QUALITY_DEFAULT_COLOR];
    }
}

#pragma mark - pangesture
- (void)onTap:(UITapGestureRecognizer *)tap {
    [_beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(12);
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.safeAreaInsets.top).offset(40);
        } else {
            make.top.mas_equalTo(20);
        }
        make.width.height.mas_equalTo(32);
    }];
    self.publishBtn.hidden = NO;
    self->_isBeautyShow = NO;
    if (self.viewPresenter && [self.viewPresenter respondsToSelector:@selector(showBeautyPanel:)]) {
        [self.viewPresenter showBeautyPanel:NO];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self->_isBeautyShow) {
        return YES;
    }
    CGPoint point = [touch locationInView:self];
    NSArray *ignoreTapViews = @[
        self.createTopPanelView,
    ];
    for (UIView *view in ignoreTapViews) {
        if (CGRectContainsPoint(view.frame, point)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 权限检查
- (BOOL)checkAudioAuthorization {
    return [self checkAuthorizationStatus:AVMediaTypeAudio];
}

- (BOOL)checkVideoAuthorization {
    return [self checkAuthorizationStatus:AVMediaTypeVideo];
}

- (BOOL)checkAuthorizationStatus:(AVMediaType)mediaType {
    AVAuthorizationStatus authorStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorStatus == AVAuthorizationStatusRestricted ||
        authorStatus == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

@end
