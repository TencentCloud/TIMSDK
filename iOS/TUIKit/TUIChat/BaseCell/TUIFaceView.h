
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  【Module Description】
 *  - This file declares the TUIFaceViewDelegate protocol and two classes, TUIFaceGroup and TUIFaceView.
 *  - This file is used to implement the emoticon browsing view in the chat window, that is, the interface opened by clicking the smiley face icon in the
 * default state.
 *  - Through this view, you can view and use all your emoticons, browse between different emoji groups, and further select and send emoticon message.
 *  - This view has integrated the editing function of string-type expressions (such as [Smile]).
 *
 *  【Function description】
 *  - TUIFaceView: Emoji view, which displays the emoticons of each group, and provides functions for selecting and deleting emoticons.
 *  - TUIFaceGroup: Emoticons group. Including the initialization of the emoticons group, the positioning of a single emoticon, etc.
 */
#import <TIMCommon/TIMCommonModel.h>
#import <UIKit/UIKit.h>

@class TUIFaceView;

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIFaceViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIFaceViewDelegate <NSObject>

/**
 *  The callback after sliding to the specified emoticons group.
 *  - You can use this callback to respond to the swipe operation, and then update the information of the emoticon view to display the emoticons in the new
 * emoticon group.
 *
 *  @param faceView Delegator, emoticon view. Usually, the expression view has one and only one.
 *  @param index The index of the emoji group to which slide.
 */
- (void)faceView:(TUIFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index;


/**
 *  The Callback after selecting a specific emoticon (index positioning).
 *  You can use this callback to achieve:
 *  - When a string type emoticon (such as [smile]) is clicked, add the emoticon to the input bar.
 *  - When clicking on another type of emoji, send that emoji directly.
 *
 *  @param faceView Delegator, emoticon view. Usually, the expression view has one and only one.
 *  @param indexPath Index path, used to locate expressions. index.section: the group where the expression is located; index.row: the row where the expression
 * is located.
 */
- (void)faceView:(TUIFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  The action callback after clicking the delete button in the emoji view.
 *  You can use this callback to delete the entire emoji string in the inputBar, for example, for "[smile]", delete the square brackets and the content between
 * the brackets directly, instead of only deleting the rightmost "]".
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
 * 【Module name】TUIFaceView
 * 【Function description】It is used to realize the emoticon browsing view in the chat window, that is, the interface opened by clicking the smiley face icon
 * in the default state.
 *  - Through this view, you can view all available emoticons, support emoticon grouping, select and send emoticons.
 *  - This view has integrated the editing functions of string-type emoticons (such as [smile]), and the selection and sending functions of image-type
 * emoticons.
 */
@interface TUIFaceView : UIView

/**
 *  Line view
 *  The separtor which distinguish emoticons from other views
 */
@property(nonatomic, strong) UIView *lineView;

/**
 *  The collectionView of emoticon view
 *  Contains multiple lines of expressions, and cooperates with faceFlowLayout for flexible and unified view layout.
 */
@property(nonatomic, strong) UICollectionView *faceCollectionView;

/**
 *  The flow layout of @faceCollectionView
 *  Cooperating with faceCollectionView to make the expression view more beautiful. Supported setting layout direction, line spacing, cell spacing, etc.
 */
@property(nonatomic, strong) UICollectionViewFlowLayout *faceFlowLayout;

/**
 *  Page control
 *  It is used to realize multi-page browsing of emoticons, can slide to switch emoticon pages, and display the total number of pages and the current number of
 * pages in the form of small dots below the emoticon page.
 */
@property(nonatomic, strong) UIPageControl *pageControl;

/**
 *  The data of @faceView
 *  The object stored in this NSMutableArray is TUIFaceGroup, that is, the expression group.
 */
@property(nonatomic, strong, readonly) NSMutableArray *faceGroups;
@property(nonatomic, strong, readonly) NSMutableArray *sectionIndexInGroup;
@property(nonatomic, strong, readonly) NSMutableArray *pageCountInGroup;
@property(nonatomic, strong, readonly) NSMutableArray *groupIndexInSection;
@property(nonatomic, strong, readonly) NSMutableDictionary *itemIndexs;

/**
 *  Delegate variable, delegated
 *  Need to implement the functionality required in the @TUIFaceViewDelegate protocol.
 */
@property(nonatomic, weak) id<TUIFaceViewDelegate> delegate;

/**
 *  Swipe to the specified expression group.
 *  Switch the emoticon group according to the subscript of the emoticon group clicked by the user.
 *
 *  @param index The index of the destination group, starting from 0.
 */
- (void)scrollToFaceGroupIndex:(NSInteger)index;

/**
 *  Setting data
 *  Used to initialize TUIFaceView or update data in faceView when needed.
 *
 *  @param data The data that needs to be set (TUIFaceGroup). The object stored in this NSMutableArray is TUIFaceGroup, that is, the emoticon group.
 */
- (void)setData:(NSMutableArray *)data;
@end
