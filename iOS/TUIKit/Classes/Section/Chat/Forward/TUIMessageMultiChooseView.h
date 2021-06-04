/******************************************************************************
*
*  本文件声明用于实现消息列表多选的组件，及您在消息列表中长按某条消息后点击多选。
*  TFaceCellData：用于存放表情的名称、本地存储路径。
*  TUIFaceCell：用于存放表情的图像，并根据 TFaceCellData 初始化 Cell。
*
******************************************************************************/

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIMessageMultiChooseView;

@protocol TUIMessageMultiChooseViewDelegate <NSObject>

/**
 * 多选消息面板取消按钮被点击
 *
 * @param multiChooseView 消息多选面板
 */
- (void)messageMultiChooseViewOnCancelClicked:(TUIMessageMultiChooseView *)multiChooseView;

/**
* 多选消息面板转发按钮被点击
*
* @param multiChooseView 消息多选面板
*/
- (void)messageMultiChooseViewOnRelayClicked:(TUIMessageMultiChooseView *)multiChooseView;

/**
* 多选消息面板删除按钮被点击
*
* @param multiChooseView 消息多选面板
*/
- (void)messageMultiChooseViewOnDeleteClicked:(TUIMessageMultiChooseView *)multiChooseView;

@end

@interface TUIMessageMultiChooseView : UIView

@property (nonatomic, weak) id<TUIMessageMultiChooseViewDelegate> delegate;

#pragma mark - 顶部工具栏
/**
 * 顶部工具栏，展示取消等快捷操作
 */
@property (nonatomic, strong) UIView *toolView;

/**
 * 顶部工具栏元素：取消按钮
 */
@property (nonatomic, strong) UIButton *cancelButton;

/**
 * 顶部工具栏元素：title
 */
@property (nonatomic, strong) UILabel *titleLabel;

#pragma mark - 底部菜单栏
/**
 * 底部菜单栏，展示多选消息后的操作菜单，例如转发、删除等操作
 */
@property (nonatomic, strong) UIView *menuView;

/**
* 底部菜单栏元素：转发按钮
*/
@property (nonatomic, strong) UIButton *relayButton;

/**
* 底部菜单栏元素：删除按钮
*/
@property (nonatomic, strong) UIButton *deleteButton;

@end

NS_ASSUME_NONNULL_END
