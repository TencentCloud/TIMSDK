//
//  TUIGroupPinPageViewController.h
//  TUIChat
//
//  Created by Tencent on 2024/05/20.
//  Copyright © 2023 Tencent. All rights reserved.
//
#import <UIKit/UIKit.h>
@import ImSDK_Plus;
NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupPinPageViewController : UIViewController

@property(nonatomic, strong) UITableView *tableview;
@property(nonatomic, strong) UIView *customArrowView;
@property(nonatomic, strong) NSArray *groupPinList;
@property (nonatomic, copy) void(^onClickRemove)(V2TIMMessage *originMessage);
@property (nonatomic, copy) void(^onClickCellView)(V2TIMMessage *originMessage);
@property(nonatomic, assign) BOOL canRemove;
@property (nonatomic,strong) UIView *bottomShadow;
@end

NS_ASSUME_NONNULL_END
