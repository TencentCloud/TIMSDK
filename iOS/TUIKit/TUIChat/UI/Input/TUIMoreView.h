/**
 *  本文件声明了用于实现“更多”视图的组件。
 *  更多视图，即在您点击聊天窗口右下角的“+”按钮浮现出的窗口。
 *  更多视图通常负责提供一些额外的重要功能，比如发送图片、拍摄图片并发送、发送视频、发送文件等。
 *  目前 TUIKit 实现并提供了上述的4种功能。如果上述的4中功能还无法满足您的功能需求的话，您也可以在本视图内添加您的自定义单元。
 *
 *  TUIMoreView 在已有的文本消息收发基础上提供了视频、图片、文件等多媒体消息的发送入口。
 *  TMoreViewDelegate 协议则为更多视图提供了响应回调，以响应用户的操作。
 *
 *  This file declares the components used to implement the "more" view.
 *  More view, the window that appears when you click the "+" button in the lower right corner of the chat window.
 *  More view are usually responsible for providing some additional important functions, such as sending pictures, taking pictures and sending, sending videos, sending files, etc.
 *  Currently TUIKit implements and provides the above four functions. If the above 4 functions cannot meet your functional requirements, you can also add your custom unit in this view.
 *
 *  TUIMoreView provides an entry for sending multimedia messages such as videos, pictures, and files based on the existing text messaging.
 *  The TMoreViewDelegate protocol provides callbacks for more views in response to user actions.
 */

#import <UIKit/UIKit.h>
#import "TUIInputMoreCell.h"

@class TUIMoreView;

/////////////////////////////////////////////////////////////////////////////////
//
//                           TMoreViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////


@protocol TMoreViewDelegate <NSObject>

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
 *
 * 【Module name】 TUIMoreView
 * 【Function description】More view are displayed after clicking the "+" on the far right of the input box.
 *  This view can provide you with functional extensions on the current page. for example:
 *  1. Camera. Call the system camera to take a photo and send
 *  2. Photo. Select a picture from the system album and send it.
 *  3. Video. Select a video from the system gallery and send it.
 *  4. File. Select file from system files and send.
 */
@interface TUIMoreView : UIView

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UICollectionView *moreCollectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *moreFlowLayout;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, weak) id<TMoreViewDelegate> delegate;

- (void)setData:(NSArray *)data;

@end
