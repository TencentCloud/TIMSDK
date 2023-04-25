//
//  TUIChatFlexViewController.h
//  TUIChat
//
//  Created by wyl on 2022/10/27.
//

#import <UIKit/UIKit.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN


@interface TUIChatFlexViewController : UIViewController

@property (nonatomic,strong) UIView *topGestureView;
@property (nonatomic, strong) UIImageView * topImgView;

@property (nonatomic,strong) UIView *containerView;

- (void)updateSubContainerView;

- (void)setnormalTop;

- (void)setNormalBottom;

@end

NS_ASSUME_NONNULL_END
