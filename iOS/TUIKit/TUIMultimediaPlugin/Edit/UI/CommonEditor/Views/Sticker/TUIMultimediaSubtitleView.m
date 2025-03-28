// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaSubtitleView.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"

#define MIN_SUBTITLE_PASTER_WIDTH 100
#define MAX_SUBTITLE_PASTER_HEIGH 400

@interface TUIMultimediaSubtitleView () <TUIMultimediaStickerViewDelegate> {
    id<TUIMultimediaStickerViewDelegate> _outerDelegate;
    UILabel *_label;
    BOOL _isSizeToFitingSubtitleInfo;
}

@end

@implementation TUIMultimediaSubtitleView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initUI];
    }
    _isSizeToFitingSubtitleInfo = NO;
    return self;
}

- (void)initUI {
    [super setDelegate:self];
    _label = [[UILabel alloc] init];
    _label.font = [UIFont systemFontOfSize:20];
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByClipping;
    _label.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Getters & Setters
- (void)setSubtitleInfo:(TUIMultimediaSubtitleInfo *)subtitleInfo {
    NSLog(@"TUIMultimediaSubtitleView setSubtitleInfo text = %@",subtitleInfo.wrappedText);
    _subtitleInfo = subtitleInfo;
    
    self.content = nil;
    _label.text = subtitleInfo.wrappedText;
    _label.textColor = subtitleInfo.color;
    [self labeSizeToFit];
    self.content = _label;
}

-(void)labeSizeToFit {
    _isSizeToFitingSubtitleInfo = YES;
    if (_subtitleInfo.wrappedText.length > 0) {
        _label.text = [NSString stringWithFormat:@"%C", [_subtitleInfo.wrappedText characterAtIndex:0]];
    } else {
        NSLog(@"_subtitleInfo.wrappedText is empty or nil.");
        _label.text = @""; 
    }
    CGSize size = [_label sizeThatFits:CGSizeMake(MAXFLOAT, MAX_SUBTITLE_PASTER_HEIGH)];
    CGFloat singleLineTextHeight = size.height;
    
    _label.text = _subtitleInfo.wrappedText;
    size = [_label sizeThatFits:CGSizeMake(MAXFLOAT, MAX_SUBTITLE_PASTER_HEIGH)];
    CGFloat adjustedWidth = size.width;
    if (size.height > singleLineTextHeight * 1.5) {
        // multi line text
        adjustedWidth = MAX(size.width, MIN_SUBTITLE_PASTER_WIDTH);
    }
    CGFloat adjustedHeight = MIN(size.height, MAX_SUBTITLE_PASTER_HEIGH);
    _label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y, adjustedWidth, adjustedHeight);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_isSizeToFitingSubtitleInfo = NO;
    });
}

- (id<TUIMultimediaStickerViewDelegate>)delegate {
    return _outerDelegate;
}

- (void)setDelegate:(id<TUIMultimediaStickerViewDelegate>)delegate {
    _outerDelegate = delegate;
}

#pragma mark - TUIMultimediaFloatingResizableDelegate protocol
- (void)onStickerViewShouldDelete:(TUIMultimediaStickerView *)v {
    [_outerDelegate onStickerViewShouldDelete:self];
}

- (void)onStickerViewShouldEdit:(TUIMultimediaStickerView *)v {
    [_outerDelegate onStickerViewShouldEdit:self];
}

- (void)onStickerViewSelected:(TUIMultimediaStickerView *)v {
    [_outerDelegate onStickerViewSelected:self];
}

- (void)onStickerViewSizeChanged:(TUIMultimediaStickerView *)v {
    [_outerDelegate onStickerViewSizeChanged:self];
    if (_isSizeToFitingSubtitleInfo == NO) {
        [self adjustFontSize];
    }
}

- (void)adjustFontSize {
    NSString *text = _label.text;
    CGSize labelSize = _label.bounds.size;
    UIFont *font = _label.font;
    CGFloat minFontSize = 0;
    CGFloat maxFontSize = 1000;
    const CGFloat eps = 0.1;
    // 理论上需要14次二分
    while (maxFontSize - minFontSize > eps) {
        CGFloat mid = (maxFontSize + minFontSize) / 2;
        font = [font fontWithSize:mid];
        CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];
        if (size.width < labelSize.width && size.height < labelSize.height) {
            minFontSize = mid;
        } else {
            maxFontSize = mid;
        }
    }
    _label.font = [_label.font fontWithSize:minFontSize];
}
@end
