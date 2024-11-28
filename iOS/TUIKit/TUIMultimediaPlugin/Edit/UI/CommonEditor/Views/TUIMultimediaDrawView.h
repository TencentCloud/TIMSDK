// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIMultimediaPath;
@protocol TUIMultimediaDrawViewDelegate;

@interface TUIMultimediaDrawView : UIView
@property(nonatomic) UIColor *color;
@property(nonatomic) CGFloat lineWidth;
@property(readonly, nonatomic) NSArray<TUIMultimediaPath *> *pathList;
@property(weak, nullable, nonatomic) id<TUIMultimediaDrawViewDelegate> delegate;
@property(readonly, nonatomic) BOOL canUndo;
@property(readonly, nonatomic) BOOL canRedo;
- (void)undo;
- (void)redo;
@end

@protocol TUIMultimediaDrawViewDelegate <NSObject>
- (void)drawViewPathListChanged:(TUIMultimediaDrawView *)v;
- (void)drawViewDrawStarted:(TUIMultimediaDrawView *)v;
- (void)drawViewDrawEnded:(TUIMultimediaDrawView *)v;
@end

@interface TUIMultimediaPath : NSObject
@property(nonatomic) UIBezierPath *bezierPath;
@property(nonatomic) UIColor *color;
@end

NS_ASSUME_NONNULL_END
