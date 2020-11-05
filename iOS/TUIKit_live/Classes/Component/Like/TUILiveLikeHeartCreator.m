//
//  TUILiveLikeHeartCreator.m
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveLikeHeartCreator.h"
#import "UIColor+MLPFlatColors.h"

// 频率控制类，如果频率没有超过 nCounts次/nSeconds秒，canTrigger将返回true
@interface TCFrequeControl : NSObject
- (instancetype)initWithCounts:(NSInteger)counts andSeconds:(NSTimeInterval)seconds;
- (BOOL)canTrigger;
@end
@implementation TCFrequeControl
{
    NSInteger                _countsLimit;
    NSInteger                _curCounts;
    NSTimeInterval           _secondsLimit;
    NSTimeInterval           _preTime;
}

- (instancetype)initWithCounts:(NSInteger)counts andSeconds:(NSTimeInterval)seconds {
    if (self = [super init]) {
        _countsLimit = counts;
        _secondsLimit = seconds;
        _curCounts = 0;
        _preTime = 0;
    }
    return self;
}

- (BOOL)canTrigger {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    if (_preTime == 0 || time - _preTime > _secondsLimit) {
        _preTime = time;
        _curCounts = 0;
    }
    if (_curCounts >= _countsLimit) {
        return NO;
    }
    _curCounts += 1;
    
    return YES;
}

@end

@interface TUILiveLikeHeartCreator ()
{
    NSMutableArray        *_heartAnimationPoints;
}
@end

@implementation TUILiveLikeHeartCreator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.createDuration = 0.1;
    }
    return self;
}

- (void)createHeartOn:(UIView *)superView startRect:(CGRect)rect {
    [self showLikeHeartStartRect:rect onView:superView];
}

- (void)showLikeHeartStartRect:(CGRect)frame onView:(UIView *)superView {
    // 星星动画频率限制
    static TCFrequeControl *freqControl = nil;
    if (freqControl == nil) {
        freqControl = [[TCFrequeControl alloc] initWithCounts:1.0/self.createDuration andSeconds:1];
    }
    if (![freqControl canTrigger]) {
        return;
    }
    
    if (superView.isHidden || superView.alpha == 0) {
        return;
    }
    UIImageView *imageView = [[UIImageView alloc ] initWithFrame:frame];
    imageView.image = [[UIImage imageNamed:@"live_audience_room_bottom_bar_like"] imageWithTintColor:[UIColor randomFlatDarkColor]];
    [superView addSubview:imageView];
    imageView.alpha = 0;
    
    
    [imageView.layer addAnimation:[self hearAnimationFrom:frame onView:superView] forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
    });
}

- (CAAnimation *)hearAnimationFrom:(CGRect)frame onView:(UIView *)superView {
    //位置
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.beginTime = 0.5;
    animation.duration = 2.5;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount= 0;
    animation.calculationMode = kCAAnimationCubicPaced;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPoint point0 = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
    
    CGPathMoveToPoint(curvedPath, NULL, point0.x, point0.y);
    
    if (!_heartAnimationPoints) {
        _heartAnimationPoints = [[NSMutableArray alloc] init];
    }
    if ([_heartAnimationPoints count] < 40) {
        float x11 = point0.x - arc4random() % 30 + 30;
        float y11 = frame.origin.y - arc4random() % 60 ;
        float x1 = point0.x - arc4random() % 15 + 15;
        float y1 = frame.origin.y - arc4random() % 60 - 30;
        CGPoint point1 = CGPointMake(x11, y11);
        CGPoint point2 = CGPointMake(x1, y1);
        
        int conffset2 = superView.bounds.size.width * 0.2;
        int conffset21 = superView.bounds.size.width * 0.1;
        float x2 = point0.x - arc4random() % conffset2 + conffset2;
        float y2 = arc4random() % 30 + 240;
        float x21 = point0.x - arc4random() % conffset21  + conffset21;
        float y21 = (y2 + y1) / 2 + arc4random() % 30 - 30;
        CGPoint point3 = CGPointMake(x21, y21);
        CGPoint point4 = CGPointMake(x2, y2);
        
        [_heartAnimationPoints addObject:[NSValue valueWithCGPoint:point1]];
        [_heartAnimationPoints addObject:[NSValue valueWithCGPoint:point2]];
        [_heartAnimationPoints addObject:[NSValue valueWithCGPoint:point3]];
        [_heartAnimationPoints addObject:[NSValue valueWithCGPoint:point4]];
    }
    
    // 从_heartAnimationPoints中随机选取一组point
    int idx = arc4random() % ([_heartAnimationPoints count]/4);
    CGPoint p1 = [[_heartAnimationPoints objectAtIndex:4*idx] CGPointValue];
    CGPoint p2 = [[_heartAnimationPoints objectAtIndex:4*idx+1] CGPointValue];
    CGPoint p3 = [[_heartAnimationPoints objectAtIndex:4*idx+2] CGPointValue];
    CGPoint p4 = [[_heartAnimationPoints objectAtIndex:4*idx+3] CGPointValue];
    CGPathAddQuadCurveToPoint(curvedPath, NULL, p1.x, p1.y, p2.x, p2.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, p3.x, p3.y, p4.x, p4.y);

    
    animation.path = curvedPath;
    
    CGPathRelease(curvedPath);
    
    //透明度变化
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnim.toValue = [NSNumber numberWithFloat:0];
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.beginTime = 0;
    opacityAnim.duration = 3;
    
    //比例
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnim.fromValue = [NSNumber numberWithFloat:.0];
    scaleAnim.toValue = [NSNumber numberWithFloat:1];
    scaleAnim.removedOnCompletion = NO;
    scaleAnim.fillMode = kCAFillModeForwards;
    scaleAnim.duration = .5;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects: scaleAnim,opacityAnim,animation, nil];
    animGroup.duration = 3;
    
    return animGroup;
}



@end
