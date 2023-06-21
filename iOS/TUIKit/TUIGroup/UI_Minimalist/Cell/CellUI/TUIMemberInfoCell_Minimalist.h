//
//  TUIMemberInfoCell_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIMemberInfoCellData_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIMemberInfoCell_Minimalist : UITableViewCell
@property(nonatomic, strong) UIImageView *avatarImageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) TUIMemberInfoCellData_Minimalist *data;

@end

NS_ASSUME_NONNULL_END
