//
//  TUICustomerServicePluginCardCell.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import <TIMCommon/TUIBubbleMessageCell.h>
#import "TUICustomerServicePluginCardCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginCardCell : TUIBubbleMessageCell

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *picView;

- (void)fillWithData:(TUICustomerServicePluginCardCellData *)data;

@property (nonatomic, strong) TUICustomerServicePluginCardCellData *customData;

@end

NS_ASSUME_NONNULL_END
