//
//  TUILiveRoomTipsView.h
//  Pods
//
//  Created by harvy on 2020/9/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveRoomTipsView : UIView

- (void)updateTips:(NSString *)tips background:(NSString *)url action:(dispatch_block_t)action;

@end

NS_ASSUME_NONNULL_END
