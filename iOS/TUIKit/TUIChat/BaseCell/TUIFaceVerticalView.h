//
//  TUIFaceVerticalView.h
//  TUIChat
//
//  Created by wyl on 2023/11/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIFaceView.h"
@class TUIFaceVerticalView;
@protocol TUIFaceVerticalViewDelegate <TUIFaceViewDelegate>
- (void)faceViewClickSendMessageBtn;
@end

@interface TUIFaceVerticalView : UIView

/**
 *  线视图
 *  视图中的分界线，区分表情和其他视图。
 *
 *  Line view
 *  The separtor which distinguish emoticons from other views
 */
@property(nonatomic, strong) UIView *lineView;

/**
 *  表情视图的 CollectionView
 *  包含多行表情，并配合 faceFlowLayout 进行灵活统一的视图布局。
 *
 *  The collectionView of emoticon view
 *  Contains multiple lines of expressions, and cooperates with faceFlowLayout for flexible and unified view layout.
 */
@property(nonatomic, strong) UICollectionView *faceCollectionView;

/**
 *  faceCollectionView 的流水布局
 *  配合 faceCollectionView，使表情视图更加美观。支持设置布局方向、行间距、cell 间距等。
 *
 *  The flow layout of @faceCollectionView
 *  Cooperating with faceCollectionView to make the expression view more beautiful. Supported setting layout direction, line spacing, cell spacing, etc.
 */
@property(nonatomic, strong) UICollectionViewFlowLayout *faceFlowLayout;

/**
 *
 *  faceView 中的数据。
 *  在此 NSMutableArray 中存放的对象为 TUIFaceGroup，即表情组。
 *
 *  The data of @faceView
 *  The object stored in this NSMutableArray is TUIFaceGroup, that is, the expression group.
 */
@property(nonatomic, strong, readonly) NSMutableArray *faceGroups;
@property(nonatomic, strong, readonly) NSMutableArray *sectionIndexInGroup;
@property(nonatomic, strong, readonly) NSMutableArray *groupIndexInSection;
@property(nonatomic, strong, readonly) NSMutableDictionary *itemIndexs;
@property(nonatomic, strong, readonly) UIView *floatCtrlView;

/**
 *  委托变量，被委托者
 *  需要实现 TUIFaceVerticalViewDelegate 协议中要求的功能。
 *
 *  Delegate variable, delegated
 *  Need to implement the functionality required in the @TUIFaceVerticalViewDelegate protocol.
 */
@property(nonatomic, weak) id<TUIFaceVerticalViewDelegate> delegate;

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

- (void)setFloatCtrlViewAllowSendSwitch:(BOOL)isAllow;
@end
