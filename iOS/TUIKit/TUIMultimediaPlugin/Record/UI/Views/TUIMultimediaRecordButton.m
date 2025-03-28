// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaRecordButton.h"
#import <Foundation/Foundation.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/TUIMultimediaCircleProgressView.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"

static const CGFloat RecordAnimeDuration = 0.3;

#pragma mark - TUIMultimediaRecordButton
@interface TUIMultimediaRecordButton () {
    TUIMultimediaCircleProgressView *_progressView;
    UIView *_dotView;
    BOOL _pressed;
    UILongPressGestureRecognizer *_longPressRec;
}
@end

@implementation TUIMultimediaRecordButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _progressView = [[TUIMultimediaCircleProgressView alloc] init];
    _progressView.lineCap = kCALineCapButt;
    _progressView.progressBgColor = TUIMultimediaPluginDynamicColor(@"record_btn_progress_bg_color", @"#FFFFFF");
    _progressView.progressColor = [[TUIMultimediaConfig sharedInstance] getThemeColor];
    _progressView.width = 2;
    [self addSubview:_progressView];

    _dotView = [[UIView alloc] init];
    _dotView.backgroundColor = TUIMultimediaPluginDynamicColor(@"record_btn_dot_color", @"#FFFFFF");
    [self addSubview:_dotView];

    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tapRec.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapRec];
    
    _longPressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    _longPressRec.cancelsTouchesInView = NO;
    _longPressRec.minimumPressDuration = RecordAnimeDuration;
    [self addGestureRecognizer:_longPressRec];
    [self layoutSubviews];
}

- (void)layoutSubviews {
    CGFloat dotSize = _pressed ? _dotSizePressed : _dotSizeNormal;
    
    CGFloat progressSize = _pressed ? _progressSizePressed : _progressSizeNormal;
    if (_isOnlySupportTakePhoto) {
        progressSize = _progressSizeNormal;
    }

    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    CGFloat len = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    _progressView.center = center;
    _progressView.bounds = CGRectMake(0, 0, len, len);
    _progressView.transform = CGAffineTransformMakeScale(progressSize / len, progressSize / len);

    _dotView.center = center;
    _dotView.bounds = CGRectMake(0, 0, dotSize, dotSize);
    _dotView.layer.cornerRadius = dotSize / 2;
}

- (void)animeStartRecord {
    _progressView.width = 4;
    [UIView animateWithDuration:RecordAnimeDuration
                     animations:^{
                       self->_pressed = YES;
                       [self layoutSubviews];
                     }];
}
- (void)animeStopRecord {
    _progressView.width = 2;
    [UIView animateWithDuration:RecordAnimeDuration
                     animations:^{
                       self->_pressed = NO;
                       [self layoutSubviews];
                     }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self animeStartRecord];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self animeStopRecord];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self animeStopRecord];
}
- (void)onTap:(UITapGestureRecognizer *)rec {
    [_delegate onRecordButtonTap:self];
}
- (void)onLongPress:(UILongPressGestureRecognizer *)rec {
    switch (rec.state) {
        case UIGestureRecognizerStateBegan: {
            [_delegate onRecordButtonLongPressBegan:self];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [_delegate onRecordButtonLongPressEnded:self];
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            [self animeStopRecord];
            [_delegate onRecordButtonLongPressCancelled:self];
        }
        default:;
    }
}

- (void)setProgress:(float)progress {
    [_progressView setProgress:progress animated:YES];
}

@end
