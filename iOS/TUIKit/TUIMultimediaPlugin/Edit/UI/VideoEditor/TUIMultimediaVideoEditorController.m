// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaVideoEditorController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/RACEXTScope.h>
#import <TUICore/TUIDefine.h>
#import <TXLiteAVSDK_Professional/TXVideoEditer.h>x
#import <TXLiteAVSDK_Professional/TXVideoEditerTypeDef.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaBGMEditController.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommonEditorControlView.h"
#import "TUIMultimediaPlugin/TUIMultimediaImagePicker.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterSelectController.h"
#import "TUIMultimediaPlugin/TUIMultimediaPersistence.h"
#import "TUIMultimediaPlugin/TUIMultimediaSubtitleEditController.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaConstant.h"

@interface TUIMultimediaVideoEditorController () <TXVideoPreviewListener,
TXVideoGenerateListener,
TUIMultimediaPasterSelectControllerDelegate,
TUIMultimediaCommonEditorControlViewDelegate,
TUIMultimediaBGMEditControllerDelegate> {
    TUIMultimediaPasterSelectController *_pasterSelectController;
    TUIMultimediaCommonEditorControlView *_ctrlView;
    TXVideoEditer *_editor;
    NSString *_sourceVideoPath;
    TXVideoInfo *_videoInfo;
    TUIMultimediaSubtitleEditController *_subtitleEditController;
    TUIMultimediaBGMEditController *_musicController;
    TUIMultimediaEncodeConfig *_encodeConfig;
    BOOL _originNavgationBarHidden;
    float _lastGenerateProgress;
    BOOL _hasAudioEdited;
}

@end

@implementation TUIMultimediaVideoEditorController

@dynamic sourceVideoPath;

- (instancetype)init {
    self = [super init];
    _encodeConfig = [[TUIMultimediaEncodeConfig alloc] initWithVideoQuality:[[TUIMultimediaConfig sharedInstance] getVideoQuality]];
    _lastGenerateProgress = 0;
    _sourceType = SOURCE_TYPE_RECORD;
    _hasAudioEdited = NO;
    return self;
}

- (void)viewDidLoad {
    [self initUI];
    _pasterSelectController = [[TUIMultimediaPasterSelectController alloc] init];
    _pasterSelectController.delegate = self;
    _pasterSelectController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    _subtitleEditController = [[TUIMultimediaSubtitleEditController alloc] init];
    _subtitleEditController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    _musicController = [[TUIMultimediaBGMEditController alloc] init];
    _musicController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    _musicController.delegate = self;
    _musicController.clipDuration = _videoInfo.duration;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.navigationController != nil) {
        _originNavgationBarHidden = self.navigationController.navigationBarHidden;
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.navigationController != nil) {
        self.navigationController.navigationBarHidden = _originNavgationBarHidden;
    }
}

- (NSString *)sourceVideoPath {
    return _sourceVideoPath;
}

- (void)setSourceVideoPath:(NSString *)sourceVideoPath {
    _sourceVideoPath = sourceVideoPath;
    NSString *currentSourceVideoPath = sourceVideoPath;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self->_sourceVideoPath != currentSourceVideoPath) return;
        self->_videoInfo = [TXVideoInfoReader getVideoInfo:self->_sourceVideoPath];
        NSLog(@"videoInfo angle = %d, width = %d, height = %d, duration = %f",
              self->_videoInfo.angle, self->_videoInfo.width, self->_videoInfo.height, self->_videoInfo.duration);
        if (self->_videoInfo.angle == 90 || self->_videoInfo.angle == 270) {
            int temp = self->_videoInfo.width;
            self->_videoInfo.width = self->_videoInfo.height;
            self->_videoInfo.height = temp;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tryReloadVideoAsset];
            self->_musicController.clipDuration = self->_videoInfo.duration;
        });
    });
}

- (void)setSourceType:(int)sourceType {
    NSLog(@"setSourceType sourceType = %d",sourceType);
    _sourceType = sourceType;
    if (_ctrlView != nil) {
        _ctrlView.sourceType = sourceType;
    }
}

- (void)tryReloadVideoAsset {
    if (_editor == nil || _sourceVideoPath == nil) return;
    int code = [_editor setVideoPath:_sourceVideoPath];
    [_editor startPlayFromTime:0 toTime:_videoInfo.duration];
    if (code != 0) {
        NSString *title = [TUIMultimediaCommon localizedStringForKey:@"modify_load_assert_failed"];
        [self showAlertWithTitle:title message:@"" action:@"OK"];
    }
    _ctrlView.previewSize = CGSizeMake(_videoInfo.width, _videoInfo.height);
}

#pragma mark - UI Init

- (void)initUI {
    _ctrlView = [[TUIMultimediaCommonEditorControlView alloc] initWithConfig:TUIMultimediaCommonEditorConfig.configForVideoEditor];
    [self.view addSubview:_ctrlView];
    _ctrlView.backgroundColor = UIColor.blackColor;
    _ctrlView.previewSize = CGSizeMake(_videoInfo.width, _videoInfo.height);
    _ctrlView.sourceType = _sourceType;
    _ctrlView.delegate = self;
    
    TXPreviewParam *param = [[TXPreviewParam alloc] init];
    param.videoView = _ctrlView.previewView;
    param.renderMode = PREVIEW_RENDER_MODE_FILL_EDGE;
    _editor = [[TXVideoEditer alloc] initWithPreview:param];
    [self tryReloadVideoAsset];
    _editor.previewDelegate = self;
    _editor.generateDelegate = self;
    
    [_ctrlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message action:(NSString *)action {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:action style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TXVideoPreviewListener protocol
- (void)onPreviewProgress:(CGFloat)time {
}
- (void)onPreviewFinished {
    [_editor startPlayFromTime:0 toTime:_videoInfo.duration];
}

#pragma mark - TXVideoGenerateListener protocol
- (void)onGenerateProgress:(float)progress {
    NSLog(@"TUIMultimediaVideoEditorController onGenerateProgress progress  = %f",progress);
    if (progress - _lastGenerateProgress > 0.01f || progress == 1.0f) {
        _ctrlView.progressBarProgress = progress;
        _lastGenerateProgress = progress;
    }
}

- (void)onGenerateComplete:(TXGenerateResult *)result {
    NSLog(@"TUIMultimediaVideoEditorController onGenerateComplete retCode = %ld",(long)result.retCode);
    int resultCode = (result.retCode != 0) ? VIDEO_EDIT_RESULT_CODE_GENERATE_FAIL : VIDEO_EDIT_RESULT_CODE_GENERATE_SUCCESS;
    _completeCallback(_resultVideoPath, resultCode);
}

#pragma mark - TUIMultimediaCommonEditorControlViewDelegate protocol
- (void)onCommonEditorControlViewComplete:(TUIMultimediaCommonEditorControlView *)view stickers:(NSArray<TUIMultimediaSticker *> *)stickers {
    if (stickers.count == 0 && !_hasAudioEdited && _sourceType == SOURCE_TYPE_ALBUM) {
        NSLog(@"Return directly without encoding the video");
        _resultVideoPath = _sourceVideoPath;
        _completeCallback(_resultVideoPath, VIDEO_EDIT_RESULT_CODE_NO_EDIT);
        return;
    }
    
    NSArray<TXPaster *> *pasterList = [stickers tui_multimedia_map:^TXPaster *(TUIMultimediaSticker *s) {
        TXPaster *p = [[TXPaster alloc] init];
        p.pasterImage = s.image;
        p.frame = s.frame;
        p.startTime = 0.0;
        p.endTime = self->_videoInfo.duration;
        return p;
    }];
    [_editor setPasterList:pasterList];
    
    _ctrlView.isGenerating = YES;
    [self.view bringSubviewToFront:_ctrlView];
    if (_resultVideoPath == nil || _resultVideoPath.length == 0) {
        _resultVideoPath = [self getOutFilePath];
    }
    [_editor setVideoBitrate:_encodeConfig.bitrate];
    [_editor generateVideo:[_encodeConfig getVideoEditCompressed] videoOutputPath:_resultVideoPath];
}

- (void)onCommonEditorControlViewCancel:(TUIMultimediaCommonEditorControlView *)view {
    [_editor stopPlay];
    _completeCallback(nil, VIDEO_EDIT_RESULT_CODE_CANCEL);
}

- (void)onCommonEditorControlViewNeedAddPaster:(TUIMultimediaCommonEditorControlView *)view {
    NSLog(@"onCommonEditorControlViewNeedAddPaster");
    _ctrlView.modifyButtonsHidden = YES;
    [self presentViewController:_pasterSelectController animated:NO completion:nil];
}

- (void)onCommonEditorControlViewNeedModifySubtitle:(TUIMultimediaSubtitleInfo *)info callback:(void (^)(TUIMultimediaSubtitleInfo *info, BOOL isOk))callback {
    _subtitleEditController.subtitleInfo = info;
    _subtitleEditController.callback = ^(TUIMultimediaSubtitleEditController *c, BOOL isOk) {
        [c.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        if (callback != nil) {
            callback(c.subtitleInfo, isOk);
        }
    };
    [self presentViewController:_subtitleEditController animated:NO completion:nil];
}
- (void)onCommonEditorControlViewNeedEditMusic:(TUIMultimediaCommonEditorControlView *)view {
    _ctrlView.modifyButtonsHidden = YES;
    [self presentViewController:_musicController animated:NO completion:nil];
}
- (void)onCommonEditorControlViewCancelGenerate:(TUIMultimediaCommonEditorControlView *)view {
    [_editor cancelGenerate];
    TXPreviewParam *param = [[TXPreviewParam alloc] init];
    param.videoView = _ctrlView.previewView;
    param.renderMode = PREVIEW_RENDER_MODE_FILL_EDGE;
    _editor = [[TXVideoEditer alloc] initWithPreview:param];
    [self tryReloadVideoAsset];
    _editor.previewDelegate = self;
    _editor.generateDelegate = self;
}

-(NSString*) getOutFilePath{
    NSDate* currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString* currentDateString = [dateFormatter stringFromDate:currentDate];
    NSString* outFileName = [NSString stringWithFormat:@"%@-%u-temp.mp4", currentDateString, arc4random()];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:outFileName];
}

#pragma mark - TUIMultimediaPasterSelectControllerDelegate protocol
- (void)pasterSelectController:(TUIMultimediaPasterSelectController *)c onPasterSelected:(UIImage *)image {
    [_ctrlView addPaster:image];
    _ctrlView.modifyButtonsHidden = NO;
    [c.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
- (void)onPasterSelectControllerExit:(TUIMultimediaPasterSelectController *)c {
    _ctrlView.modifyButtonsHidden = NO;
    [c.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - TUIMultimediaMusicControllerDelegate protocol
- (void)onBGMEditController:(TUIMultimediaBGMEditController *)c bgmInfoChanged:(TUIMultimediaVideoBgmEditInfo *)bgmInfo {
    [_editor setBGMLoop:YES];
    @weakify(self);
    [_editor setBGMAsset:bgmInfo.bgm.asset
                  result:^(int result) {
        @strongify(self);
        if (result != 0) {
            NSString *title = [TUIMultimediaCommon localizedStringForKey:@"modify_load_assert_failed"];
            [self showAlertWithTitle:title message:@"" action:@"OK"];
        }
    }];
    [_editor setBGMAtVideoTime:0];
    [_editor setBGMStartTime:bgmInfo.bgm.startTime endTime:bgmInfo.bgm.endTime];
    [_editor setBGMVolume:1];
    if (bgmInfo.originAudio) {
        [_editor setVideoVolume:1];
    } else {
        [_editor setVideoVolume:0];
    }
    _ctrlView.musicEdited = bgmInfo.bgm != nil;
    
    _hasAudioEdited = (!bgmInfo.originAudio) || (bgmInfo.bgm != nil);
}
- (void)onBGMEditControllerExit:(nonnull TUIMultimediaBGMEditController *)c {
    _ctrlView.modifyButtonsHidden = NO;
    [c.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
