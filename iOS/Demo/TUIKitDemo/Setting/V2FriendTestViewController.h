//
//  V2FriendTestViewController.h
//  TUIKitDemo
//
//  Created by xiangzhang on 2020/3/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface V2FriendTestViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userID;
@property (weak, nonatomic) IBOutlet UITextField *remark;
@property (weak, nonatomic) IBOutlet UITextField *customKey;
@property (weak, nonatomic) IBOutlet UITextField *customValue;
@property (weak, nonatomic) IBOutlet UITextField *addGroupUserID;
@property (weak, nonatomic) IBOutlet UITextView *eventInfo;
@end

NS_ASSUME_NONNULL_END
