// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaSubtitleEditController.h"
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaSubtitleEditView.h"

@interface TUIMultimediaSubtitleEditController () <TUIMultimediaSubtitleEditViewDelegate> {
    TUIMultimediaSubtitleEditView *_editView;
    BOOL _hasCallback;
}

@end

@implementation TUIMultimediaSubtitleEditController
- (instancetype)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    _editView = [[TUIMultimediaSubtitleEditView alloc] initWithFrame:self.view.bounds];
    _editView.subtitleInfo = _subtitleInfo;
    _editView.delegate = self;
    [self.view addSubview:_editView];
}

- (void)viewDidAppear:(BOOL)animated {
    [_editView activate];
    _hasCallback = false;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _editView.frame = self.view.bounds;
}

#pragma mark - TUIMultimediaSubtitleEditViewDelegate protocol
- (void)subtitleEditViewOnOk:(TUIMultimediaSubtitleEditView *)view {
    if (_callback != nil && !_hasCallback) {
        _hasCallback = true;
        _callback(self, YES);
    }
}
- (void)subtitleEditViewOnCancel:(TUIMultimediaSubtitleEditView *)view {
    if (_callback != nil && !_hasCallback) {
        _hasCallback = true;
        _callback(self, NO);
    }
}

#pragma mark - Setters
- (void)setSubtitleInfo:(TUIMultimediaSubtitleInfo *)subtitleInfo {
    _subtitleInfo = [subtitleInfo copy];
    _editView.subtitleInfo = _subtitleInfo;
}

@end
