
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 * This file mainly declares the controller class that jumps to the read member list after clicking the read label of the group chat message
 *
 * The TUIMessageReadSelectView class defines a tab-like view in the read list. Currently only used in TUIMessageReadViewController.
 * TUIMessageReadSelectViewDelegate Callback for clicked view event. Currently implemented by TUIMessageReadViewController to switch between read and unread
 * lists.
 *
 * The TUIMessageReadViewController class implements the UI and logic for the read member list.
 * TUIMessageReadViewControllerDelegate callback click member list cell event.
 */

#import <TIMCommon/TUIMessageCellData.h>
#import <UIKit/UIKit.h>
#import "TUIChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIMessageReadSelectView;
@protocol TUIMessageReadSelectViewDelegate <NSObject>
@optional
- (void)messageReadSelectView:(TUIMessageReadSelectView *)view didSelectItemTag:(TUIMessageReadViewTag)tag;
@end

@interface TUIMessageReadSelectView : UIView
@property(nonatomic, weak) id<TUIMessageReadSelectViewDelegate> delegate;
@property(nonatomic, assign) BOOL selected;

- (instancetype)initWithTitle:(NSString *)title viewTag:(TUIMessageReadViewTag)tag selected:(BOOL)selected;

@end

@class TUIMessageDataProvider;
@interface TUIMessageReadViewController : UIViewController
@property(copy, nonatomic) void (^viewWillDismissHandler)(void);

- (instancetype)initWithCellData:(TUIMessageCellData *)data
                    dataProvider:(TUIMessageDataProvider *)dataProvider
           showReadStatusDisable:(BOOL)showReadStatusDisable
                 c2cReceiverName:(NSString *)name
               c2cReceiverAvatar:(NSString *)avatarUrl;
@end

NS_ASSUME_NONNULL_END
