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
 *
 *  Delegate variable, delegated
 *  Need to implement the functionality required in the @TUIFaceVerticalViewDelegate protocol.
 */
@property(nonatomic, weak) id<TUIFaceVerticalViewDelegate> delegate;
 
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

- (void)setFloatCtrlViewAllowSendSwitch:(BOOL)isAllow;
@end
