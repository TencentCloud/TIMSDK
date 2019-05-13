//
//  TDeleteMemberController.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAddIndexView.h"

@interface TDeleteMemberResult : NSObject
@property (nonatomic, assign) int code;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSArray *delMembers;
@end

@class TDeleteMemberController;
@protocol TDeleteMemberControllerDelegate <NSObject>
- (void)didCancelInDeleteMemberController:(TDeleteMemberController *)controller;
- (void)deleteMemberController:(TDeleteMemberController *)controller didDeleteMemberResult:(TDeleteMemberResult *)result;
@end

@interface TDeleteMemberController : UIViewController
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TAddIndexView *indexView;
@property (nonatomic, weak) id<TDeleteMemberControllerDelegate> delegate;
@property (nonatomic, strong) NSString *groupId;
@end

