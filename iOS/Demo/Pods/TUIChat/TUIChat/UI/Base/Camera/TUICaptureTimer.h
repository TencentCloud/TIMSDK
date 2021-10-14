

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICaptureTimer : NSObject
@property (nonatomic, assign) CGFloat maxCaptureTime;
@property (nonatomic, assign, readonly) CGFloat captureDuration;

@property (nonatomic, copy) void(^progressBlock)(CGFloat ratio, CGFloat recordTime);
@property (nonatomic, copy) void(^progressCancelBlock)(void);
@property (nonatomic, copy) void(^progressFinishBlock)(CGFloat ratio, CGFloat recordTime);

- (void)startTimer;
- (void)stopTimer;

@end

NS_ASSUME_NONNULL_END
