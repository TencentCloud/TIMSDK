//
//  TAddMemberController.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAddIndexView.h"
#import "TAddCell.h"

@interface TAddMemberResult : NSObject
@property (nonatomic, assign) int code;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSArray *addMembers;
@end

@class TAddMemberController;
@protocol TAddMemberControllerDelegate <NSObject>
- (void)didCancelInAddMemberController:(TAddMemberController *)controller;
- (void)addMemberController:(TAddMemberController *)controller didAddMemberResult:(TAddMemberResult *)result;
@end

@interface TAddMemberController : UIViewController
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TAddIndexView *indexView;
@property (nonatomic, weak) id<TAddMemberControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray<TAddCellData *> *users;
@property (nonatomic, strong) NSString *groupId;
@end


