//
//  TUIMemberInfoCell.h
//  TUIGroup
//
//  Created by harvy on 2021/12/27.
//

#import <UIKit/UIKit.h>
@class TUIMemberInfoCellData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIMemberInfoCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) TUIMemberInfoCellData *data;

@end

NS_ASSUME_NONNULL_END
