//
//  TUIMessageReadViewController_Minimalist.h
//  TUIChat
//
//  Created by xia on 2022/3/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIMessageCellData.h>
#import <TIMCommon/TUIMessageCell_Minimalist.h>
#import <UIKit/UIKit.h>
#import "TUIChatDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIMessageDataProvider;

@interface TUIMessageReadViewController_Minimalist : UIViewController
@property(nonatomic, strong) Class alertCellClass;
@property(nonatomic, strong) TUIMessageCellData *alertViewCellData;
@property(nonatomic, assign) CGRect originFrame;

@property(copy, nonatomic) void (^viewWillShowHandler)(TUIMessageCell *alertView);
@property(copy, nonatomic) void (^viewDidShowHandler)(TUIMessageCell *alertView);
@property(copy, nonatomic) void (^viewWillDismissHandler)(TUIMessageCell *alertView);

- (instancetype)initWithCellData:(TUIMessageCellData *)data
                    dataProvider:(TUIMessageDataProvider *)dataProvider
           showReadStatusDisable:(BOOL)showReadStatusDisable
                 c2cReceiverName:(NSString *)name
               c2cReceiverAvatar:(NSString *)avatarUrl;
@end

NS_ASSUME_NONNULL_END
