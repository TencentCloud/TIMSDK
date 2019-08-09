//
//  GroupRequestViewController.h
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/5/20.
//  Copyright © 2019年 Tencent. All rights reserved.
//
/** 腾讯云IM Demon群组加入页面，在用户想要加入群组时提供UI
 *
 * 本文件实现了加入群组时的视图，使得使用者能够对只能群组发送申请加入的请求
 *
 * 本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import <UIKit/UIKit.h>
#import <ImSDK/ImSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupRequestViewController : UIViewController
@property TIMGroupInfo *groupInfo;
@end

NS_ASSUME_NONNULL_END
