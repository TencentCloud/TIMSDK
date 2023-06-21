//
//  TUIFoldListViewController_Minimalist.h
//  TUIKitDemo
//
//  Created by wyl on 2022/11/4.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIFoldListViewController_Minimalist : UIViewController

@property(nonatomic, copy) void (^dismissCallback)(NSMutableAttributedString *foldStr, NSArray *sortArr, NSArray *needRemoveFromCacheMapArray);

@end

NS_ASSUME_NONNULL_END
