//
//  TAddGroupController.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAddIndexView.h"
#import "TAddGroupOptionView.h"

@class TAddGroupController;
@protocol TAddGroupControllerDelegate <NSObject>
- (void)didCancelInAddGroupController:(TAddGroupController *)controller;
- (void)addGroupController:(TAddGroupController *)controller didCreateGroupId:(NSString *)groupId groupName:(NSString *)groupName;
@end

@interface TAddGroupController : UIViewController
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) TAddGroupOptionView *groupTypeView;
@property (nonatomic, strong) TAddGroupOptionView *groupAddOptionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TAddIndexView *indexView;
@property (nonatomic, weak) id<TAddGroupControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *data;
@end
