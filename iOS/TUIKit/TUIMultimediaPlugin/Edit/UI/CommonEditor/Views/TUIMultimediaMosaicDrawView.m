// Copyright (c) 2025 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaMosaicDrawView.h"
#import <CoreImage/CoreImage.h>
#import <Masonry/Masonry.h>

#import "TUIMultimediaPlugin/TUIMultimediaDrawView.h"

#define MOSAIC_LINE_WIDTH 20
#define MOSAIC_SCALE_VALUE 50

@interface TUIMultimediaMosaicDrawView () {
    UIBezierPath *_currentPath;
    
    NSMutableArray<CAShapeLayer *> *_layerList;
    NSMutableArray<CAShapeLayer *> *_redoLayerList;
    
    CALayer *_maskParentLayer;
    CAShapeLayer *_currentShapeLayer;
    BOOL _isAdddPathFirstPoint;
}
@end

@implementation TUIMultimediaMosaicDrawView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    NSLog(@"Mosaic setupView");
    _maskParentLayer = [CALayer layer];
    _maskParentLayer.frame = self.bounds;
    self.layer.mask = _maskParentLayer;
    
    _layerList = [NSMutableArray array];
    _redoLayerList = [NSMutableArray array];
    _isAdddPathFirstPoint = YES;
}

- (void)setOriginalImage:(UIImage *)originalImage {
    NSLog(@"Mosaic setOriginalImage");
    _originalImage = originalImage;
    self.image = [self generateMosaicImage:originalImage];
}

-(void)addPathPoint:(CGPoint) point {
    if (_isAdddPathFirstPoint) {
        _isAdddPathFirstPoint = NO;
        _currentShapeLayer = [self createShapeLayer];
        [_maskParentLayer addSublayer:_currentShapeLayer];
        [_layerList addObject:_currentShapeLayer];
        _currentPath = [UIBezierPath bezierPath];
        [_currentPath moveToPoint:point];
    } else {
        [_currentPath addLineToPoint:point];
        _currentShapeLayer.path = _currentPath.CGPath;
    }
}

-(CAShapeLayer*)createShapeLayer{
    CAShapeLayer* shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineWidth = MOSAIC_LINE_WIDTH;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.fillColor = nil;
    return shapeLayer;
}

-(void)completeAddPoint {
    _isAdddPathFirstPoint = YES;
    for (CAShapeLayer * layer in _redoLayerList) {
        [self safeRemoveShapeLayer:layer];
    }
    [_redoLayerList removeAllObjects];
}

- (NSInteger) pathCount {
    return _layerList.count;
}

- (BOOL)canUndo {
    return _layerList.count != 0;
}

- (BOOL)canRedo {
    return _redoLayerList.count != 0;
}

- (void)clearMosaic {
    for (CAShapeLayer * layer in _layerList) {
        [self safeRemoveShapeLayer:layer];
    }
    
    for (CAShapeLayer * layer in _redoLayerList) {
        [self safeRemoveShapeLayer:layer];
    }
    
    [_currentPath removeAllPoints];
    [_layerList removeAllObjects];
    [_redoLayerList removeAllObjects];
}

- (void)undo {
    if (_layerList.count == 0) {
        return;
    }
    CAShapeLayer *layer = [_layerList lastObject];
    [_layerList removeLastObject];
    layer.hidden = YES;
    [_redoLayerList addObject:layer];
}

- (void)redo {
    if (_redoLayerList.count == 0) {
        return;
    }
    CAShapeLayer *layer = [_redoLayerList lastObject];
    [_redoLayerList removeLastObject];
    layer.hidden = NO;
    [_layerList addObject:layer];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _maskParentLayer.frame = self.bounds;
    
    for (CAShapeLayer *layer in _maskParentLayer.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            float scale = self.bounds.size.width / layer.frame.size.width;
            layer.frame = self.bounds;
            CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
            CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(layer.path, &transform);
            layer.lineWidth = layer.lineWidth * scale;
            layer.path = scaledPath;
            CGPathRelease(scaledPath);
        }
    }
}

- (UIImage *)generateMosaicImage:(UIImage *)inputImage {
    CIImage *ciImage = [[CIImage alloc] initWithImage:inputImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@(MOSAIC_SCALE_VALUE) forKey:kCIInputScaleKey];
    
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:outputImage.extent];
    return [UIImage imageWithCGImage:cgImage];
}

- (void)safeRemoveShapeLayer:(CAShapeLayer *)layer {
    if (!layer) return;

    [layer removeAllAnimations];
    layer.delegate = nil;
    layer.path = NULL;
    layer.fillColor = NULL;
    layer.strokeColor = NULL;
    [layer removeFromSuperlayer];
}

@end
