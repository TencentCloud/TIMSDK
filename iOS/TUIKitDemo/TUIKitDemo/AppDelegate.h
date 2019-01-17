//
//  AppDelegate.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTabBarController.h"
#import "LoginController.h"

#define Key_UserInfo_User @"Key_UserInfo_User"
#define Key_UserInfo_Pwd @"Key_UserInfo_Pwd"
#define Key_UserInfo_Sig @"Key_UserInfo_Sig"

#define sdkAppid          1400178259
#define sdkAccountType    @"36862"

#define identifier1 @"user1"
#define userSig1    @"eJxlj01PhDAURff8CtK10VJaAZNZgBKdDDijkPixIZUWaFAopeCo8b*rOIlNfNtzbu59H5Zt2yBPsmNalv3U6UK-SQ7sMxtAcPQHpRSsoLpwFfsH*V4KxQtaaa4W6BBCEISmIxjvtKjEwZhGrhwDj6wtlo7fPIbQ8XxEAlMR9QLT*OZ8Ha1xf50S*Z69Pj6F5dSgRG79DOKrzQ5vk4u58aqYt95lTkMRwVQN7anv0zZ*DjJdwXtORjzUt7Nbn4Rd0DxEmg35-m4TrlZGpRYv-PAQ9gj5XuUbdOZqFH23CAg6xEEu-DlgfVpfwJVcdw__"

#define identifier2 @"user2"
#define userSig2    @"eJxlz01rg0AQgOG7v0K8ppR1142m0EOyzcHmox9pk-S0LDqJg9as6xqU0P9eagMVOtfnHYa5OK7rem-Lza1KklNTWmk7DZ5753rEu-lDrTGVykpm0n8IrUYDUh0smB59zjklZNhgCqXFA16LpgZDB1ynuexv-O4HhPhhRPlkmOCxx9X8XcQPYiz2mlerRxAfEeMbU0ySDJ-iZYV5pVhXruNzUxW55lOcT7OgJTvWliraZ83MhrNtshs-r19H9RYXoyLTAjry0i0UHO8HJy1*wvWhIOQ8IJQN9AymxlPZB5T43KeM-IznfDnfP41dnA__"

#define identifier3 @"user3"
#define userSig3    @"eJxlz11PgzAUgOF7fkXDtTHloxS9m91UIi5jH*CuCBvtPE5YaTtkGv*7kS2RxHP7vCcn58tCCNnLeHFdbLeHY21yc5LcRrfIxvbVH0oJZV6Y3FPlP*SdBMXzQhiuenQIIS7GwwZKXhsQcCmOmitvwLrc5-2N876PsUNDl9wME9j1*DxZsyhhT1pM6jvGVLZmyZJUwSkOx*8l3rSbrpW6hfF9mi2qJtEf0eto5kwrKrtotZrFIks7SvbB59R7eAlg3oSpemS7RkEYdeJtcNJAxS8P*ZQQH3t0oC1XGg51H7jYIY7r4d*xrW-rB4zSXjo_"

#define identifier4 @"user4"
#define userSig4    @"eJxlj1FPgzAUhd-5FU1fNaYwbhgme1jYiCbDQcQl*EKQlnodsFqKqRr-uxGXSOJ9-b6Tc*6nQwih*e7*qqrr09ib0rwrQck1oYxe-kGlkJeVKRea-4PCKtSirBoj9ARdAPAYmzvIRW*wwbMxDkL7MzzwYzl1-OZ9xtxg6UE4V1BOMNlm0W1c2M4wf3uImw8XbPQ8pq8bswOQo9St2j-qrkv2rd0c6jWusyPy9CFu1TIPC57lKnyqMZFd1IC4sTEv7gIT2-TlopKr1azSYCfOD-kBgM9gvvlN6AFP-SR4zAXXW7Cfo86X8w2zR15j"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
- (UIViewController *)getLoginController;
- (UITabBarController *)getMainController;
@end

