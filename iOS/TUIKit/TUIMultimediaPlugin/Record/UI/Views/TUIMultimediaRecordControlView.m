// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaRecordControlView.h"

#import <Masonry/Masonry.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaIconLabelButton.h"
#import "TUIMultimediaPlugin/TUIMultimediaRecordButton.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaAuthorizationPrompter.h"

#pragma mark - UI relative constants
const static CGFloat BtnStartRecordSize = 72;
const static CGFloat BtnStartRecordGapBottom = 15;
const static CGFloat BtnStartRecordDotSizeNormal = 56;
const static CGFloat BtnStartRecordDotSizePressed = 20;
const static CGFloat BtnStartRecordProgressSizeNormal = 72;
const static CGFloat BtnStartRecordProgressSizePressed = 80;

const static CGSize BtnExitRecordSize = TUIMultimediaConstCGSize(28, 28);
const static CGFloat BtnExitRecordGapToStartRecord = 55;

const static CGSize BtnCameraSwitch = TUIMultimediaConstCGSize(28, 28);
const static CGFloat BtnCameraSwitchGapToStartRecord = 55;

const static CGFloat FunctionBtnToToTop = 64;
const static CGFloat FunctionBtnToRight = 16;

const static CGSize BtnExtendFunctionIconSize = TUIMultimediaConstCGSize(28, 28);
const static CGFloat BtnExtendFunctionIconTextGap = 4;
const static CGFloat BtnExtendFunctionGap = 24;

const static BOOL ShowDurationLabel = YES;

#pragma mark - TUIMultimediaRecordControlView

@interface TUIMultimediaRecordControlView () <TUIMultimediaRecordButtonDelegate> {
    TUIMultimediaRecordButton *_btnRecord;
    UIButton *_btnExitRecord;
    UIButton *_btnCameraSwitch;
    UIButton *_btnFlash;
    UIButton *_btnBeautify;
    UIButton *_btnAspect;
    UIButton *_lastFuncitonBtn;
    UILabel *_lbDuration;
    UILabel *_lbTip;
    BOOL _isOnlySupportTakePhoto;
}
@end

@implementation TUIMultimediaRecordControlView

- (instancetype)initWithFrame:(CGRect)frame isOnlySupportTakePhoto:(BOOL)isOnlySupportTakePhoto {
    return [self initWithFrame:frame isOnlySupportTakePhoto:isOnlySupportTakePhoto beautifySettings:nil];
}

- (instancetype)initWithFrame:(CGRect)frame isOnlySupportTakePhoto:(BOOL) isOnlySupportTakePhoto beautifySettings:(TUIMultimediaBeautifySettings *)beautifySettings {
    self = [super initWithFrame:frame];
    _isUsingFrontCamera = NO;
    _flashState = NO;
    _aspectRatio = TUIMultimediaRecordAspectRatio9_16;
    _beautifySettings = beautifySettings;
    _isOnlySupportTakePhoto = isOnlySupportTakePhoto;
    if (_beautifySettings == nil) {
        _beautifySettings = [[TUIMultimediaBeautifySettings alloc] init];
    }
    [self initUI];
    return self;
}

- (void)setProgress:(float)progress duration:(float)duration {
    [_btnRecord setProgress:progress];
    int m = floor(duration / 60);
    int s = floor(duration - m * 60);
    _lbDuration.text = [NSString stringWithFormat:@"%02d:%02d", m, s];
}
#pragma mark - UI Init

- (void)initUI {
    _previewView = [[UIView alloc] init];
    [self addSubview:_previewView];
    [_previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self);
      make.width.equalTo(self);
      make.height.equalTo(_previewView.mas_width).multipliedBy(16.0 / 9.0);
    }];

    // 防止 _lbDuration 直接与 _previewView 部分重叠
    UIView *_bottomMaskView = [[UIView alloc] init];
    [self addSubview:_bottomMaskView];
    _bottomMaskView.backgroundColor = UIColor.blackColor;

    [self initControlButtons];
    [self initFunctionButtons];

    _lbDuration = [[UILabel alloc] init];
    [self addSubview:_lbDuration];
    _lbDuration.hidden = YES;
    _lbDuration.text = @"00:00";
    _lbDuration.font = [UIFont monospacedSystemFontOfSize:18 weight:UIFontWeightMedium];
    _lbDuration.textColor = UIColor.whiteColor;
    [_lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
      make.bottom.equalTo(_btnRecord.mas_top).inset(8);
      make.centerX.equalTo(_btnRecord);
    }];

    [_bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.bottom.equalTo(self);
      make.top.equalTo(_lbDuration.mas_top).offset(-8);
    }];

    _lbTip = [[UILabel alloc] init];
    [self addSubview:_lbTip];
    if (_isOnlySupportTakePhoto) {
        _lbTip.text = [TUIMultimediaCommon localizedStringForKey:@"record_photo_tip"];
    } else {
        _lbTip.text = [TUIMultimediaCommon localizedStringForKey:@"record_tip"];
    }
   
    _lbTip.font = [UIFont systemFontOfSize:16];
    _lbTip.textColor = UIColor.whiteColor;
    [_lbTip mas_makeConstraints:^(MASConstraintMaker *make) {
      make.bottom.lessThanOrEqualTo(_previewView).inset(16);
      make.bottom.lessThanOrEqualTo(_bottomMaskView.mas_top).offset(-16);
      make.centerX.equalTo(self);
    }];
}

// 下方的控制按钮
- (void)initControlButtons {
    _btnRecord = [[TUIMultimediaRecordButton alloc] init];
    [self addSubview:_btnRecord];
    _btnRecord.dotSizeNormal = BtnStartRecordDotSizeNormal;
    _btnRecord.dotSizePressed = BtnStartRecordDotSizePressed;
    _btnRecord.progressSizeNormal = BtnStartRecordProgressSizeNormal;
    _btnRecord.progressSizePressed = BtnStartRecordProgressSizePressed;
    _btnRecord.isOnlySupportTakePhoto = _isOnlySupportTakePhoto;
    _btnRecord.delegate = self;
    _btnExitRecord = [self newCustomButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"record_exit_img", @"cross") onTouchUpInside:@selector(onBtnExitClick)];
    _btnCameraSwitch = [self newCustomButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"record_camera_switch_img", @"camera_switch")
                                      onTouchUpInside:@selector(onBtnCameraSwitchClick)];

    [_btnRecord mas_makeConstraints:^(MASConstraintMaker *make) {
      make.width.height.mas_equalTo(BtnStartRecordSize);
      make.centerX.equalTo(self);
      make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).inset(BtnStartRecordGapBottom);
    }];
    [_btnExitRecord mas_makeConstraints:^(MASConstraintMaker *make) {
      make.size.mas_equalTo(BtnExitRecordSize);
      make.centerY.equalTo(_btnRecord);
      make.right.equalTo(_btnRecord.mas_left).inset(BtnExitRecordGapToStartRecord);
    }];
    [_btnCameraSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
      make.size.mas_equalTo(BtnCameraSwitch);
      make.centerY.equalTo(_btnRecord);
      make.left.equalTo(_btnRecord.mas_right).inset(BtnCameraSwitchGapToStartRecord);
    }];
}

// 右上角的功能按钮
- (void)initFunctionButtons {
    [self initTorchView];
    [self initBeautyView];
    [self initAspectView];
}

- (void) initTorchView {
    if (![[TUIMultimediaConfig sharedInstance] isSupportRecordTorch]) {
        return;
    }
    
    _btnFlash = [self newFunctionButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"record_flash_close_img", @"flash_close")
                                           title:[TUIMultimediaCommon localizedStringForKey:@"flash"]
                                 onTouchUpInside:@selector(onBtnFlashClick)];
    
    [_btnFlash mas_makeConstraints:^(MASConstraintMaker *make) {
      make.right.equalTo(self).inset(FunctionBtnToRight);
      make.top.equalTo(self).inset(FunctionBtnToToTop);
    }];
    
    _lastFuncitonBtn = _btnFlash;
}

- (void) initBeautyView {
    if (![[TUIMultimediaConfig sharedInstance] isSupportRecordBeauty]) {
        return;
    }
    
    _btnBeautify = [self newFunctionButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"record_beautify_img", @"beauty_record")
                                              title:[TUIMultimediaCommon localizedStringForKey:@"beautify"]
                                    onTouchUpInside:@selector(onBtnBeautifyClick)];
    
    [_btnBeautify mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_lastFuncitonBtn == nil) {
            make.top.equalTo(self).inset(FunctionBtnToToTop);
            make.right.equalTo(self).inset(FunctionBtnToRight);
        } else {
            make.centerX.equalTo(_lastFuncitonBtn);
            make.top.equalTo(_lastFuncitonBtn.mas_bottom).inset(BtnExtendFunctionGap);
        }
        _lastFuncitonBtn = _btnBeautify;
    }];
}

- (void) initAspectView {
    if (![[TUIMultimediaConfig sharedInstance] isSupportRecordAspect]) {
        return;
    }
    
    _btnAspect = [self newFunctionButtonWithImage:TUIMultimediaPluginBundleThemeImage(@"record_aspect_9_16_img", @"record_aspect_9_16")
                                            title:[TUIMultimediaCommon localizedStringForKey:@"aspect"]
                                  onTouchUpInside:@selector(onBtnAspectClick)];
    
    [_btnAspect mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_lastFuncitonBtn == nil) {
            make.top.equalTo(self).inset(FunctionBtnToToTop);
            make.right.equalTo(self).inset(FunctionBtnToRight);
        } else {
            make.centerX.equalTo(_lastFuncitonBtn);
            make.top.equalTo(_lastFuncitonBtn.mas_bottom).inset(BtnExtendFunctionGap);
        }
        _lastFuncitonBtn = _btnBeautify;
    }];
}

- (UIButton *)newFunctionButtonWithImage:(UIImage *)img title:(NSString *)title onTouchUpInside:(SEL)sel {
    TUIMultimediaIconLabelButton *btn = [TUIMultimediaIconLabelButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:img forState:UIControlStateNormal];
    [btn setAttributedTitle:[[NSAttributedString alloc]
                                initWithString:title
                                    attributes:@{
                                        NSFontAttributeName : [UIFont systemFontOfSize:12],
                                        NSForegroundColorAttributeName : TUIMultimediaPluginDynamicColor(@"record_func_btn_text_color", @"#FFFFFF"),
                                    }]
                   forState:UIControlStateNormal];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.iconSize = BtnExtendFunctionIconSize;
    btn.iconLabelGap = BtnExtendFunctionIconTextGap;
    [self addSubview:btn];
    return btn;
}
- (UIButton *)newCustomButtonWithImage:(nullable UIImage *)image onTouchUpInside:(nullable SEL)sel {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    if (sel != nil) {
        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:btn];
    return btn;
}

#pragma mark - Actions
- (void)onBtnExitClick {
    [_delegate recordControlViewOnExit];
}

- (void)onBtnCameraSwitchClick {
    if (_isUsingFrontCamera) {
        _isUsingFrontCamera = NO;
        _btnFlash.enabled = YES;
    } else {
        _isUsingFrontCamera = YES;
        _btnFlash.enabled = NO;
        [self setFlashState:NO];
    }
    [_delegate recordControlViewOnCameraSwicth:_isUsingFrontCamera];
}

- (void)onBtnFlashClick {
    if (_isUsingFrontCamera) {
        return;
    }
    [self setFlashState:!_flashState];
    [_delegate recordControlViewOnFlashStateChange:_flashState];
}

- (void)onBtnAspectClick {
    if (_aspectRatio == TUIMultimediaRecordAspectRatio9_16) {
        _aspectRatio = TUIMultimediaRecordAspectRatio3_4;
        [_btnAspect setImage:TUIMultimediaPluginBundleThemeImage(@"record_aspect_3_4_img", @"record_aspect_3_4") forState:UIControlStateNormal];
        [_previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.center.equalTo(self);
          make.width.equalTo(self);
          make.height.equalTo(_previewView.mas_width).multipliedBy(4.0 / 3.0);
        }];
    } else {
        _aspectRatio = TUIMultimediaRecordAspectRatio9_16;
        [_btnAspect setImage:TUIMultimediaPluginBundleThemeImage(@"record_aspect_9_16_img", @"record_aspect_9_16") forState:UIControlStateNormal];
        [_previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self);
          make.width.equalTo(self);
          make.height.equalTo(_previewView.mas_width).multipliedBy(16.0 / 9.0);
        }];
    }
    [_delegate recordControlViewOnAspectChange:_aspectRatio];
}

- (void)onBtnBeautifyClick {
    [_delegate recordControlViewOnBeautify];
}

#pragma mark - TUIMultimediaRecordButtonDelegate protocol
- (void)onRecordButtonLongPressBegan:(TUIMultimediaRecordButton *)btn {
    if (![TUIMultimediaAuthorizationPrompter verifyPermissionGranted:self.delegate]) {
        return;
    }
    
    if (!_isOnlySupportTakePhoto) {
        [_delegate recordControlViewOnRecordStart];
        _lbDuration.hidden = !ShowDurationLabel;
    } else {
        _lbDuration.hidden = YES;
    }
    
    _lbTip.hidden = YES;
    _btnExitRecord.hidden = YES;
    _btnCameraSwitch.hidden = YES;
    
    if (_btnFlash != nil) {
        _btnFlash.hidden = YES;
    }
    if (_btnBeautify != nil) {
        _btnBeautify.hidden = YES;
    }
    if (_btnAspect != nil) {
        _btnAspect.hidden = YES;
    }
}

- (void)onRecordButtonLongPressEnded:(TUIMultimediaRecordButton *)btn {
    if (![TUIMultimediaAuthorizationPrompter verifyPermissionGranted:nil]) {
        return;
    }
    
    
    if (!_isOnlySupportTakePhoto) {
        [_delegate recordControlViewOnRecordFinish];
    } else {
        [_delegate recordControlViewPhoto];
    }
    
    _lbDuration.hidden = YES;

    _lbTip.hidden = NO;
    _btnExitRecord.hidden = NO;
    _btnCameraSwitch.hidden = NO;
    if (_btnFlash != nil) {
        _btnFlash.hidden = NO;
    }
    if (_btnBeautify != nil) {
        _btnBeautify.hidden = NO;
    }
    if (_btnAspect != nil) {
        _btnAspect.hidden = NO;
    }
}

- (void)onRecordButtonLongPressCancelled:(TUIMultimediaRecordButton *)btn {
    if (![TUIMultimediaAuthorizationPrompter verifyPermissionGranted:nil]) {
        return;
    }
    
    if (!_isOnlySupportTakePhoto) {
        [_delegate recordControlViewOnRecordFinish];
    }
    
    _lbDuration.hidden = YES;

    _lbTip.hidden = NO;
    _btnExitRecord.hidden = NO;
    _btnCameraSwitch.hidden = NO;
    if (_btnFlash != nil) {
        _btnFlash.hidden = NO;
    }
    if (_btnBeautify != nil) {
        _btnBeautify.hidden = NO;
    }
    if (_btnAspect != nil) {
        _btnAspect.hidden = NO;
    }
}

- (void)onRecordButtonTap:(TUIMultimediaRecordButton *)btn {
    [_delegate recordControlViewPhoto];
}

#pragma mark - Properties
- (void)setFlashState:(BOOL)flashState {
    _flashState = flashState;
    if (_flashState) {
        [_btnFlash setImage:TUIMultimediaPluginBundleThemeImage(@"record_flash_open_img", @"flash_open") forState:UIControlStateNormal];
    } else {
        [_btnFlash setImage:TUIMultimediaPluginBundleThemeImage(@"record_flash_close_img", @"flash_close") forState:UIControlStateNormal];
    }
}

- (BOOL)recordTipHidden {
    return _lbTip.hidden;
}

- (void)setRecordTipHidden:(BOOL)recordTipHidden {
    _lbTip.hidden = recordTipHidden;
}
@end
