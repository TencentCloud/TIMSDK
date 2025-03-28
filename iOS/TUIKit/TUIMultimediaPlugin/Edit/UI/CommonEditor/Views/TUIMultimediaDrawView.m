// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaDrawView.h"
#import <Masonry/Masonry.h>
#import "TUIMultimediaPlugin/TUIMultimediaColorPanel.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"
#import "TUIMultimediaPlugin/TUIMultimediaMosaicDrawView.h"
#import "TUIMultimediaPlugin/TUIMultimediaGraffitiDrawView.h"

@interface TUIMultimediaDrawView () {
    TUIMultimediaMosaicDrawView* _mosaciDrawView;
    TUIMultimediaGraffitiDrawView* _graffitiDrawView;
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
                
        _mosaciDrawView = [[TUIMultimediaMosaicDrawView alloc] initWithFrame:self.bounds];
        [self addSubview:_mosaciDrawView];
        [_mosaciDrawView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        _graffitiDrawView = [[TUIMultimediaGraffitiDrawView alloc] initWithFrame:self.bounds];
        [self addSubview:_graffitiDrawView];
        [_graffitiDrawView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (BOOL)canUndo {
    return _drawMode == GRAFFITI ? _graffitiDrawView.canUndo : _mosaciDrawView.canUndo;
}

- (BOOL)canRedo {
    return _drawMode == GRAFFITI ? _graffitiDrawView.canRedo : _mosaciDrawView.canRedo;
}

- (void)clear {
    [_graffitiDrawView clearGraffiti];
    [_mosaciDrawView clearMosaic];
}

- (void)undo {
    if (_drawMode == GRAFFITI) {
        [_graffitiDrawView undo];
    } else {
        [_mosaciDrawView undo];
    }
}

- (void)redo {
    if (_drawMode == GRAFFITI) {
        [_graffitiDrawView redo];
    } else {
        [_mosaciDrawView redo];
    }
}

- (void)onPan:(UIPanGestureRecognizer *)rec {
    switch (rec.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            CGPoint p = [rec locationInView:self];
            if (_drawMode == MOSAIC) {
                [_mosaciDrawView addPathPoint:p];
            } else {
                [_graffitiDrawView addPathPoint:p];
            }
            [_delegate drawViewDrawStarted:self];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (_drawMode == MOSAIC) {
                [_mosaciDrawView completeAddPoint];
            } else {
                [_graffitiDrawView completeAddPoint];
            }
            [_delegate drawViewDrawEnded:self];
            [_delegate drawViewPathListChanged:self];
            break;
        }
        default:
            break;
    }
}

- (NSInteger) pathCount {
    return _mosaciDrawView.pathCount + _graffitiDrawView.pathCount;
}

-(void) setMosaciOriginalImage:(UIImage *)mosaciOriginalImage {
    _mosaciDrawView.originalImage = mosaciOriginalImage;
}

-(void) setColor:(UIColor *)color {
    _graffitiDrawView.color = color;
}

@end
