//
//  TUIConversationTableView.m
//  TUIConversation
//
//  Created by xiangzhang on 2023/3/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationTableView.h"
#import <TIMCommon/TUISecondConfirm.h>
#import <TUICore/TUICore.h>
#import "TUIConversationCell.h"
#import "TUIFoldListViewController.h"

@interface TUIConversationTableView () <UITableViewDelegate, UITableViewDataSource, TUIConversationListDataProviderDelegate>
@property(nonatomic, strong) UIImageView *tipsView;
@property(nonatomic, strong) UILabel *tipsLabel;
@end

@implementation TUIConversationTableView {
    TUIConversationListBaseDataProvider *_dataProvider;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTableView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setTipsViewFrame];
}

- (void)setTableView {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = TUIConversationDynamicColor(@"conversation_bg_color", @"#FFFFFF");
    self.tableFooterView = [[UIView alloc] init];
    self.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [self registerClass:[TUIConversationCell class] forCellReuseIdentifier:gConversationCell_ReuseId];
    self.estimatedRowHeight = TConversationCell_Height;
    self.rowHeight = TConversationCell_Height;
    self.delaysContentTouches = NO;
    [self setSeparatorColor:TIMCommonDynamicColor(@"separator_color", @"#DBDBDB")];
    self.delegate = self;
    self.dataSource = self;
    [self addSubview:self.tipsView];
    [self addSubview:self.tipsLabel];
    self.disableMoreActionExtension = NO;

    [self setTipsViewFrame];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onFriendInfoChanged:) name:@"FriendInfoChangedNotification" object:nil];
}

- (void)onFriendInfoChanged:(NSNotification *)notice {
    V2TIMFriendInfo *friendInfo = notice.object;
    if (friendInfo == nil) {
        return;
    }
    for (TUIConversationCellData *cellData in self.dataProvider.conversationList) {
        if ([cellData.userID isEqualToString:friendInfo.userID]) {
            NSString *title = friendInfo.friendRemark;
            if (title.length == 0) {
                title = friendInfo.userFullInfo.nickName;
            }
            if (title.length == 0) {
                title = friendInfo.userID;
            }
            cellData.title = title;
            [self reloadData];
            break;
        }
    }
}

- (UIImageView *)tipsView {
    if (!_tipsView) {
        _tipsView = [[UIImageView alloc] init];
        _tipsView.image = TUIConversationDynamicImage(@"no_conversation_img", [UIImage imageNamed:TUIConversationImagePath(@"no_conversation")]);
        _tipsView.hidden = YES;
    }
    return _tipsView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = TIMCommonDynamicColor(@"nodata_tips_color", @"#999999");
        _tipsLabel.font = [UIFont systemFontOfSize:14.0];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}

- (void)setTipsViewFrame {
    self.tipsView.mm_width(128).mm_height(109).mm__centerX(self.mm_centerX).mm__centerY(self.mm_centerY - 60);
    self.tipsLabel.mm_width(300).mm_height(20).mm__centerX(self.mm_centerX).mm_top(self.tipsView.mm_maxY + 18);
}

- (void)updateTipsViewStatus {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (0 == self.dataProvider.conversationList.count) {
          self.tipsView.hidden = NO;
          self.tipsLabel.hidden = NO;
          self.tipsLabel.text = self.tipsMsgWhenNoConversation;
      } else {
          self.tipsView.hidden = YES;
          self.tipsLabel.hidden = YES;
      }
    });
}

- (void)setDataProvider:(TUIConversationListBaseDataProvider *)dataProvider {
    _dataProvider = dataProvider;
    if (_dataProvider) {
        _dataProvider.delegate = self;
        [_dataProvider loadNexPageConversations];
    }
}

- (TUIConversationListBaseDataProvider *)dataProvider {
    return _dataProvider;
    ;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark TUIConversationListDataProviderDelegate
- (void)insertConversationsAtIndexPaths:(NSArray *)indexPaths {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf insertConversationsAtIndexPaths:indexPaths];
        });
        return;
    }
    [UIView performWithoutAnimation:^{
      [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)reloadConversationsAtIndexPaths:(NSArray *)indexPaths {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf reloadConversationsAtIndexPaths:indexPaths];
        });
        return;
    }
    if (self.isEditing) {
        self.editing = NO;
    }
    [UIView performWithoutAnimation:^{
      [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)deleteConversationAtIndexPaths:(NSArray *)indexPaths {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf deleteConversationAtIndexPaths:indexPaths];
        });
        return;
    }
    [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadAllConversations {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf reloadAllConversations];
        });
        return;
    }
    [self reloadData];
}

- (void)updateMarkUnreadCount:(NSInteger)markUnreadCount markHideUnreadCount:(NSInteger)markHideUnreadCount {
    if (self.unreadCountChanged) {
        self.unreadCountChanged(markUnreadCount, markHideUnreadCount);
    }
}

#pragma mark - Table view data source
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.dataProvider loadNexPageConversations];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (self.convDelegate && [self.convDelegate respondsToSelector:@selector(tableViewDidScroll:)]) {
        [self.convDelegate tableViewDidScroll:offsetY];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self updateTipsViewStatus];
    return self.dataProvider.conversationList.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCellData *cellData = self.dataProvider.conversationList[indexPath.row];
    NSMutableArray *rowActions = [NSMutableArray array];

    @weakify(self);
    if (cellData.isLocalConversationFoldList) {
        UITableViewRowAction *markHideAction =
            [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                               title:TIMCommonLocalizableString(MarkHide)
                                             handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                               @strongify(self);
                                               [self.dataProvider markConversationHide:cellData];
                                               if (cellData.isLocalConversationFoldList) {
                                                   [TUIConversationListDataProvider cacheConversationFoldListSettings_HideFoldItem:YES];
                                               }
                                             }];
        markHideAction.backgroundColor = RGB(242, 147, 64);
        [rowActions addObject:markHideAction];
        return rowActions;
    }

    // Delete action
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:TIMCommonLocalizableString(Delete)
                                                                          handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                                                            @strongify(self);
                                                                            TUISecondConfirmBtnInfo *cancelBtnInfo = [[TUISecondConfirmBtnInfo alloc] init];
                                                                            cancelBtnInfo.tile = TIMCommonLocalizableString(Cancel);
                                                                            cancelBtnInfo.click = ^{
                                                                              self.editing = NO;
                                                                            };
                                                                            TUISecondConfirmBtnInfo *confirmBtnInfo = [[TUISecondConfirmBtnInfo alloc] init];
                                                                            confirmBtnInfo.tile = TIMCommonLocalizableString(Delete);
                                                                            confirmBtnInfo.click = ^{
                                                                              [self.dataProvider removeConversation:cellData];
                                                                              self.editing = NO;
                                                                            };
                                                                            [TUISecondConfirm show:TIMCommonLocalizableString(TUIKitConversationTipsDelete)
                                                                                     cancelBtnInfo:cancelBtnInfo
                                                                                    confirmBtnInfo:confirmBtnInfo];
                                                                          }];
    deleteAction.backgroundColor = RGB(242, 77, 76);
    [rowActions addObject:deleteAction];

    // MarkAsRead action
    UITableViewRowAction *markAsReadAction =
        [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                           title:(cellData.isMarkAsUnread || cellData.unreadCount > 0) ? TIMCommonLocalizableString(MarkAsRead)
                                                                                                       : TIMCommonLocalizableString(MarkAsUnRead)
                                         handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                           @strongify(self);
                                           if (cellData.isMarkAsUnread || cellData.unreadCount > 0) {
                                               [self.dataProvider markConversationAsRead:cellData];
                                               if (cellData.isLocalConversationFoldList) {
                                                   [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:NO];
                                               }
                                           } else {
                                               [self.dataProvider markConversationAsUnRead:cellData];
                                               if (cellData.isLocalConversationFoldList) {
                                                   [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:YES];
                                               }
                                           }
                                         }];
    markAsReadAction.backgroundColor = RGB(20, 122, 255);
    [rowActions addObject:markAsReadAction];

    // More action
    NSArray *moreExtensionList =
        [TUICore getExtensionList:TUICore_TUIConversationExtension_ConversationCellMoreAction_ClassicExtensionID
                            param:@{
                                TUICore_TUIConversationExtension_ConversationCellAction_ConversationIDKey : cellData.conversationID,
                                TUICore_TUIConversationExtension_ConversationCellAction_MarkListKey : cellData.conversationMarkList ?: @[],
                                TUICore_TUIConversationExtension_ConversationCellAction_GroupListKey : cellData.conversationGroupList ?: @[]
                            }];
    if (self.disableMoreActionExtension || 0 == moreExtensionList.count) {
        UITableViewRowAction *markAsHideAction =
            [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                               title:TIMCommonLocalizableString(MarkHide)
                                             handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                               @strongify(self);
                                               [self.dataProvider markConversationHide:cellData];
                                               if (cellData.isLocalConversationFoldList) {
                                                   [TUIConversationListDataProvider cacheConversationFoldListSettings_HideFoldItem:YES];
                                               }
                                             }];
        markAsHideAction.backgroundColor = RGB(242, 147, 64);
        [rowActions addObject:markAsHideAction];
    } else {
        UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                              title:TIMCommonLocalizableString(More)
                                                                            handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
                                                                              @strongify(self);
                                                                              self.editing = NO;
                                                                              [self showMoreAction:cellData extensionList:moreExtensionList];
                                                                            }];
        moreAction.backgroundColor = RGB(242, 147, 64);
        [rowActions addObject:moreAction];
    }
    return rowActions;
}

// available ios 11 +
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    TUIConversationCellData *cellData = self.dataProvider.conversationList[indexPath.row];

    // config Actions
    @weakify(self);
    if (cellData.isLocalConversationFoldList) {
        UIContextualAction *markHideAction = [UIContextualAction
            contextualActionWithStyle:UIContextualActionStyleNormal
                                title:TIMCommonLocalizableString(MarkHide)
                              handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^_Nonnull completionHandler)(BOOL)) {
                                @strongify(self);
                                [self.dataProvider markConversationHide:cellData];
                                if (cellData.isLocalConversationFoldList) {
                                    [TUIConversationListDataProvider cacheConversationFoldListSettings_HideFoldItem:YES];
                                }
                              }];
        markHideAction.backgroundColor = RGB(242, 147, 64);
        UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[ markHideAction ]];
        configuration.performsFirstActionWithFullSwipe = NO;
        return configuration;
    }

    NSMutableArray *arrayM = [NSMutableArray array];

    // Delete action
    UIContextualAction *deleteAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleNormal
                            title:TIMCommonLocalizableString(Delete)
                          handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^_Nonnull completionHandler)(BOOL)) {
                            @strongify(self);
                            TUISecondConfirmBtnInfo *cancelBtnInfo = [[TUISecondConfirmBtnInfo alloc] init];
                            cancelBtnInfo.tile = TIMCommonLocalizableString(Cancel);
                            cancelBtnInfo.click = ^{
                              self.editing = NO;
                            };
                            TUISecondConfirmBtnInfo *confirmBtnInfo = [[TUISecondConfirmBtnInfo alloc] init];
                            confirmBtnInfo.tile = TIMCommonLocalizableString(Delete);
                            confirmBtnInfo.click = ^{
                              [self.dataProvider removeConversation:cellData];
                              self.editing = NO;
                            };
                            [TUISecondConfirm show:TIMCommonLocalizableString(TUIKitConversationTipsDelete)
                                     cancelBtnInfo:cancelBtnInfo
                                    confirmBtnInfo:confirmBtnInfo];
                          }];
    deleteAction.backgroundColor = RGB(242, 77, 76);
    [arrayM addObject:deleteAction];

    // MarkAsRead action
    UIContextualAction *markAsReadAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleNormal
                            title:(cellData.isMarkAsUnread || cellData.unreadCount > 0) ? TIMCommonLocalizableString(MarkAsRead)
                                                                                        : TIMCommonLocalizableString(MarkAsUnRead)
                          handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^_Nonnull completionHandler)(BOOL)) {
                            @strongify(self);
                            if (cellData.isMarkAsUnread || cellData.unreadCount > 0) {
                                [self.dataProvider markConversationAsRead:cellData];
                                if (cellData.isLocalConversationFoldList) {
                                    [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:NO];
                                }
                            } else {
                                [self.dataProvider markConversationAsUnRead:cellData];
                                if (cellData.isLocalConversationFoldList) {
                                    [TUIConversationListDataProvider cacheConversationFoldListSettings_FoldItemIsUnread:YES];
                                }
                            }
                          }];
    markAsReadAction.backgroundColor = RGB(20, 122, 255);
    [arrayM addObject:markAsReadAction];

    // More action
    NSArray *moreExtensionList =
        [TUICore getExtensionList:TUICore_TUIConversationExtension_ConversationCellMoreAction_ClassicExtensionID
                            param:@{
                                TUICore_TUIConversationExtension_ConversationCellAction_ConversationIDKey : cellData.conversationID,
                                TUICore_TUIConversationExtension_ConversationCellAction_MarkListKey : cellData.conversationMarkList ?: @[],
                                TUICore_TUIConversationExtension_ConversationCellAction_GroupListKey : cellData.conversationGroupList ?: @[]
                            }];
    if (self.disableMoreActionExtension || 0 == moreExtensionList.count) {
        UIContextualAction *markAsHideAction = [UIContextualAction
            contextualActionWithStyle:UIContextualActionStyleNormal
                                title:TIMCommonLocalizableString(MarkHide)
                              handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^_Nonnull completionHandler)(BOOL)) {
                                @strongify(self);
                                [self.dataProvider markConversationHide:cellData];
                                if (cellData.isLocalConversationFoldList) {
                                    [TUIConversationListDataProvider cacheConversationFoldListSettings_HideFoldItem:YES];
                                }
                              }];
        markAsHideAction.backgroundColor = RGB(242, 147, 64);
        [arrayM addObject:markAsHideAction];
    } else {
        UIContextualAction *moreAction = [UIContextualAction
            contextualActionWithStyle:UIContextualActionStyleNormal
                                title:TIMCommonLocalizableString(More)
                              handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^_Nonnull completionHandler)(BOOL)) {
                                @strongify(self);
                                self.editing = NO;
                                [self showMoreAction:cellData extensionList:moreExtensionList];
                              }];
        moreAction.backgroundColor = RGB(242, 147, 64);
        [arrayM addObject:moreAction];
    }

    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:[NSArray arrayWithArray:arrayM]];
    configuration.performsFirstActionWithFullSwipe = NO;
    return configuration;
}

// MARK: action
- (void)showMoreAction:(TUIConversationCellData *)cellData extensionList:(NSArray *)extensionList {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(MarkHide)
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                                    [strongSelf.dataProvider markConversationHide:cellData];
                                                    if (cellData.isLocalConversationFoldList) {
                                                        [TUIConversationListDataProvider cacheConversationFoldListSettings_HideFoldItem:YES];
                                                    }
                                                  }]];
    [self addCustomAction:ac cellData:cellData];
    [ac tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    if (self.convDelegate && [self.convDelegate respondsToSelector:@selector(tableViewDidShowAlert:)]) {
        [self.convDelegate tableViewDidShowAlert:ac];
    }
}

- (void)addCustomAction:(UIAlertController *)ac cellData:(TUIConversationCellData *)cellData {
    NSArray *extensionList =
        [TUICore getExtensionList:TUICore_TUIConversationExtension_ConversationCellMoreAction_ClassicExtensionID
                            param:@{
                                TUICore_TUIConversationExtension_ConversationCellAction_ConversationIDKey : cellData.conversationID,
                                TUICore_TUIConversationExtension_ConversationCellAction_MarkListKey : cellData.conversationMarkList ?: @[],
                                TUICore_TUIConversationExtension_ConversationCellAction_GroupListKey : cellData.conversationGroupList ?: @[]
                            }];
    for (TUIExtensionInfo *info in extensionList) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:info.text
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                         info.onClicked(@{});
                                                       }];
        [ac tuitheme_addAction:action];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:gConversationCell_ReuseId forIndexPath:indexPath];
    if (cell && indexPath.row < self.dataProvider.conversationList.count) {
        TUIConversationCellData *data = [self.dataProvider.conversationList objectAtIndex:indexPath.row];
        [self tableViewFillCell:cell withData:data];

        NSArray *extensionList =
            [TUICore getExtensionList:TUICore_TUIConversationExtension_ConversationCellUpperRightCorner_ClassicExtensionID
                                param:@{
                                    TUICore_TUIConversationExtension_ConversationCellUpperRightCorner_GroupListKey : data.conversationGroupList ?: @[],
                                    TUICore_TUIConversationExtension_ConversationCellUpperRightCorner_MarkListKey : data.conversationMarkList ?: @[],
                                }];
        if (extensionList.count > 0) {
            TUIExtensionInfo *info = extensionList.firstObject;
            if (info.text.length > 0) {
                cell.timeLabel.text = info.text;
            } else if (info.icon) {
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.image = info.icon;
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                cell.timeLabel.attributedText = imageStr;
            }
        }
    }
    return cell;
}

- (void)tableViewFillCell:(TUIConversationCell *)cell withData:(TUIConversationCellData *)data {
    [cell fillWithData:data];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCellData *data = [self.dataProvider.conversationList objectAtIndex:indexPath.row];
    [self tableViewDidSelectCell:data];
}

- (void)tableViewDidSelectCell:(TUIConversationCellData *)data {
    if (self.convDelegate && [self.convDelegate respondsToSelector:@selector(tableViewDidSelectCell:)]) {
        [self.convDelegate tableViewDidSelectCell:data];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Turn on or off the length of the last line of dividers by controlling this switch
    BOOL needLastLineFromZeroToMax = NO;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
        if (needLastLineFromZeroToMax && indexPath.row == (self.dataProvider.conversationList.count - 1)) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if (needLastLineFromZeroToMax && [cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if (needLastLineFromZeroToMax && [cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
