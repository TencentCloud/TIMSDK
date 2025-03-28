// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaFakeAudioWaveView.h"
#import <Masonry/Masonry.h>
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"

@interface TUIMultimediaFakeAudioWaveView () {
    dispatch_source_t _timer;
}

@end

@implementation TUIMultimediaFakeAudioWaveView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = UIColor.clearColor;
        _color = UIColor.grayColor;
        _lineWidth = 1.5;
        _lineSpacing = 0.5;
        _animeInterval = 0.2;
        _enabled = NO;

        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, _animeInterval * NSEC_PER_SEC, _animeInterval * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
          [self setNeedsDisplay];
        });
        dispatch_activate(_timer);
        dispatch_suspend(_timer);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [_color set];
    CGFloat x = 0;
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    while (x + _lineWidth < selfWidth) {
        CGFloat h = (CGFloat)arc4random() / UINT32_MAX * selfHeight;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(x, selfHeight - h, _lineWidth, selfHeight)];
        [path fill];
        x += _lineWidth + _lineSpacing;
    }
}

#pragma mark - Properties
- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled && !enabled) {
        dispatch_suspend(_timer);
    } else if (!_enabled && enabled) {
        dispatch_resume(_timer);
    }
    _enabled = enabled;
}

- (void)setAnimeInterval:(CGFloat)animeInterval {
    _animeInterval = animeInterval;
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, _animeInterval * NSEC_PER_SEC, _animeInterval * NSEC_PER_SEC);
}

@end
