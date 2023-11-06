//
//  TUICustomerServicePluginBranchCell.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import <TIMCommon/TUIBubbleMessageCell.h>
#import "TUICustomerServicePluginBranchCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginBranchItemCell : UITableViewCell

@property (nonatomic, strong) UIImageView *topLine;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *arrowView;

@end

@interface TUICustomerServicePluginBranchCell : TUIBubbleMessageCell

@property (nonatomic, strong) UILabel *headerLabel;
//@property (nonatomic, strong) NSMutableArray *itemButtons;
@property (nonatomic, strong) UITableView *itemsTableView;

- (void)fillWithData:(TUICustomerServicePluginBranchCellData *)data;

@property (nonatomic, strong) TUICustomerServicePluginBranchCellData *customData;

@end

NS_ASSUME_NONNULL_END
