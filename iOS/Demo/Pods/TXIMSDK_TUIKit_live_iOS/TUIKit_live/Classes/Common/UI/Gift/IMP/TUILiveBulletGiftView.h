//
//  TUILiveBulletGiftView.h
//  Pods
//
//  Created by harvy on 2020/9/17.
//

#import <UIKit/UIKit.h>
@class TUILiveGiftInfo;

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveBulletGiftView : UIView

@property (nonatomic, strong) TUILiveGiftInfo *giftInfo;

- (void)playWithCompletion:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
