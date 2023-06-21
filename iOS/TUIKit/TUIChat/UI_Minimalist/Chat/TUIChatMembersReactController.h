//
//  TUIChatMembersReactController.h
//  TUIChat
//
//  Created by wyl on 2022/10/31.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIMessageCellData.h>
#import <TIMCommon/TUITagsModel.h>
#import "TUIChatConversationModel.h"
#import "TUIChatFlexViewController.h"
#import "TUIEmojiCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatMembersReactSubController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSMutableArray<TUIEmojiCellData *> *data;

@property(nonatomic, strong) TUIMessageCellData *originData;

@end

@interface TUIChatMembersReactController : TUIChatFlexViewController

@property(nonatomic, strong) TUIMessageCellData *originData;

@property(nonatomic, strong) NSArray<TUITagsModel *> *tagsArray;

@property(nonatomic, strong) TUIChatConversationModel *conversationData;

- (instancetype)initWithChatConversationModel:(TUIChatConversationModel *)conversationData;
@end

NS_ASSUME_NONNULL_END
