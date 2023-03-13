//
//  TUIContactFloatController.h
//  TUIContact
//
//  Created by wyl on 2023/1/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIContactFloatSubViewControllerProtocol <NSObject>

@optional

- (void)floatControllerLeftButtonClick;

- (void)floatControllerRightButtonClick;

@end

@interface TUIContactFloatTitleView : UIView

@property (nonatomic,strong) UIButton * leftButton;
@property (nonatomic,strong) UIButton * rightButton;
@property (nonatomic,copy) void(^leftButtonClickCallback)(void);
@property (nonatomic,copy) void(^rightButtonClickCallback)(void);
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subTitleLabel;

- (void)setTitleText:(NSString *)mainText
        subTitleText:(NSString *)secondText
         leftBtnText:(NSString *)leftBtnText
        rightBtnText:(NSString *)rightBtnText;
@end

@interface TUIContactFloatController : UIViewController
@property (nonatomic,strong) TUIContactFloatTitleView *topGestureView;
@property (nonatomic,strong) UIImageView * topImgView;
@property (nonatomic,strong) UIView *containerView;

- (void)updateSubContainerView;

- (void)setnormalTop;

- (void)setNormalBottom;

- (void)appendChildViewController:(UIViewController<TUIContactFloatSubViewControllerProtocol> *)vc topMargin:(CGFloat)topMargin;

- (void)floatDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
@end

NS_ASSUME_NONNULL_END
