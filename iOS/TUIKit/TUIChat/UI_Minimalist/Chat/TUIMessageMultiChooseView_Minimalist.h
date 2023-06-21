
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIMessageMultiChooseView_Minimalist;

@protocol TUIMessageMultiChooseViewDelegate_Minimalist <NSObject>

/**
 * 多选消息面板上的取消按钮被点击的回调
 * Callback when the cancel button on the multi-select message panel is clicked
 */
- (void)messageMultiChooseViewOnCancelClicked:(TUIMessageMultiChooseView_Minimalist *)multiChooseView;

/**
 * 多选消息面板上的转发按钮被点击的回调
 * Callback for when the forward button on the multi-select message panel is clicked
 */
- (void)messageMultiChooseViewOnRelayClicked:(TUIMessageMultiChooseView_Minimalist *)multiChooseView;

/**
 * 多选消息面板上的删除按钮被点击的回调
 * Callback for when the delete button on the multi-select message panel is clicked
 */
- (void)messageMultiChooseViewOnDeleteClicked:(TUIMessageMultiChooseView_Minimalist *)multiChooseView;

@end

@interface TUIMessageMultiChooseView_Minimalist : UIView

@property(nonatomic, weak) id<TUIMessageMultiChooseViewDelegate_Minimalist> delegate;

#pragma mark - Top toolbar
/**
 * 顶部工具栏，展示取消等快捷操作
 * The top toolbar, showing shortcut operations such as cancel
 */
@property(nonatomic, strong) UIView *toolView;

/**
 * 顶部工具栏元素：取消按钮
 * Top toolbar element: Cancel button
 */
@property(nonatomic, strong) UIButton *cancelButton;

/**
 * 顶部工具栏元素：title
 * Top toolbar element: title
 */
@property(nonatomic, strong) UILabel *titleLabel;

#pragma mark - Bottom menu bar
/**
 * 底部菜单栏，展示多选消息后的操作菜单，例如转发、删除等操作
 * The bottom menu bar,  shows the operation menu after multiple selection messages, such as forwarding, deleting, etc.
 */
@property(nonatomic, strong) UIView *menuView;

/**
 * 底部菜单栏元素：转发按钮
 * Bottom menu bar element: Forward button
 */
@property(nonatomic, strong) UIButton *relayButton;

@property(nonatomic, strong) UIButton *deleteButton;

@property(nonatomic, strong) UILabel *selectedCountLabel;

@property(nonatomic, strong) UIButton *bottomCancelButton;

@end

NS_ASSUME_NONNULL_END
