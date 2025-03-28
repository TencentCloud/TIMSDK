// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaGraffitiDrawView.h"
#import <Masonry/Masonry.h>
#import "TUIMultimediaPlugin/TUIMultimediaColorPanel.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"
#import "TUIMultimediaPlugin/TUIMultimediaDrawView.h"

#define GRAFFITI_LINE_WIDTH 4
#define CGPointMultiply(point, scalar) CGPointMake(point.x * scalar, point.y * scalar)

@interface TUIMultimediaGraffitiDrawView () {
    NSMutableArray<NSValue *> *_currentPathPoints;
    UIBezierPath *_currentPath;
    NSMutableArray<TUIMultimediaPath *> *_pathList;
    NSMutableArray<TUIMultimediaPath *> *_redoPathList;
}
@end

@implementation TUIMultimediaGraffitiDrawView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = UIColor.clearColor;
        _pathList = [NSMutableArray array];
        _redoPathList = [NSMutableArray array];
        _currentPathPoints = [NSMutableArray array];
        _color = UIColor.whiteColor;
    }
    return self;
}

- (NSInteger) pathCount {
    return _pathList.count;
}

- (BOOL)canUndo {
    return _pathList.count != 0;
}

- (BOOL)canRedo {
    return _redoPathList.count != 0;
}

- (void)clearGraffiti {
    [_pathList removeAllObjects];
    [_redoPathList removeAllObjects];
    [_currentPath removeAllPoints];
    [_currentPathPoints removeAllObjects];
    [self setNeedsDisplay];
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

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
    
    for (TUIMultimediaPath *path in _pathList) {
        [path.color set];
        CGFloat scale = self.frame.size.width / path.originCanvasSize.width;
        UIBezierPath * bezierPath = [TUIMultimediaGraffitiDrawView smoothBezierPathFromPoints:path.pathPoints scale:scale];
        [bezierPath stroke];
    }
    
    if (_currentPath != nil) {
        [_color set];
        [_currentPath stroke];
    }
}

- (NSArray<TUIMultimediaPath *> *)pathList {
    return _pathList;
}

- (void)addPathPoint:(CGPoint) point {
    [_currentPathPoints addObject:@(point)];
    _currentPath = [TUIMultimediaGraffitiDrawView smoothBezierPathFromPoints:_currentPathPoints scale:1.0];
    [self setNeedsDisplay];
}

- (void)completeAddPoint {
    TUIMultimediaPath *path = [[TUIMultimediaPath alloc] init];
    path.pathPoints = [[NSMutableArray alloc] initWithArray:_currentPathPoints copyItems:YES];
    path.color = _color;
    path.originCanvasSize = self.frame.size;
    [_pathList addObject:path];
    [_redoPathList removeAllObjects];
    [_currentPathPoints removeAllObjects];
    _currentPath = nil;
}

+ (UIBezierPath *)smoothBezierPathFromPoints:(NSMutableArray<NSValue *> *) pathPoints scale:(CGFloat)scale{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = GRAFFITI_LINE_WIDTH * scale;
    
    if (pathPoints.count <= 1) {
        return nil;
    }
    [path moveToPoint:CGPointMultiply(pathPoints.firstObject.CGPointValue, scale)];
    if (pathPoints.count == 2) {
        [path addLineToPoint:CGPointMultiply(pathPoints.lastObject.CGPointValue,scale)];
        return path;
    }

    for (int i = 3; i < pathPoints.count; i++) {
        CGPoint p = CGPointMultiply(pathPoints[i].CGPointValue, scale);
        CGPoint prev = CGPointMultiply(pathPoints[i - 1].CGPointValue, scale);
        CGPoint midPoint = Vec2Mul(Vec2AddVector(p, prev), 0.5);
        [path addQuadCurveToPoint:midPoint controlPoint:prev];
    }
    [path addLineToPoint:CGPointMultiply(pathPoints.lastObject.CGPointValue, scale)];
    return path;
}

@end

@implementation TUIMultimediaPath
- (instancetype)init {
    self = [super init];
    _color = UIColor.clearColor;
    return self;
}
@end
