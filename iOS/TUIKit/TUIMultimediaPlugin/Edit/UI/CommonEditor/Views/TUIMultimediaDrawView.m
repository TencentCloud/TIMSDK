// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaDrawView.h"
#import <Masonry/Masonry.h>
#import "TUIMultimediaPlugin/TUIMultimediaColorPanel.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"

@interface TUIMultimediaDrawView () {
    NSMutableArray<TUIMultimediaPath *> *_pathList;
    NSMutableArray<TUIMultimediaPath *> *_redoPathList;
    NSMutableArray<NSValue *> *_currentPath;
}

@end

@implementation TUIMultimediaDrawView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = UIColor.clearColor;
        UIPanGestureRecognizer *panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        panRec.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panRec];
        _pathList = [NSMutableArray array];
        _redoPathList = [NSMutableArray array];
        _currentPath = [NSMutableArray array];
        _color = UIColor.whiteColor;
        _lineWidth = 4;
    }
    return self;
}

- (void)addPath:(TUIMultimediaPath *)path {
    [_pathList addObject:path];
    [_redoPathList removeAllObjects];
    [self setNeedsDisplay];
    [_delegate drawViewPathListChanged:self];
}

- (BOOL)canUndo {
    return _pathList.count != 0;
}

- (BOOL)canRedo {
    return _redoPathList.count != 0;
}

- (void)undo {
    if (_pathList.count == 0) {
        return;
    }
    TUIMultimediaPath *path = [_pathList lastObject];
    [_pathList removeLastObject];
    [_redoPathList addObject:path];
    [self setNeedsDisplay];
}

- (void)redo {
    if (_redoPathList.count == 0) {
        return;
    }
    TUIMultimediaPath *path = [_redoPathList lastObject];
    [_redoPathList removeLastObject];
    [_pathList addObject:path];
    [self setNeedsDisplay];
}

- (void)onPan:(UIPanGestureRecognizer *)rec {
    switch (rec.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint p = [rec locationInView:self];
            [_currentPath addObject:@(p)];
            [_delegate drawViewDrawStarted:self];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint p = [rec locationInView:self];
            [_currentPath addObject:@(p)];
            [self setNeedsDisplay];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            TUIMultimediaPath *path = [[TUIMultimediaPath alloc] init];
            path.bezierPath = [self smoothBezierPathFromCurrentPoints];
            path.color = _color;
            [self addPath:path];
            [_currentPath removeAllObjects];
            [_delegate drawViewDrawEnded:self];
            break;
        }
        default:
            break;
    }
}

// 生成平滑曲线
- (UIBezierPath *)smoothBezierPathFromCurrentPoints {
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = _lineWidth;
    if (_currentPath.count <= 1) {
        return path;
    }
    [path moveToPoint:_currentPath.firstObject.CGPointValue];
    if (_currentPath.count == 2) {
        [path addLineToPoint:_currentPath.lastObject.CGPointValue];
        return path;
    }
    // 从第point2&point3开始，避免最前面一段不平滑
    for (int i = 3; i < _currentPath.count; i++) {
        CGPoint p = _currentPath[i].CGPointValue;
        CGPoint prev = _currentPath[i - 1].CGPointValue;
        CGPoint midPoint = Vec2Mul(Vec2AddVector(p, prev), 0.5);
        [path addQuadCurveToPoint:midPoint controlPoint:prev];
    }
    [path addLineToPoint:_currentPath.lastObject.CGPointValue];
    return path;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    for (TUIMultimediaPath *path in _pathList) {
        [path.color set];
        [path.bezierPath stroke];
    }
    [_color set];
    [[self smoothBezierPathFromCurrentPoints] stroke];
}

- (NSArray<TUIMultimediaPath *> *)pathList {
    return _pathList;
}

@end

@implementation TUIMultimediaPath
- (instancetype)init {
    self = [super init];
    _bezierPath = [[UIBezierPath alloc] init];
    _color = UIColor.clearColor;
    return self;
}
- (instancetype)initWithPath:(UIBezierPath *)path color:(UIColor *)color {
    self = [super init];
    _bezierPath = path;
    _color = color;
    return self;
}
@end
