/**
 *  【模块说明】
 *  - 本文件声明了 TFaceViewDelegate 协议以及 TUIFaceGroup 和 TUIFaceView 两个类。
 *  - 本文件用于实现聊天窗口中的表情浏览视图，即在默认状态下点击笑脸图标打开的界面。
 *  - 通过本视图，您可以查看并使用您的所有表情，在不同的表情分组间进行浏览，进一步进行表情的选择与发送。
 *  - 本视图已经整合了字符串类型的表情（如[微笑]）的编辑功能。
 *
 *  【功能描述】
 *  -  TUIFaceView：表情视图，展示各个分组的表情，并提供表情的选取、删除功能。
 *  - TUIFaceGroup：表情组。包括表情组的初始化、单个表情的定位等。
 *
 *
 *  【Module Description】
 *  - This file declares the TFaceViewDelegate protocol and two classes, TUIFaceGroup and TUIFaceView.
 *  - This file is used to implement the emoticon browsing view in the chat window, that is, the interface opened by clicking the smiley face icon in the default state.
 *  - Through this view, you can view and use all your emoticons, browse between different emoji groups, and further select and send emoticon message.
 *  - This view has integrated the editing function of string-type expressions (such as [Smile]).
 *
 *  【Function description】
 *  - TUIFaceView: Emoji view, which displays the emoticons of each group, and provides functions for selecting and deleting emoticons.
 *  - TUIFaceGroup: Emoticons group. Including the initialization of the emoticons group, the positioning of a single emoticon, etc.
 */
#import <UIKit/UIKit.h>
#import "TUICommonModel.h"

@class TUIFaceView;


/////////////////////////////////////////////////////////////////////////////////
//
//                          TFaceViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////


@protocol TFaceViewDelegate <NSObject>

/**
 *  滑动到指定表情分组后的回调。
 *  - 您可以通过该回调响滑动操作，进而更新表情视图的信息，展示出新表情组内的表情。
 *
 *  @param faceView 委托者，表情视图。通常情况下表情视图有且仅有一个。
 *  @param index 滑动到的表情组的索引。
 */
/**
 *  The callback after sliding to the specified emoticons group.
 *  - You can use this callback to respond to the swipe operation, and then update the information of the emoticon view to display the emoticons in the new emoticon group.
 *
 *  @param faceView Delegator, emoticon view. Usually, the expression view has one and only one.
 *  @param index The index of the emoji group to which slide.
 */
- (void)faceView:(TUIFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index;

/**
 *  选择某一具体表情后的回调（索引定位）。
 *  您可以通过该回调实现：
 *  - 当点击字符串类型的表情（如[微笑]）时，将表情添加到输入条。
 *  - 当点击其他类型的表情时，直接发送该表情。
 *
 *  @param faceView 委托者，表情视图。通常情况下表情视图有且仅有一个。
 *  @param indexPath 索引路径，用于定位表情。index.section：表情所在分组；index.row：表情所在行。
 */
/**
 *  The Callback after selecting a specific emoticon (index positioning).
 *  You can use this callback to achieve:
 *  - When a string type emoticon (such as [smile]) is clicked, add the emoticon to the input bar.
 *  - When clicking on another type of emoji, send that emoji directly.
 *
 *  @param faceView Delegator, emoticon view. Usually, the expression view has one and only one.
 *  @param indexPath Index path, used to locate expressions. index.section: the group where the expression is located; index.row: the row where the expression is located.
 */
- (void)faceView:(TUIFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  点击表情视图中 删除 按钮后的操作回调。
 *  您可以通过该回调实现：在 inputBar 中删除整个表情字符串，比如，对于“[微笑]”，直接删除中括号以及括号中间的内容，而不是仅删除最右侧”]“。
 *
 *  @param faceView 委托者，表情视图，通常情况下表情视图有且仅有一个。
 */
/**
 *  The action callback after clicking the delete button in the emoji view.
 *  You can use this callback to delete the entire emoji string in the inputBar, for example, for "[smile]", delete the square brackets and the content between the brackets directly, instead of only deleting the rightmost "]".
 *
 *  @param faceView Delegator, emoticon view. Usually, the expression view has one and only one.
 */
- (void)faceViewDidBackDelete:(TUIFaceView *)faceView;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIFaceView
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIFaceView
 * 【功能说明】用于实现聊天窗口中的表情浏览视图，即在默认状态下点击笑脸图标打开的界面。
 *  - 通过本视图，您可以查看所有可用的表情，支持表情分组，以及表情的选择和发送。
 *  - 本视图已经整合了字符串类型的表情（如[微笑]）的编辑功能，以及图像类表情的选取与发送功能。
 *
 * 【Module name】TUIFaceView
 * 【Function description】It is used to realize the emoticon browsing view in the chat window, that is, the interface opened by clicking the smiley face icon in the default state.
 *  - Through this view, you can view all available emoticons, support emoticon grouping, select and send emoticons.
 *  - This view has integrated the editing functions of string-type emoticons (such as [smile]), and the selection and sending functions of image-type emoticons.
 */
@interface TUIFaceView : UIView

/**
 *  线视图
 *  视图中的分界线，区分表情和其他视图。
 *
 *  Line view
 *  The separtor which distinguish emoticons from other views
 */
@property (nonatomic, strong) UIView *lineView;

/**
 *  表情视图的 CollectionView
 *  包含多行表情，并配合 faceFlowLayout 进行灵活统一的视图布局。
 *
 *  The collectionView of emoticon view
 *  Contains multiple lines of expressions, and cooperates with faceFlowLayout for flexible and unified view layout.
 */
@property (nonatomic, strong) UICollectionView *faceCollectionView;

/**
 *  faceCollectionView 的流水布局
 *  配合 faceCollectionView，使表情视图更加美观。支持设置布局方向、行间距、cell 间距等。
 *
 *  The flow layout of @faceCollectionView
 *  Cooperating with faceCollectionView to make the expression view more beautiful. Supported setting layout direction, line spacing, cell spacing, etc.
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *faceFlowLayout;

/**
 *  分页控制
 *  用于实现表情的多页浏览，能够滑动切换表情页，在表情页下方以小圆点形式显示总页数以及当前页数等功能。
 *
 *  Page control
 *  It is used to realize multi-page browsing of emoticons, can slide to switch emoticon pages, and display the total number of pages and the current number of pages in the form of small dots below the emoticon page.
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/**
 *
 *  faceView 中的数据。
 *  在此 NSMutableArray 中存放的对象为 TUIFaceGroup，即表情组。
 *
 *  The data of @faceView
 *  The object stored in this NSMutableArray is TUIFaceGroup, that is, the expression group.
 */
@property (nonatomic, strong, readonly) NSMutableArray *faceGroups;
@property (nonatomic, strong, readonly) NSMutableArray *sectionIndexInGroup;
@property (nonatomic, strong, readonly) NSMutableArray *pageCountInGroup;
@property (nonatomic, strong, readonly) NSMutableArray *groupIndexInSection;
@property (nonatomic, strong, readonly) NSMutableDictionary *itemIndexs;

/**
 *  委托变量，被委托者
 *  需要实现 TFaceViewDelegate 协议中要求的功能。
 *
 *  Delegate variable, delegated
 *  Need to implement the functionality required in the @TFaceViewDelegate protocol.
 */
@property (nonatomic, weak) id<TFaceViewDelegate> delegate;

/**
 *  滑动到指定表情分组。
 *  根据用户点击的表情分组的下标，切换表情分组。
 *
 *  @param index 目的分组的索引，从0开始。
 */
/**
 *  Swipe to the specified expression group.
 *  Switch the emoticon group according to the subscript of the emoticon group clicked by the user.
 *
 *  @param index The index of the destination group, starting from 0.
 */
- (void)scrollToFaceGroupIndex:(NSInteger)index;

/**
 *  设置数据。
 *  用来进行 TUIFaceView 的初始化或在需要时更新 faceView 中的数据。
 *
 *  @param data 需要设置的数据（TUIFaceGroup）。在此 NSMutableArray 中存放的对象为 TUIFaceGroup，即表情组。
 */
/**
 *  Setting data
 *  Used to initialize TUIFaceView or update data in faceView when needed.
 *
 *  @param data The data that needs to be set (TUIFaceGroup). The object stored in this NSMutableArray is TUIFaceGroup, that is, the emoticon group.
 */
- (void)setData:(NSMutableArray *)data;
@end
