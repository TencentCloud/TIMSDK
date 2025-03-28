//
//  TUIReactMembersController.h
//  TUIChat
//
//  Created by wyl on 2022/10/31.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIMessageCellData.h>
#import <TUIChat/TUIChatFlexViewController.h>
#import "TUIReactModel.h"
#import "TUIReactMemberCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatMembersReactSubController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSMutableArray<TUIReactMemberCellData *> *data;

@property(nonatomic, strong) TUIMessageCellData *originData;

@property(nonatomic, copy) void (^emojiClickCallback)(TUIReactModel *model);

@end

@interface TUIReactMembersController : TUIChatFlexViewController

@property(nonatomic, strong) TUIMessageCellData *originData;

@property(nonatomic, strong) NSArray<TUIReactModel *> *tagsArray;

@end

NS_ASSUME_NONNULL_END
