// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaGraffitiDrawView : UIView
@property(nonatomic) UIColor *color;
@property(readonly, nonatomic) BOOL canUndo;
@property(readonly, nonatomic) BOOL canRedo;
@property(readonly, nonatomic) NSInteger pathCount;

- (void)clearGraffiti;
- (void)undo;
- (void)redo;
- (void)addPathPoint:(CGPoint) point;
- (void)completeAddPoint;
@end

NS_ASSUME_NONNULL_END
