/******************************************************************************
 *
 *  本文件声明了用于实现“更多”视图的组件。
 *  更多视图，即在您点击聊天窗口右下角的“+”按钮浮现出的窗口。
 *  更多视图通常负责提供一些额外的重要功能，比如发送图片、拍摄图片并发送、发送视频、发送文件等。
 *  目前 TUIKit 实现并提供了上述的4种功能。如果上述的4中功能还无法满足您的功能需求的话，您也可以在本视图内添加您的自定义单元。
 *
 *  TUIMoreView 在已有的文本消息收发基础上提供了视频、图片、文件等多媒体消息的发送入口。
 *  TMoreViewDelegate 协议则为更多视图提供了响应回调，以响应用户的操作。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIInputMoreCell.h"

@class TUIMoreView;

/////////////////////////////////////////////////////////////////////////////////
//
//                           TMoreViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////


@protocol TMoreViewDelegate <NSObject>

/**
 *  点击某一moreCell后的回调
 *  您可以通过该回调响应用户的点击操作，对被点击的 cell 进行判断，并进行相对应的功能操作。
 *  本委托中调用了进一步 inputController: didSelectMoreCell: 这一委托。
 *  如果您想实现自定义更多单元的响应回调的话，您可以在上述函数中使用以下示例代码：
 *
 *
 *  @param moreView 委托者，更多视图。
 *  @param cell 被选择并传入的modeCell
 */
- (void)moreView:(TUIMoreView *)moreView didSelectMoreCell:(TUIInputMoreCell *)cell;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIMoreView
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIMoreView
 * 【功能说明】更多视图，在点击输入框最右侧“+”后显示。
 *  本视图能够为您在当前页面提供功能扩展。比如：
 *  1、拍摄。调用系统相机拍摄照片并进行发送。
 *  2、图片。从系统相册中选择图片并发送。
 *  3、视频。从系统相册中选择视频并发送。
 *  4、文件。从系统文件中选择文件并发送。
 *  您还可以根据需求对本视图进行个性化拓展，增加其他功能。
 */
@interface TUIMoreView : UIView

/**
 *  线视图
 *  在视图中的分界线，使得表情视图与其他视图在视觉上区分，从而让表情视图在显示逻辑上更加清晰有序。
 */
@property (nonatomic, strong) UIView *lineView;

/**
 *  更多视图的 CollectionView
 *  包含多个更多视图单元（按钮），并配合 moreFlowLayout 进行灵活统一的布局。
 */
@property (nonatomic, strong) UICollectionView *moreCollectionView;

/**
 *  moreCollectionView 的流水布局
 *  配合 moreCollectionView，用来维护表情视图的布局，使表情排布更加美观。能够设置布局方向、行间距、cell 间距等。
 */

@property (nonatomic, strong) UICollectionViewFlowLayout *moreFlowLayout;

/**
 *  moreView的页面控制器。
 *  用于 moreCell 的多页浏览，能够实现滑动切换更多视图页，在更多视图下方以原点形式显示总页数以及当前页数等功能。
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/**
 *  被委托者
 *  需要实现协议 TMoreViewDelegate 中要求的功能。
 */
@property (nonatomic, weak) id<TMoreViewDelegate> delegate;

/**
 *  设置数据
 *  用来进行 TUIMoreView 的数据初始化或在有需要时设置新的数据。
 *  数组中存放的元素类型为 TUIInputMoreCellData。
 *
 *  @param data     需要设置的数据
 */
- (void)setData:(NSArray *)data;
@end
