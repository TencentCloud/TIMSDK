//
//  LoginController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 登录界面
 *  - 本文件实现了Demo中的登录界面
 *  - 值得注意的是，实际登录模块与Demo中的登录模块有所不同。
 *  - Demo中为了方便用户体验，只需在AppDelegate.h中填用户名和usersig即可（具体获得过程请参照https://github.com/tencentyun/TIMSDK/tree/master/iOS）
 *  - 本类依赖于腾讯云 TUIKit 和 IMSDK
 *
 *  Tencent Cloud Chat Demo login interface
 *  - This file implements the login interface in the Demo.
 *  - It is worth noting that the actual login module is different from the login module in the demo.
 *  - For the convenience of user experience in Demo, you only need to fill in the username and usersig in AppDelegate.h (for details, please refer to https://github.com/tencentyun/TIMSDK/tree/master/iOS).
 *  - This class depends on Tencent Cloud TUIKit and IMSDK
 */
#import <UIKit/UIKit.h>

@interface LoginController : UIViewController

@end

