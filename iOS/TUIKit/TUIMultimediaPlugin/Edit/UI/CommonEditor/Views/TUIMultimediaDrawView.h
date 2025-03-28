// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIMultimediaPath;
@protocol TUIMultimediaDrawViewDelegate;

typedef NS_ENUM(NSInteger, DrawMode){
    GRAFFITI,
    MOSAIC
};

@interface TUIMultimediaDrawView : UIView
@property(nonatomic) UIColor *color;
@property(nonatomic) CGFloat lineWidth;
@property(readonly, nonatomic) NSInteger pathCount;
@property(weak, nullable, nonatomic) id<TUIMultimediaDrawViewDelegate> delegate;
@property(readonly, nonatomic) BOOL canUndo;
@property(readonly, nonatomic) BOOL canRedo;
@property(nonatomic) DrawMode drawMode;
@property (nonatomic, strong) UIImage *mosaciOriginalImage;

- (void)clear;
- (void)undo;
- (void)redo;
@end

@protocol TUIMultimediaDrawViewDelegate <NSObject>
- (void)drawViewPathListChanged:(TUIMultimediaDrawView *)v;
- (void)drawViewDrawStarted:(TUIMultimediaDrawView *)v;
- (void)drawViewDrawEnded:(TUIMultimediaDrawView *)v;
@end


@interface TUIMultimediaPath : NSObject
@property(nonatomic) CGSize originCanvasSize;
@property(nonatomic, nonnull) NSMutableArray<NSValue *> *pathPoints;
@property(nonatomic, nonnull) UIColor *color;
@end

NS_ASSUME_NONNULL_END
