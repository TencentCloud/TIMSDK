
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This file declares the components used to implement the emoji menu view.
 *  The emoji menu view, the bright white view at the bottom of the emoji view, is responsible for displaying individual emoji groups and their thumbnails, and
 * providing a "Send" button.
 *
 *  The TUIMenuViewDelegate protocol provides the emoticon menu view with event callbacks for sending messages and cell selection.
 *  The TUIMenuView class, the "ontology" of the emoticon menu view, is responsible for displaying it in the form of a view in the UI, and at the same time
 * serving as a "container" for each component. You can switch between different groups of emoticons or send emoticons through the emoticon menu view.
 */
#import <UIKit/UIKit.h>
#import "TUIMenuCellData.h"

@class TUIMenuView;

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIMenuViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIMenuViewDelegate <NSObject>

/**
 *  Callback after clicking on a specific menuCell
 *  You can use this callback to achieve: in response to the user's click, switch to the corresponding emoticon group view according to the menuCell selected by
 * the user.
 */
- (void)menuView:(TUIMenuView *)menuView didSelectItemAtIndex:(NSInteger)index;

/**
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

@property(nonatomic, strong) UICollectionView *menuCollectionView;

@property(nonatomic, strong) UICollectionViewFlowLayout *menuFlowLayout;

@property(nonatomic, weak) id<TUIMenuViewDelegate> delegate;

- (void)scrollToMenuIndex:(NSInteger)index;

- (void)setData:(NSMutableArray<TUIMenuCellData *> *)data;

@end
