//
//  TUIChatPopContextController.h
//  TUIChat
//
//  Created by wyl on 2022/10/24.
//

#import <UIKit/UIKit.h>
#import "TUIMessageCellData.h"
#import "TUIMessageCell.h"
#import "TUIChatPopContextRecentView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BlurEffectStyle) {
    BlurEffectStyleLight,
    BlurEffectStyleExtraLight,
    BlurEffectStyleDarkEffect,
};
@interface TUIChatPopContextController : UIViewController

@property (nonatomic, strong) Class alertCellClass;

@property (nonatomic, strong) TUIMessageCellData *alertViewCellData;

@property (nonatomic, assign) CGRect originFrame;

@property (copy, nonatomic) void (^viewWillShowHandler)(TUIMessageCell *alertView);

@property (copy, nonatomic) void (^viewDidShowHandler)(TUIMessageCell *alertView);

// dismiss controller completed block
@property (nonatomic, copy) void (^dismissComplete)(void);

@property (nonatomic, copy) void(^reactClickCallback)(NSString *faceName);

@property (nonatomic, strong) NSMutableArray<TUIChatPopContextExtionItem *> *Items;

- (void)setBlurEffectWithView:(UIView *)view;

- (void)blurDismissViewControllerAnimated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;

- (void)updateExtionView;

@end

NS_ASSUME_NONNULL_END
