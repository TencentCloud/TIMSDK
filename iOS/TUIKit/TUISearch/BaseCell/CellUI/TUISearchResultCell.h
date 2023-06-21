//
//  TUISearchResultCell.h
//  Pods
//
//  Created by harvy on 2020/12/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TUISearchResultCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUISearchResultCell : UITableViewCell
@property(nonatomic, strong) UIImageView *avatarView;
@property(nonatomic, strong) UILabel *title_label;

- (void)fillWithData:(TUISearchResultCellModel *)cellModel;
@end

NS_ASSUME_NONNULL_END
