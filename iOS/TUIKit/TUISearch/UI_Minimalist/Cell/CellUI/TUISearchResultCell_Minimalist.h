//
//  TUISearchResultCell_Minimalist.h
//  TUISearch
//
//  Created by wyl on 2022/12/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISearchResultCell.h"
@class TUISearchResultCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUISearchResultCell_Minimalist : UITableViewCell
@property(nonatomic, strong) UIImageView *avatarView;
@property(nonatomic, strong) UILabel *title_label;

- (void)fillWithData:(TUISearchResultCellModel *)cellModel;

@end

NS_ASSUME_NONNULL_END
