
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TIMCommon/TUIFitButton.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationMultiChooseView_Minimalist : UIView
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

@property(nonatomic, strong) TUIBlockButton *hideButton;
@property(nonatomic, strong) TUIBlockButton *readButton;
@property(nonatomic, strong) TUIBlockButton *deleteButton;

@end

NS_ASSUME_NONNULL_END
