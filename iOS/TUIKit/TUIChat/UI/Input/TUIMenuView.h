/**
 *
 *  本文件声明了用于实现表情菜单视图的组件。
 *  表情菜单视图，即在表情视图最下方的亮白色视图，负责显示各个表情分组及其缩略图，并提供“发送”按钮。
 *
 *  TMenuViewDelegate 协议，为表情菜单视图提供了发送信息和单元被选择时的事件回调。
 *  TUIMenuView 类，即表情菜单视图“本体”，负责在 UI 中以视图的形式进行显示，同时作为盛放各个组件的“容器”。
 *  您可以通过表情菜单视图在不同组别的表情下切换，或是发送表情。
 *
 *  This file declares the components used to implement the emoji menu view.
 *  The emoji menu view, the bright white view at the bottom of the emoji view, is responsible for displaying individual emoji groups and their thumbnails, and providing a "Send" button.
 *
 *  The TMenuViewDelegate protocol provides the emoticon menu view with event callbacks for sending messages and cell selection.
 *  The TUIMenuView class, the "ontology" of the emoticon menu view, is responsible for displaying it in the form of a view in the UI, and at the same time serving as a "container" for each component.
 *  You can switch between different groups of emoticons or send emoticons through the emoticon menu view.
 */
#import <UIKit/UIKit.h>
#import "TUIMenuCellData.h"

@class TUIMenuView;

/////////////////////////////////////////////////////////////////////////////////
//
//                           TMenuViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TMenuViewDelegate <NSObject>

/**
 *  点击具体某一 menuCell 后的回调
 *  您可以通过该回调实现：响应用户的点击，根据用户选择的 menuCell 切换到对应的表情分组视图下。
 *
 *  Callback after clicking on a specific menuCell
 *  You can use this callback to achieve: in response to the user's click, switch to the corresponding emoticon group view according to the menuCell selected by the user.
 */
- (void)menuView:(TUIMenuView *)menuView didSelectItemAtIndex:(NSInteger)index;

/**
 *  点击 menuView 上的发送按钮后的回调
 *  您可以通过该回调将当前输入框（TUIInputBar）中的内容发送。
 *  在 TUIKit 的默认实现中，委托调用链为 menuView -> inputController -> messageController。
 *  分别调用上述类中的 sendMessage 函数，使得功能合理分层的同时提高代码复用率。
 *
 *  Callback after click of send button on menuView
 *  You can send the content of the current input box (TUIInputBar) through this callback
 *  In the default implementation of TUIKit, the delegate call chain is menuView -> inputController -> messageController.
 *  Call the sendMessage function in the above classes respectively, so that the functions are reasonably layered and the code reuse rate is improved.
 */
- (void)menuViewDidSendMessage:(TUIMenuView *)menuView;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIMenuView
//
/////////////////////////////////////////////////////////////////////////////////
///
@interface TUIMenuView : UIView

@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) UICollectionView *menuCollectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *menuFlowLayout;

@property (nonatomic, weak) id<TMenuViewDelegate> delegate;


- (void)scrollToMenuIndex:(NSInteger)index;

- (void)setData:(NSMutableArray<TUIMenuCellData *> *)data;

@end
