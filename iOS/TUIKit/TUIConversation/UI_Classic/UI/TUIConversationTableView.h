//
//  TUIConversationTableView.h
//  TUIConversation
//
//  Created by xiangzhang on 2023/3/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIConversationCell.h"
#import "TUIConversationListControllerListener.h"
#import "TUIConversationListDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *gConversationCell_ReuseId = @"TConversationCell";

typedef void (^TUIConversationMarkUnreadCountChanged)(NSInteger markUnreadCount, NSInteger markHideUnreadCount);

@protocol TUIConversationTableViewDelegate <NSObject>
@optional
- (void)tableViewDidScroll:(CGFloat)offsetY;
- (void)tableViewDidSelectCell:(TUIConversationCellData *)data;
- (void)tableViewDidShowAlert:(UIAlertController *)ac;
@end

@interface TUIConversationTableView : UITableView
@property(nonatomic, weak) id<TUIConversationTableViewDelegate> convDelegate;
@property(nonatomic, strong) TUIConversationListBaseDataProvider *dataProvider;
@property(nonatomic, copy) TUIConversationMarkUnreadCountChanged unreadCountChanged;
@property(nonatomic, strong) NSString *tipsMsgWhenNoConversation;
@property(nonatomic, assign) BOOL disableMoreActionExtension;

- (void)tableViewDidSelectCell:(TUIConversationCellData *)data;
- (void)tableViewFillCell:(TUIConversationCell *)cell withData:(TUIConversationCellData *)data;
@end

NS_ASSUME_NONNULL_END
