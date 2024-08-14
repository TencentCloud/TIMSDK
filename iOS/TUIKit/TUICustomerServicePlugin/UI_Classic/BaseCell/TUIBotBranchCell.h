//
//  TUIBotBranchCell.h
//  TUICustomerServicePlugin
//
//  Created by lynx on 2023/10/30.
//

#import <TIMCommon/TUIBubbleMessageCell.h>
#import "TUIBotBranchCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIBotBranchItemCell : UITableViewCell
@property (nonatomic, assign) BranchMsgSubType subType;
@property (nonatomic, strong) UIImageView *topLine;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@interface TUIBotBranchCell : TUIBubbleMessageCell
@property (nonatomic, strong) UIImageView *headerBkView;
@property (nonatomic, strong) UIImageView *headerDotView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *headerRefreshBtn;
@property (nonatomic, strong) UIImageView *headerRefreshView;
@property (nonatomic, strong) UITableView *itemsTableView;

- (void)fillWithData:(TUIBotBranchCellData *)data;

@property (nonatomic, strong) TUIBotBranchCellData *customData;

@end

NS_ASSUME_NONNULL_END
