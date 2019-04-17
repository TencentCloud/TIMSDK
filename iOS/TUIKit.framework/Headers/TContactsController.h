//
//  TContactsController.h
//  TUIKit
//
//  Created by annidyfeng on 2019/3/25.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFriendListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class TContactsController;
@protocol TContactsControllerDelegagte <NSObject>
- (void)contactsController:(TContactsController *)controller didClickRightBarButton:(UIButton *)rightBarButton;
@end

@interface TContactsController : TFriendListViewController
@property (nonatomic, weak) id<TContactsControllerDelegagte> delegate;
@end

NS_ASSUME_NONNULL_END
