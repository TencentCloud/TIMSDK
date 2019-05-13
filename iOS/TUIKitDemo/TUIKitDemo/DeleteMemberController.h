//
//  DeleteMemberController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeleteMemberController : UIViewController
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, weak) UIViewController *presenter;
@end
