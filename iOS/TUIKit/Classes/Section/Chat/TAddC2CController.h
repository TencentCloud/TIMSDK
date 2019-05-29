//
//  TAddC2CController.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAddIndexView.h"

@class TAddC2CController;
@protocol TAddC2CControllerDelegate <NSObject>
- (void)didCancelInAddC2CController:(TAddC2CController *)controller;
- (void)addC2CController:(TAddC2CController *)controller didCreateChat:(NSString *)user;
@end

@interface TAddC2CController : UIViewController
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TAddIndexView *indexView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, weak) id<TAddC2CControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *data;
@end
