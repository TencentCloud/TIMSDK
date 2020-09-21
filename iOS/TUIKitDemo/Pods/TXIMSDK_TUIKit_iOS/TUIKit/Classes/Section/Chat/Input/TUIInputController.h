 /******************************************************************************
  *
  * 本文件声明了实现输入区的相关组件。
  * 输入区即包括表情视图输入区（TUIFaceView+TUIMoreView）、“更多”功能区（TUIMoreView）和文本输入区（TUIInputBar）。
  * 本文件包含TInputControllerDelegate 协议和 TInputController 类。
  * 在输入条（TUIInputBar）中，提供了表情、语音、更多视图的按钮响应委托。
  * 而在本类中，将 InputBar 与上述三个视图实际结合，实现了各个视图的显示与切换的逻辑。
  *
  ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIInputBar.h"
#import "TUIFaceView.h"
#import "TUIMenuView.h"
#import "TUIMoreView.h"
#import "TUIMessageCell.h"

@class TUIInputController;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

/**
 *  控制器的回调委托。
 *  通常由各个视图（InputBar、MoreView 等）中的回调函数进一步调用。实现功能的分层与逐步细化。
 */
@protocol TInputControllerDelegate <NSObject>

/**
 *  当前 InputController 高度改变时的回调。
 *  一般由 InputBar 中的高度改变回调进一步调用。
 *  您可以通过该回调实现：根据改变的高度调整控制器内各个组件的 UI 布局。
 *
 *  @param  inputController 委托者，当前参与交互的视图控制器。
 *  @param height 改变高度的具体数值（偏移量）。
 */
- (void)inputController:(TUIInputController *)inputController didChangeHeight:(CGFloat)height;

/**
 *  当前 InputCOntroller 发送信息时的回调。
 *  一般由 InputBar 中的发送信息回调进一步调用。
 *  您可以通过该回调实现：将该信息（TUIMessageCellData）执行发送。
 *  TUIKit 的默认实现中，在本回调的实现函数中调用了 TUIMessageController 中的已经封装好的 sendMessage 函数进行消息发送。
 *
 *  @param  inputController 委托者，当前参与交互的视图控制器。
 *  @param msg 当前控制器所获取并准备发送的消息。
 */
- (void)inputController:(TUIInputController *)inputController didSendMessage:(TUIMessageCellData *)msg;

/**
 *  点击某一具体“更多”单元后的回调。
 *  一般由 MoreView 中的点击回调进一步调用。
 *  您可以通过该回调实现：根据点击的单元的类型，进行对应类型相应的进一步操作。比如选择图片、选择文件等。
 *  同时在本委托的实现中，含有以下代码：
 * <pre>
 *- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell{
 *  ……
 *  ……
 *      if(_delegate && [_delegate respondsToSelector:@selector(chatController:onSelectMoreCell:)]){
 *      [_delegate chatController:self onSelectMoreCell:cell];
 *      }
 *  }
 * </pre>
 *  上述代码能够帮助您实现“更多”单元的自定义。
 *  更多信息您可以参照 Section\Chat\TUIChatController.h 中的注释进一步了解。
 *
 *  @param  inputController 委托者，当前参与交互的视图控制器。
 *  @param cell 被选中的单元。
 */
- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell;

/**
 *  有 @ 字符输入
 */
- (void)inputControllerDidInputAt:(TUIInputController *)inputController;

/**
 *  有 @xxx 字符删除
 */
- (void)inputController:(TUIInputController *)inputController didDeleteAt:(NSString *)atText;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                         TInputControllerDelegate
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIInputController
 * 【功能说明】TUI 输入控制器，实现了输入条中进一步的业务逻辑。
 *  在输入条（TUIInputBar）中，提供了表情、语音、更多视图的按钮和响应回调。
 *  而在本类中，将 InputBar 与上述三个视图实际结合，实现了各个视图的显示与切换的逻辑。
 */
@interface TUIInputController : UIViewController

/**
 *  输入条
 *  输入条中包含文本输入框、语音按钮、“更多”按钮、表情按钮等一系列交互组件，并提供了这些组件的对应回调委托。
 *  详细信息请参考 Section\Chat\Input\TUIInputBar.h
 */
@property (nonatomic, strong) TUIInputBar *inputBar;

/**
 *  表情视图
 *  表情视图一般在点击“笑脸”按钮后浮现。负责显示各个表情分组，与分组内表情的具体信息。
 *  详细信息请参考 Section\Chat\TUIFaceView.h
 */
@property (nonatomic, strong) TUIFaceView *faceView;

/**
 *  菜单视图
 *  菜单视图位于表情视图下方，负责提供表情分组单元以及发送按钮。
 *  详细信息请参考 Section\Chat\TUIMenuView.h
 */
@property (nonatomic, strong) TUIMenuView *menuView;

/**
 *  更多视图
 *  更多视图一般在点击“更多“按钮（”+“按钮）后浮现，负责显示各个更多单元，比如拍摄、视频、文件、相册等。
 *  详细信息请参考 Section\Chat\TUIMoreView.h
 */
@property (nonatomic, strong) TUIMoreView *moreView;

/**
 *  实现 TInputControllerDelegate 协议的委托。
 */
@property (nonatomic, weak) id<TInputControllerDelegate> delegate;

/**
 *  重置当前输入控制器。
 *  如果当前有表情视图或者“更多“视图正在显示，则收起相应视图，并将当前状态设置为 Input_Status_Input。
 *  即无论当前 InputController 处于何种状态，都将其重置为初始化后的状态。
 */
- (void)reset;
@end
