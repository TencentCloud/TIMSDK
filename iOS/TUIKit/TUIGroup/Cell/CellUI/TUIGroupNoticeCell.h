//
//  TUIGroupNoticeCell.h
//  TUIGroup
//
//  Created by harvy on 2022/1/11.
//

#import <UIKit/UIKit.h>
#import "TUIGroupNoticeCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupNoticeCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) TUIGroupNoticeCellData *cellData;

@end

NS_ASSUME_NONNULL_END
