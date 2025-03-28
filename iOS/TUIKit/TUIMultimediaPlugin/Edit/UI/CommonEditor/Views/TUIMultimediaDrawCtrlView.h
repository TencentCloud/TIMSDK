// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIMultimediaDrawView;
@class TUIMultimediaSticker;
@protocol TUIMultimediaDrawCtrlViewDelegate;
enum DrawMode:NSInteger;

@interface TUIMultimediaDrawCtrlView : UIView
-(void)flushRedoUndoState;
-(void)clearAllDraw;

@property (nonatomic, strong) TUIMultimediaDrawView* drawView;
@property (nonatomic) enum DrawMode drawMode;
@property (nonatomic) BOOL drawEnable;
@property (nonatomic, strong, readonly) TUIMultimediaSticker * drawSticker;
@property (weak, nullable, nonatomic) id<TUIMultimediaDrawCtrlViewDelegate> delegate;
@end

@protocol TUIMultimediaDrawCtrlViewDelegate <NSObject>
- (void)onIsDrawCtrlViewDrawing:(BOOL)Hidden;
@end

NS_ASSUME_NONNULL_END
