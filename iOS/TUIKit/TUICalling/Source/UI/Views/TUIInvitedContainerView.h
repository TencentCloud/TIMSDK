//
//  TUIInvitedContainerView.h
//  TUICalling
//
//  Created by noah on 2021/8/30.
//

#import <UIKit/UIKit.h>
#import "TUIInvitedActionProtocal.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIInvitedContainerView : UIView

@property (nonatomic, weak) id<TUIInvitedActionProtocal> delegate;

- (void)configTitleColor:(UIColor *)titleColor;

@end

NS_ASSUME_NONNULL_END
