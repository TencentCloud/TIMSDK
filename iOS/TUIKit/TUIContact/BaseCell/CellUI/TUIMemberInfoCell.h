//
//  TUIMemberInfoCell.h
//  TUIGroup
//
//  Created by harvy on 2021/12/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TUIMemberInfoCellData;

NS_ASSUME_NONNULL_BEGIN
@interface TUIMemberTagView : UIView
@property(nonatomic, strong) UILabel *tagname;
@end

@interface TUIMemberInfoCell : UITableViewCell

@property(nonatomic, strong) UIImageView *avatarImageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) TUIMemberInfoCellData *data;
@property(nonatomic, strong) TUIMemberTagView *tagView;

@end

NS_ASSUME_NONNULL_END
