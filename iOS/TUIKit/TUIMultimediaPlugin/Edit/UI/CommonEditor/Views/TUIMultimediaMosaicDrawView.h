// Copyright (c) 2025 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>

@interface TUIMultimediaMosaicDrawView : UIImageView
@property (nonatomic, strong) UIImage *originalImage;
@property(readonly, nonatomic) BOOL canUndo;
@property(readonly, nonatomic) BOOL canRedo;
@property(readonly, nonatomic) NSInteger pathCount;

- (void)clearMosaic;
- (void)undo;
- (void)redo;
- (void)addPathPoint:(CGPoint) point;
- (void)completeAddPoint;
@end
