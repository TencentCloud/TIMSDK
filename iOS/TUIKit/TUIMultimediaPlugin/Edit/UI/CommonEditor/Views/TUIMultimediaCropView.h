// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>

@protocol TUIMultimediaCropDelegate;

@interface TUIMultimediaCropView : UIView
@property(nonatomic) CGRect preViewFrame;
@property(weak, nullable, nonatomic) id<TUIMultimediaCropDelegate> delegate;
-(void)reset;
-(void)rotation90;
-(CGRect)getCropRect;
@end

@protocol TUIMultimediaCropDelegate <NSObject>
- (void)onStartCrop;
- (void)onCropComplete:(CGFloat)scale centerPoint:(CGPoint)centerPoint offset:(CGPoint)offset;
@end
