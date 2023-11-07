//
//  TUICustomerServicePluginCollectionCell.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import <TIMCommon/TUIBubbleMessageCell.h>
#import "TUICustomerServicePluginCollectionCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginCollectionItemCell : UITableViewCell

@property (nonatomic, strong) UILabel *contentLabel;

@end

@interface TUICustomerServicePluginCollectionCell : TUIBubbleMessageCell

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UITableView *itemsTableView;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIButton *confirmButton;

- (void)fillWithData:(TUICustomerServicePluginCollectionCellData *)data;

@property (nonatomic, strong) TUICustomerServicePluginCollectionCellData *customData;

@end

NS_ASSUME_NONNULL_END
