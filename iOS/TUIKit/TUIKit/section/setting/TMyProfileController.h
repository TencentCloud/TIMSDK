//
//  TMyProfileController.h
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIMFriendshipManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface TMyProfileController : UITableViewController
@property (readonly) TIMUserProfile *inProfile;
@property NSString *identifier;
@end

NS_ASSUME_NONNULL_END
