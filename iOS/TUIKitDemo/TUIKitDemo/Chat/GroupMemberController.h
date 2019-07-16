//
//  GroupMemberController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 群成员管理视图
 *  本文件实现了群成员管理视图，在管理员进行群内人员管理时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 *
 */
#import <UIKit/UIKit.h>

@interface GroupMemberController : UIViewController
@property (nonatomic, strong) NSString *groupId;
@end
