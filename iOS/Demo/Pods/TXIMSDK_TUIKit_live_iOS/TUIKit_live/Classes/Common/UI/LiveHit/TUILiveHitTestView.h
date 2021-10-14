//
//  TUILiveHitTestView.h
//  Pods
//
//  Created by harvy on 2020/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUILiveHitTestViewDelegate <NSObject>

@optional

- (void)hitTest:(CGPoint)point withEvent:(UIEvent *)event view:(UIView *)view;

@end

@interface TUILiveHitTestView : UIView

@property (nonatomic, weak) id<TUILiveHitTestViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
