
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TUICommonPendencyCell_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【Module name】The interface that displays the received friend request (TUINewFriendViewController)
 * 【Function description】Responsible for pulling friend application information and displaying it in the interface.
 *  Through this interface, you can view the friend requests you have received, and perform the operations of agreeing/rejecting the application.
 */
@interface TUINewFriendViewController_Minimalist : UIViewController

@property(nonatomic) void (^cellClickBlock)(TUICommonPendencyCell_Minimalist *cell);

@end

NS_ASSUME_NONNULL_END
