/******************************************************************************
 *
 *  本文件声明了用于实现表情菜单视图的组件。
 *  表情菜单视图，即在表情视图最下方的亮白色视图，负责显示各个表情分组及其缩略图，并提供“发送”按钮。
 *
 *  TMenuViewDelegate 协议，为表情菜单视图提供了发送信息和单元被选择时的事件回调。
 *  TUIMenuView 类，即表情菜单视图“本体”，负责在 UI 中以视图的形式进行显示，同时作为盛放各个组件的“容器”。
 *  您可以通过表情菜单视图在不同组别的表情下切换，或是发送表情。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>

@class TUIMenuView;

/////////////////////////////////////////////////////////////////////////////////
//
//                           TMenuViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  menuView 函数委托，实现 menuView 的响应回调
 */
@protocol TMenuViewDelegate <NSObject>

/**
 *  点击具体某一 menuCell 后的回调（索引定位）
 *  您可以通过该回调实现：响应用户的点击，根据用户选择的 menuCell 切换到对应的表情分组视图下。
 *
 *  @param menuView 委托者，表情菜单视图
 *  @param index 索引下标，从0开始。
 */
- (void)menuView:(TUIMenuView *)menuView didSelectItemAtIndex:(NSInteger)index;

/**
 *  menuView 点击发送按钮后的回调
 *  您可以通过该回调将当前输入框（TUIInputBar）中的内容发送。（TUIInputBar 的详细信息，请参考 Section\Chat\Input\TUIInputBar.h）
 *  在 TUIKit 的默认实现中，委托调用链为 menuView -> inputController -> messageController。
 *  分别调用上述类中的 sendMessage 委托/函数，使得功能合理分层的同时提高代码复用率。
 *  上述实现仅为您对该委托的实现提供参考作用，帮助您更好的理解 TUIKit 的运行机制。
 *
 *  @param menuView 委托者，表情菜单视图
 */
- (void)menuViewDidSendMessage:(TUIMenuView *)menuView;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIMenuView
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIMenuView
 * 【功能说明】用于实现聊天窗口中的表情菜单视图。
 *  表情菜单视图，即在表情视图最下方的亮白色视图。
 *  本视图负责显示各个表情分组及其缩略图，方便您快速在各个表情分组中切换，并提供“发送”按钮。
 *  您可以通过表情菜单视图在不同组别的表情下切换，或是发送表情。
 */
@interface TUIMenuView : UIView

/**
 *  发送按钮
 *  即在 muewView 最右侧的“发送”按钮。
 */
@property (nonatomic, strong) UIButton *sendButton;

/**
 *  表情菜单视图的collectionView
 *  包含多个 menuCell，并通过 menuFlowLayout 进行灵活统一的布局。
 */
@property (nonatomic, strong) UICollectionView *menuCollectionView;

/**
 *  表情菜单 collectionView 的流水布局。
 *  配合 menuCollectionView，维护表情菜单视图的布局，使表情排布更加美观。
 *  您可以在本布局中能够设置布局方向、行间距、cell 间距等。
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *menuFlowLayout;

/**
 *  被委托者，负责实现 TMenuViewDelegate 委托协议。
 */
@property (nonatomic, weak) id<TMenuViewDelegate> delegate;

/**
 *  滑动到某一索引菜单的回调函数
 *  通常情况下：设置cell状态与图标跟随滑动一同改变。
 *  您可以根据需求进行个性化实现。
 *
 *  @param index 索引值
 */
- (void)scrollToMenuIndex:(NSInteger)index;

/**
 *  设置表情菜单数据
 *  data 数组中存放对象类型为 TMenuCellData，即 MenuCell 的数据源。
 *
 *  @param data 需要设置的数据
 */
- (void)setData:(NSMutableArray *)data;
@end
