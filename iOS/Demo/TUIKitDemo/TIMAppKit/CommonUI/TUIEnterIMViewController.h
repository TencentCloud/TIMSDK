//
//  TUIEnterIMViewController.h
//  TUIKitDemo
//
//  Created by lynxzhang on 2022/2/9.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DefaultVC) {
    DefaultVC_Conversation,
    DefaultVC_Contact,
    DefaultVC_Setting,
};

@interface TUIEnterIMViewController : UIViewController
@property (nonatomic, assign) DefaultVC defaultVC;
@end

NS_ASSUME_NONNULL_END
