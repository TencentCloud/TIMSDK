//
//  TUIChatBotPluginBranchCell.h
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import <TIMCommon/TUIBubbleMessageCell.h>
#import "TUIChatBotPluginBranchCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatBotPluginBranchItemCell : UITableViewCell
@property (nonatomic, assign) BranchMsgSubType subType;
@property (nonatomic, strong) UIImageView *topLine;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@interface TUIChatBotPluginBranchCell : TUIBubbleMessageCell
@property (nonatomic, strong) UIImageView *headerBkView;
@property (nonatomic, strong) UIImageView *headerDotView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *headerRefreshBtn;
@property (nonatomic, strong) UIImageView *headerRefreshView;
@property (nonatomic, strong) UITableView *itemsTableView;

- (void)fillWithData:(TUIChatBotPluginBranchCellData *)data;

@property (nonatomic, strong) TUIChatBotPluginBranchCellData *customData;

@end

NS_ASSUME_NONNULL_END
