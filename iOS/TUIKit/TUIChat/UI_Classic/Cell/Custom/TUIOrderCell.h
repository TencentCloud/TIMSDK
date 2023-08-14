//
//  TUIOrderCell.h
//  TUIChat
//
//  Created by xia on 2022/6/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIBubbleMessageCell.h>
#import "TUIOrderCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIOrderCell : TUIBubbleMessageCell

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *priceLabel;
@property(nonatomic, strong) TUIOrderCellData *customData;

- (void)fillWithData:(TUIOrderCellData *)data;

@end

NS_ASSUME_NONNULL_END
