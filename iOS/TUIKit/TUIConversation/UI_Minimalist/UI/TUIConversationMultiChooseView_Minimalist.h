#import <UIKit/UIKit.h>
#import <TIMCommon/TUIFitButton.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationMultiChooseView_Minimalist : UIView
#pragma mark - Top toolbar
/**
 * 顶部工具栏，展示取消等快捷操作
 * The top toolbar, showing shortcut operations such as cancel
 */
@property (nonatomic, strong) UIView *toolView;

/**
 * 顶部工具栏元素：取消按钮
 * Top toolbar element: Cancel button
 */
@property (nonatomic, strong) UIButton *cancelButton;

/**
 * 顶部工具栏元素：title
 * Top toolbar element: title
 */
@property (nonatomic, strong) UILabel *titleLabel;

#pragma mark - Bottom menu bar
/**
 * 底部菜单栏，展示多选消息后的操作菜单，例如转发、删除等操作
 * The bottom menu bar,  shows the operation menu after multiple selection messages, such as forwarding, deleting, etc.
 */
@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, strong) TUIBlockButton *hideButton;
@property (nonatomic, strong) TUIBlockButton *readButton;
@property (nonatomic, strong) TUIBlockButton *deleteButton;

@end

NS_ASSUME_NONNULL_END
