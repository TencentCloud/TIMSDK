//
//  TUIConversationFloatController.h
//  TUIConversation
//
//  Created by wyl on 2023/1/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIConversationFloatSubViewControllerProtocol <NSObject>

@optional

@property (nonatomic, copy) void(^floatDataSourceChanged)(NSArray *arr);

- (void)floatControllerLeftButtonClick;

- (void)floatControllerRightButtonClick;

@end

@interface TUIConversationFloatTitleView : UIView

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

@interface TUIConversationFloatController : UIViewController
@property (nonatomic,strong) TUIConversationFloatTitleView *topGestureView;
@property (nonatomic,strong) UIImageView * topImgView;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) UIViewController<TUIConversationFloatSubViewControllerProtocol> * childVC;

- (void)updateSubContainerView;

- (void)setnormalTop;

- (void)setNormalBottom;

- (void)appendChildViewController:(UIViewController *)vc topMargin:(CGFloat)topMargin;

- (void)floatDismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
@end

NS_ASSUME_NONNULL_END
