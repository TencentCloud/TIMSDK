// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaBGMEditController.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/RACEXTScope.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaBGMEditView.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaImagePicker.h"
#import "TUIMultimediaPlugin/TUIMultimediaPasterSelectView.h"
#import "TUIMultimediaPlugin/TUIMultimediaPersistence.h"

@interface TUIMultimediaBGMEditController () <TUIMultimediaBGMEditViewDelegate> {
    TUIMultimediaBGMEditView *_editView;
    NSArray<TUIMultimediaBGMGroup *> *_bgmConfig;
    dispatch_block_t _blockBGMNotify;
}

@end

@implementation TUIMultimediaBGMEditController
- (instancetype)init {
    self = [super init];
    _bgmConfig = [TUIMultimediaBGMGroup loadBGMConfigs];
    _bgmEditInfo = [[TUIMultimediaVideoBgmEditInfo alloc] init];
    _bgmEditInfo.originAudio = YES;
    _bgmEditInfo.bgm = nil;

    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _editView = [[TUIMultimediaBGMEditView alloc] init];
    _editView.bgmConfig = _bgmConfig;
    _editView.originAudioEnabled = YES;
    _editView.clipDuration = _clipDuration;
    _editView.delegate = self;
    self.mainView = _editView;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)popupControllerDidCanceled {
    [_delegate onBGMEditControllerExit:self];
}

#pragma mark - Properties
- (void)setClipDuration:(float)videoDuration {
    _clipDuration = videoDuration;
    _editView.clipDuration = videoDuration;
}

#pragma mark - TUIMultimediaBGMEditViewDelegate protocol
- (void)bgmEditViewValueChanged:(TUIMultimediaBGMEditView *)v {
    TUIMultimediaVideoBgmEditInfo *newBgmInfo = [[TUIMultimediaVideoBgmEditInfo alloc] init];
    if (v.bgmEnabled) {
        newBgmInfo.bgm = [v.selectedBgm copy];
    } else {
        newBgmInfo.bgm = nil;
    }
    newBgmInfo.originAudio = v.originAudioEnabled;

    // 延迟防抖, 防止拖动时产生怪音
    if (_blockBGMNotify != nil) {
        dispatch_block_cancel(_blockBGMNotify);
        _blockBGMNotify = nil;
    }
    _blockBGMNotify = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
      self->_bgmEditInfo = newBgmInfo;
      [self->_delegate onBGMEditController:self bgmInfoChanged:self->_bgmEditInfo];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.050 * NSEC_PER_SEC)), dispatch_get_main_queue(), _blockBGMNotify);
}

@end
