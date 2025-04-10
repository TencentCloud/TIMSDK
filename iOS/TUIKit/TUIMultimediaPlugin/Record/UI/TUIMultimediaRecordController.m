// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaRecordController.h"

#import <Masonry/Masonry.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TXLiteAVSDK_Professional/TXUGCRecord.h>

#import "TUIMultimediaPlugin/TUIMultimediaBeautifyController.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaRecordControlView.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaAuthorizationPrompter.h"

@interface TUIMultimediaRecordController () <TUIMultimediaRecordControlViewDelegate, TXUGCRecordListener, TUIMultimediaBeautifyControllerDelegate> {
    TUIMultimediaBeautifyController *_beautifyController;
    TUIMultimediaRecordControlView *_ctrlView;
    BOOL _originNavgationBarHidden;
    float recordDuration;
    CGFloat _zoom;
    TUIMultimediaEncodeConfig* _encodeConfig;
    BOOL _recordForEdit;
    float _minDurationSeconds;
    float _maxDurationSeconds;
}

@end

@implementation TUIMultimediaRecordController

- (instancetype)init {
    self = [super init];
    _minDurationSeconds = [[TUIMultimediaConfig sharedInstance] getMinRecordDurationMs] / 1000.0f;
    _maxDurationSeconds = [[TUIMultimediaConfig sharedInstance] getMaxRecordDurationMs] / 1000.0f;
    _encodeConfig = [[TUIMultimediaEncodeConfig alloc] initWithVideoQuality:[[TUIMultimediaConfig sharedInstance] getVideoQuality]];
    _zoom = 1.0;
    _recordForEdit = YES;
    _isOnlySupportTakePhoto = NO;
    return self;
}

- (void)viewDidLoad {
    [self initUI];
}

#pragma mark - UI Init

- (void)initUI {
    self.view.backgroundColor = UIColor.blackColor;

    _ctrlView = [[TUIMultimediaRecordControlView alloc] initWithFrame:self.view.bounds isOnlySupportTakePhoto:_isOnlySupportTakePhoto];
    _ctrlView.delegate = self;
    [self.view addSubview:_ctrlView];

    _beautifyController = [[TUIMultimediaBeautifyController alloc] init];
    _beautifyController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    _beautifyController.delegate = self;

    [self startPreview];

    UIPinchGestureRecognizer *pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    [_ctrlView addGestureRecognizer:pinchRec];
}

- (void)startPreview {
    TXUGCCustomConfig *param = [[TXUGCCustomConfig alloc] init];
    param.minDuration = _minDurationSeconds;
    param.maxDuration = _maxDurationSeconds;
    param.videoResolution = [_encodeConfig getVideoRecordResolution];
    param.videoBitratePIN = _encodeConfig.bitrate;
    param.videoFPS = _encodeConfig.fps;
    if (_recordForEdit) {
        param.videoBitratePIN = TUIMultimediaEditBitrate;
    }
    [self recordControlViewOnAspectChange:_ctrlView.aspectRatio];
    [TXUGCRecord.shareInstance startCameraCustom:param preview:_ctrlView.previewView];
    [TXUGCRecord.shareInstance switchCamera:_ctrlView.isUsingFrontCamera];
    [self beautifyController:_beautifyController onSettingsChange:_beautifyController.settings];
}

- (void)viewWillAppear:(BOOL)animated {
    [self startPreview];
    if (self.navigationController != nil) {
        _originNavgationBarHidden = self.navigationController.navigationBarHidden;
        self.navigationController.navigationBarHidden = YES;
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [TXUGCRecord.shareInstance stopCameraPreview];
    if (self.navigationController != nil) {
        self.navigationController.navigationBarHidden = _originNavgationBarHidden;
    }
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)appDidBecomeActive {
    [self startPreview];
}
- (void)appWillResignActive {
    [TXUGCRecord.shareInstance stopCameraPreview];
}

- (void)presentSimpleAlertWithTitle:(NSString *)title message:(NSString *)message onOk:(void (^)(void))onOk {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                            if (onOk != nil) {
                                                                onOk();
                                                            }
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)takePhoto {
    int code = [TXUGCRecord.shareInstance snapshot:^(UIImage *image) {
      if (self->_resultCallback != nil) {
          self->_resultCallback(nil, image);
      }
    }];
    if (code != 0) {
        [self presentSimpleAlertWithTitle:[TUIMultimediaCommon localizedStringForKey:@"photo_failed"] message:@"" onOk:nil];
    }
}

#pragma mark - UIPinchGestureRecognizer
- (void)onPinch:(UIPinchGestureRecognizer *)rec {
    _zoom = MIN(MAX(_zoom * rec.scale, 1.0), 5.0);
    rec.scale = 1;
    [TXUGCRecord.shareInstance setZoom:_zoom];
}

#pragma mark - TUIMultimediaRecordControlViewDelegate protocol
- (void)recordControlViewOnAspectChange:(TUIMultimediaRecordAspectRatio)aspect {
    switch (_ctrlView.aspectRatio) {
        case TUIMultimediaRecordAspectRatio3_4: {
            [TXUGCRecord.shareInstance setAspectRatio:VIDEO_ASPECT_RATIO_3_4];
            break;
        }
        case TUIMultimediaRecordAspectRatio9_16: {
            [TXUGCRecord.shareInstance setAspectRatio:VIDEO_ASPECT_RATIO_9_16];
            break;
        }
        default:;
    }
}

- (void)recordControlViewOnCameraSwicth:(BOOL)isUsingFrontCamera {
    [TXUGCRecord.shareInstance switchCamera:isUsingFrontCamera];
}

- (void)recordControlViewOnExit {
    [TXUGCRecord.shareInstance stopCameraPreview];
    if (_resultCallback != nil) {
        _resultCallback(nil, nil);
    }
}

- (void)recordControlViewOnFlashStateChange:(BOOL)flashState {
    [TXUGCRecord.shareInstance toggleTorch:flashState];
}

- (void)recordControlViewOnRecordStart {
    TXUGCRecord.shareInstance.recordDelegate = self;
    int res = [TXUGCRecord.shareInstance startRecord];
    if (res == 0) {
        return;
    }
    NSString *title = [TUIMultimediaCommon localizedStringForKey:@"record_failed"];
    NSString *msg;
    switch (res) {
        case -3:
            msg = [TUIMultimediaCommon localizedStringForKey:@"record_failed_reason_camera"];
            break;
        case -4:
            msg = [TUIMultimediaCommon localizedStringForKey:@"record_failed_reason_microphone"];
            break;
        case -5:
            msg = [TUIMultimediaCommon localizedStringForKey:@"record_failed_reason_license"];
            break;
        default:
            msg = [TUIMultimediaCommon localizedStringForKey:@"record_failed_reason_unknown"];
            break;
    }
    [self presentSimpleAlertWithTitle:title message:msg onOk:nil];
}

- (void)recordControlViewOnRecordFinish {
    [TXUGCRecord.shareInstance stopRecord];
    [TXUGCRecord.shareInstance stopCameraPreview];
}

- (void)recordControlViewPhoto {
    if (![TUIMultimediaAuthorizationPrompter verifyPermissionGranted:self]) {
        return;
    }
    [self takePhoto];
}

- (void)recordControlViewOnBeautify {
    _ctrlView.recordTipHidden = YES;
    [self.navigationController presentViewController:_beautifyController animated:NO completion:nil];
}

#pragma mark - TXUGCRecordListener protocol
- (void)onRecordProgress:(NSInteger)milliSecond {
    recordDuration = milliSecond / 1000.0;
    [_ctrlView setProgress:milliSecond / 1000.0 / _maxDurationSeconds duration:recordDuration];
    if (milliSecond / 1000.0 >= _maxDurationSeconds) {
        [TXUGCRecord.shareInstance stopRecord];
        [TXUGCRecord.shareInstance stopCameraPreview];
    }
}

- (void)onRecordComplete:(TXUGCRecordResult *)result {
    [TXUGCRecord.shareInstance.partsManager deleteAllParts];
    if (result.retCode == UGC_RECORD_RESULT_FAILED) {
        NSString *title = [TUIMultimediaCommon localizedStringForKey:@"record_failed"];
        [self presentSimpleAlertWithTitle:title
                                  message:@""
                                     onOk:^{
                                       [self startPreview];
                                     }];
        return;
    }
    // 未达到最小录制时长
    if (recordDuration < _minDurationSeconds) {
        [self takePhoto];
        return;
    }
    if (self->_resultCallback != nil) {
        self->_resultCallback(result.videoPath, nil);
    }
}

#pragma mark - TUIMultimediaBeautifyControllerDelegate protocol
- (void)beautifyControllerOnExit:(TUIMultimediaBeautifyController *)controller {
    [self dismissViewControllerAnimated:NO completion:nil];
    _ctrlView.recordTipHidden = NO;
}

- (void)beautifyController:(TUIMultimediaBeautifyController *)controller onSettingsChange:(TUIMultimediaBeautifySettings *)settings {
    TXBeautyManager *manager = [TXUGCRecord.shareInstance getBeautyManager];
    [manager setBeautyStyle:TXBeautyStyleSmooth];
    __auto_type convertStrength = ^(int strength, float min, float max) {
      float ratio = ((float)strength - TUIMultimediaEffectSliderMin) / (TUIMultimediaEffectSliderMax - TUIMultimediaEffectSliderMin);
      return ratio * (max - min) + min;
    };
    __auto_type convertBeautifyStrength = ^(int strength) {
      return convertStrength(strength, TUIMultimediaBeautifyStrengthMin, TUIMultimediaBeautifyStrengthMax);
    };
    __auto_type convertFilterStrength = ^(int strength) {
      return convertStrength(strength, TUIMultimediaFilterStrengthMin, TUIMultimediaFilterStrengthMax);
    };
    if (settings.activeBeautifyTag == TUIMultimediaEffectItemTagNone) {
        [manager setBeautyLevel:0];
    }
    for (TUIMultimediaEffectItem *item in settings.beautifyItems) {
        float strength = convertBeautifyStrength(item.strength);
        if (settings.activeBeautifyTag == item.tag) {
            switch (item.tag) {
                case TUIMultimediaEffectItemTagSmooth:
                    [manager setBeautyStyle:TXBeautyStyleSmooth];
                    break;
                case TUIMultimediaEffectItemTagNatural:
                    [manager setBeautyStyle:TXBeautyStyleNature];
                    break;
                case TUIMultimediaEffectItemTagPitu:
                    [manager setBeautyStyle:TXBeautyStylePitu];
                    break;
            }
            [manager setBeautyLevel:strength];
        }
        switch (item.tag) {
            case TUIMultimediaEffectItemTagWhiteness:
                [manager setWhitenessLevel:strength];
                break;
            case TUIMultimediaEffectItemTagRuddy:
                [manager setRuddyLevel:strength];
                break;
        }
    }
    NSInteger idx = settings.activeFilterIndex;
    if (idx >= 0 && idx < settings.filterItems.count) {
        float strength = convertFilterStrength(settings.filterItems[idx].strength);
        [manager setFilter:settings.filterItems[idx].filterMapImage];
        [manager setFilterStrength:strength];
    } else {
        [manager setFilter:nil];
    }
}

@end
