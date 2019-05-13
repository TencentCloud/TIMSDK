//
//  TAddGroupController.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAddIndexView.h"
#import "TAddGroupOptionView.h"

typedef NS_ENUM(NSInteger,AddGroupType){
    AddGroupType_Create,
    AddGroupType_Join,
};

@class TAddGroupController;
@protocol TAddGroupControllerDelegate <NSObject>
- (void)didCancelInAddGroupController:(TAddGroupController *)controller;
- (void)addGroupController:(TAddGroupController *)controller didCreateGroupId:(NSString *)groupId groupName:(NSString *)groupName;
- (void)addGroupController:(TAddGroupController *)controller didCreateGroupIdFailed:(int)errorCode errorMsg:(NSString *)errorMsg;
- (void)addGroupController:(TAddGroupController *)controller didJoinGroupId:(NSString *)groupId;
- (void)addGroupController:(TAddGroupController *)controller didJoinGroupIdFailed:(int)errorCode errorMsg:(NSString *)errorMsg;
@end

@interface TAddGroupController : UIViewController
@property (nonatomic, assign) AddGroupType addGroupType;
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
