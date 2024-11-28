// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaBeautifyController.h"
#import <Masonry/Masonry.h>
#import "TUIMultimediaPlugin/TUIMultimediaBeautifyView.h"

@interface TUIMultimediaBeautifyController () <TUIMultimediaBeautifyViewDelegate> {
    TUIMultimediaBeautifyView *_beautifyView;
}

@end

@implementation TUIMultimediaBeautifyController

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _settings = [[TUIMultimediaBeautifySettings alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _beautifyView = [[TUIMultimediaBeautifyView alloc] init];
    _beautifyView.settings = _settings;
    _beautifyView.delegate = self;

    self.mainView = _beautifyView;
}

- (void)popupControllerDidCanceled {
    [_delegate beautifyControllerOnExit:self];
}

#pragma mark - TUIMultimediaBeautifyViewDelegate protocol
- (void)beautifyView:(TUIMultimediaBeautifyView *)beautifyView onSettingsChange:(TUIMultimediaBeautifySettings *)settings {
    [_delegate beautifyController:self onSettingsChange:settings];
}
@end
