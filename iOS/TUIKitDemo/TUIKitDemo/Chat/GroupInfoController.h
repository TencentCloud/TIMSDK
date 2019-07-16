//
//  GroupInfoController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 群组信息视图
 *  本文件实现了群组信息的展示页面
 *
 *  您可以通过此界面查看特定群组的信息，包括群名称、群成员、群类型等
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import <UIKit/UIKit.h>
#import "TUIGroupInfoController.h"

@interface GroupInfoController : UIViewController
@property (nonatomic, strong) NSString *groupId;
@end
