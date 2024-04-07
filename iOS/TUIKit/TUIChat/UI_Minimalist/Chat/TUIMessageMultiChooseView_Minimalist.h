
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIMessageMultiChooseView_Minimalist;

@protocol TUIMessageMultiChooseViewDelegate_Minimalist <NSObject>

/**
 * Callback when the cancel button on the multi-select message panel is clicked
 */
- (void)messageMultiChooseViewOnCancelClicked:(TUIMessageMultiChooseView_Minimalist *)multiChooseView;

/**
 * Callback for when the forward button on the multi-select message panel is clicked
 */
- (void)messageMultiChooseViewOnRelayClicked:(TUIMessageMultiChooseView_Minimalist *)multiChooseView;

/**
 * Callback for when the delete button on the multi-select message panel is clicked
 */
- (void)messageMultiChooseViewOnDeleteClicked:(TUIMessageMultiChooseView_Minimalist *)multiChooseView;

@end

@interface TUIMessageMultiChooseView_Minimalist : UIView

@property(nonatomic, weak) id<TUIMessageMultiChooseViewDelegate_Minimalist> delegate;

#pragma mark - Top toolbar
/**
 * The top toolbar, showing shortcut operations such as cancel
 */
@property(nonatomic, strong) UIView *toolView;

/**
 * Top toolbar element: Cancel button
 */
@property(nonatomic, strong) UIButton *cancelButton;

/**
 * Top toolbar element: title
 */
@property(nonatomic, strong) UILabel *titleLabel;

#pragma mark - Bottom menu bar
/**
 * The bottom menu bar,  shows the operation menu after multiple selection messages, such as forwarding, deleting, etc.
 */
@property(nonatomic, strong) UIView *menuView;

/**
 * Bottom menu bar element: Forward button
 */
@property(nonatomic, strong) UIButton *relayButton;

@property(nonatomic, strong) UIButton *deleteButton;

@property(nonatomic, strong) UILabel *selectedCountLabel;

@property(nonatomic, strong) UIButton *bottomCancelButton;

@end

NS_ASSUME_NONNULL_END
