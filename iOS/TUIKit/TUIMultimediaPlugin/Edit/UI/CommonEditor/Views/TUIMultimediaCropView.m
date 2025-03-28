// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaCropView.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>

#define TOUCH_MAX_DIS 40
#define CORNER_LINE_WIDTH 4.0
#define CORNER_LENGTH 25.0
#define CROP_RECT_BORDER_LINE_WIDTH  2.0
#define CROP_RECT_GRID_LINE_WIDTH 0.8

@interface TUIMultimediaCropView()<UIGestureRecognizerDelegate, UIGestureRecognizerDelegate>{
    UIColor * _borderColor;
    UIColor* _backgroundColor;
    
    NSDate * _lastShowTransparentBackgroundTime;
    NSDate * _lastShowGridTime;
    BOOL _isShowTransparentBackground;
    BOOL _isShowGird;
    
    CGRect _limitRect;
    CGRect _cropRect;
    
    CGFloat _isMoveLeft;
    CGFloat _isMoveRight;
    CGFloat _isMoveTop;
    CGFloat _isMoveBottom;
}
@end

@implementation TUIMultimediaCropView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _borderColor = [UIColor whiteColor];
        _backgroundColor = [UIColor blackColor];
        _isShowTransparentBackground = NO;
        _isShowGird = NO;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.delegate = self;
        [self addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesture];
        
        UIPinchGestureRecognizer *pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
        [self addGestureRecognizer:pinchRec];
        pinchRec.delegate = self;
    }
    return self;
}

-(CGRect)getCropRect {
    return _cropRect;
}

-(void)reset {
    [self adjustCropRect:_preViewFrame];
    [self setNeedsDisplay];
}

-(void)rotation90 {
    int centerX = CGRectGetMidX(_cropRect);
    int centerY = CGRectGetMidY(_cropRect);
    int width = _cropRect.size.width;
    int height = _cropRect.size.height;

    _cropRect.origin.y = centerY - width / 2.0f;
    _cropRect.size.height = width;
    
    _cropRect.origin.x = centerX - height / 2.0f;
    _cropRect.size.width = height;
    
    [self adjustCropRect:_cropRect];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _limitRect = CGRectMake(10, 50, self.frame.size.width - 20, self.frame.size.height - 160);
    _cropRect = _limitRect;
}

- (void)onTap:(UITapGestureRecognizer *)gesture {
    [self showTransparentBackground];
    [self showGrid];
}

- (void)onPinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    [self showTransparentBackground];
    [self showGrid];
}

- (void)onPan:(UIPanGestureRecognizer *)gesture {
    _backgroundColor = [UIColor clearColor];
    [self showTransparentBackground];
    [self showGrid];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint p = [gesture locationInView:self];
            _isMoveLeft = fabs(p.x - _cropRect.origin.x) < TOUCH_MAX_DIS;
            _isMoveRight = fabs(p.x - CGRectGetMaxX(_cropRect)) < TOUCH_MAX_DIS;
            _isMoveTop = fabs(p.y - _cropRect.origin.y) < TOUCH_MAX_DIS;
            _isMoveBottom = fabs(p.y -  CGRectGetMaxY(_cropRect)) < TOUCH_MAX_DIS;
            if (_isMoveTop || _isMoveLeft || _isMoveRight || _isMoveBottom) {
                [_delegate onStartCrop];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint p = [gesture locationInView:self];
            if (_isMoveLeft && p.x > _limitRect.origin.x && p.x < CGRectGetMaxX(_cropRect)) {
                _cropRect.size.width += (_cropRect.origin.x - p.x);
                _cropRect.origin.x = p.x;
            }

            if (_isMoveRight && p.x > _cropRect.origin.x && p.x < CGRectGetMaxX(_limitRect)) {
                _cropRect.size.width = p.x - _cropRect.origin.x;
            }

            if (_isMoveTop && p.y > _limitRect.origin.y && p.y < CGRectGetMaxY(_cropRect)) {
                _cropRect.size.height += (_cropRect.origin.y - p.y);
                _cropRect.origin.y = p.y;
            }

            if (_isMoveBottom && p.y > _cropRect.origin.y && p.y <  CGRectGetMaxY(_limitRect)) {
                _cropRect.size.height = p.y - _cropRect.origin.y;
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (_isMoveTop || _isMoveLeft || _isMoveRight || _isMoveBottom) {
                [self adjustCropRect:_cropRect];
            }
        }
        default:
            break;
    }
    
    [gesture setTranslation:CGPointZero inView:self.superview];
    [self setNeedsDisplay];
}


- (void) adjustCropRect:(CGRect) sourceCropRect {
    if (CGRectIsEmpty(sourceCropRect)) {
        return;
    }
    
    float limitRectRation = _limitRect.size.width * 1.0f / _limitRect.size.height;
    float sourceRectRation = sourceCropRect.size.width * 1.0f / sourceCropRect.size.height;

    if (sourceRectRation > limitRectRation) {
        _cropRect.origin.x = _limitRect.origin.x;
        _cropRect.size.width = _limitRect.size.width;
        _cropRect.size.height = _cropRect.size.width / sourceRectRation;
        _cropRect.origin.y  = (_limitRect.size.height - _cropRect.size.height) / 2.0f + _limitRect.origin.y;
    } else {
        _cropRect.origin.y = _limitRect.origin.y;
        _cropRect.size.height = _limitRect.size.height;
        _cropRect.size.width = _cropRect.size.height * sourceRectRation;
        _cropRect.origin.x  = (_limitRect.size.width - _cropRect.size.width) / 2.0f + _limitRect.origin.x;
    }

    CGFloat scale = _cropRect.size.width * 1.0f / sourceCropRect.size.width;
    CGFloat moveX = _cropRect.origin.x - sourceCropRect.origin.x;
    CGFloat moveY = _cropRect.origin.y - sourceCropRect.origin.y;
    
    [_delegate onCropComplete:scale centerPoint:sourceCropRect.origin
                     offset:CGPointMake(moveX, moveY)];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_cropRect.size.width == 0 || _cropRect.size.height == 0) {
        return;
    }
        
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (_isShowTransparentBackground) {
        [[UIColor clearColor] setFill];
        CGContextFillRect(context, rect);
        CGContextFillPath(context);
    } else {
        [[UIColor blackColor] setFill];
        CGContextFillRect(context, rect);
        CGContextAddRect(context, _cropRect);
        CGContextClip(context);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextAddRect(context, _cropRect);
        CGContextFillPath(context);
    }
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [self drawCropRect:context];
    [self drawCorner:context];
    if (_isShowGird) {
        [self drawGrid:context];
    }
}

- (void) drawCropRect:(CGContextRef) context {
    CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
    CGContextSetLineWidth(context, CROP_RECT_BORDER_LINE_WIDTH );
    
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect) + CORNER_LENGTH, CGRectGetMinY(_cropRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect) - CORNER_LENGTH, CGRectGetMinY(_cropRect));
    
    CGContextMoveToPoint(context, CGRectGetMaxX(_cropRect), CGRectGetMinY(_cropRect) + CORNER_LENGTH);
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect), CGRectGetMaxY(_cropRect) - CORNER_LENGTH);
    
    CGContextMoveToPoint(context, CGRectGetMaxX(_cropRect) - CORNER_LENGTH, CGRectGetMaxY(_cropRect));
    CGContextAddLineToPoint(context, CGRectGetMinX(_cropRect) + CORNER_LENGTH, CGRectGetMaxY(_cropRect));
    
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect), CGRectGetMaxY(_cropRect) - CORNER_LENGTH);
    CGContextAddLineToPoint(context, CGRectGetMinX(_cropRect), CGRectGetMinY(_cropRect) + CORNER_LENGTH);
    
    CGContextStrokePath(context);
}

- (void) drawCorner:(CGContextRef) context {
    float corner_width = CORNER_LINE_WIDTH;
    if (!_isShowTransparentBackground) {
        corner_width = 1.5f * corner_width;
    }
    CGContextSetLineWidth(context, corner_width);
    float halfLineWidth = corner_width / 2.0f;
    
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect) - halfLineWidth, CGRectGetMinY(_cropRect));
    CGContextAddLineToPoint(context, CGRectGetMinX(_cropRect) + CORNER_LENGTH, CGRectGetMinY(_cropRect));
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect), CGRectGetMinY(_cropRect) - halfLineWidth);
    CGContextAddLineToPoint(context, CGRectGetMinX(_cropRect), CGRectGetMinY(_cropRect) + CORNER_LENGTH);
    
    CGContextMoveToPoint(context, CGRectGetMaxX(_cropRect) - CORNER_LENGTH, CGRectGetMinY(_cropRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect) + halfLineWidth, CGRectGetMinY(_cropRect));
    CGContextMoveToPoint(context, CGRectGetMaxX(_cropRect), CGRectGetMinY(_cropRect) - halfLineWidth);
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect), CGRectGetMinY(_cropRect) + CORNER_LENGTH);
    
    CGContextMoveToPoint(context, CGRectGetMaxX(_cropRect), CGRectGetMaxY(_cropRect) - CORNER_LENGTH);
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect), CGRectGetMaxY(_cropRect) + halfLineWidth);
    CGContextMoveToPoint(context, CGRectGetMaxX(_cropRect) - CORNER_LENGTH, CGRectGetMaxY(_cropRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect) + halfLineWidth, CGRectGetMaxY(_cropRect));
    
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect), CGRectGetMaxY(_cropRect) - CORNER_LENGTH);
    CGContextAddLineToPoint(context, CGRectGetMinX(_cropRect), CGRectGetMaxY(_cropRect) + halfLineWidth);
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect) - halfLineWidth, CGRectGetMaxY(_cropRect));
    CGContextAddLineToPoint(context, CGRectGetMinX(_cropRect) + CORNER_LENGTH, CGRectGetMaxY(_cropRect));
    
    CGContextStrokePath(context);
}

- (void) drawGrid:(CGContextRef) context {
    CGContextSetLineWidth(context, CROP_RECT_GRID_LINE_WIDTH);
    
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect) + _cropRect.size.width / 3, CGRectGetMinY(_cropRect));
    CGContextAddLineToPoint(context, CGRectGetMinX(_cropRect) + _cropRect.size.width / 3, CGRectGetMaxY(_cropRect));
    
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect) + _cropRect.size.width * 2 / 3, CGRectGetMinY(_cropRect));
    CGContextAddLineToPoint(context, CGRectGetMinX(_cropRect) + _cropRect.size.width * 2 / 3, CGRectGetMaxY(_cropRect));
    
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect), CGRectGetMinY(_cropRect) + _cropRect.size.height / 3);
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect), CGRectGetMinY(_cropRect) + _cropRect.size.height / 3);
    
    CGContextMoveToPoint(context, CGRectGetMinX(_cropRect), CGRectGetMinY(_cropRect) + _cropRect.size.height * 2 / 3);
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect), CGRectGetMinY(_cropRect) + _cropRect.size.height * 2 / 3);
    
    CGContextStrokePath(context);
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) showTransparentBackground {
    _lastShowTransparentBackgroundTime = [NSDate date];
    if (!_isShowTransparentBackground) {
        _isShowTransparentBackground = YES;
        [self setNeedsDisplay];
        [self delayCancelShowTransparentBackground];
    }
}

- (void) delayCancelShowTransparentBackground {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC));
    
    @weakify(self) 
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        @strongify(self)
        if ([[NSDate date] timeIntervalSinceDate:self->_lastShowTransparentBackgroundTime] < 2.0f) {
            [self delayCancelShowTransparentBackground];
            return;
        }
        self->_isShowTransparentBackground = NO;
        [self setNeedsDisplay];
    });
}

- (void) showGrid {
    _lastShowGridTime = [NSDate date];
    if (!_isShowGird) {
        _isShowGird = YES;
        [self setNeedsDisplay];
        [self delayCancelShowGrid];
    }
}

- (void) delayCancelShowGrid {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC));
    
    @weakify(self) 
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        @strongify(self)
        if ([[NSDate date] timeIntervalSinceDate:self->_lastShowGridTime] < 4.0f) {
            [self delayCancelShowGrid];
            return;
        }
        self->_isShowGird = NO;
        [self setNeedsDisplay];
    });
}

@end
