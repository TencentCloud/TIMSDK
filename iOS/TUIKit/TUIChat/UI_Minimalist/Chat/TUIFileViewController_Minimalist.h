//
//  FileViewController.h
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/11/12.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIFileMessageCell_Minimalist.h"

@interface TUIFileViewController_Minimalist : UIViewController
@property(nonatomic, strong) TUIFileMessageCellData *data;
@property(nonatomic, copy) void (^dismissClickCallback)(void);

@end
