//
//  TUIFindContactCell_Minimalist.h
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//

#import <UIKit/UIKit.h>
#import "TUIFindContactCellModel_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIFindContactCell_Minimalist : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) TUIFindContactCellModel_Minimalist *data;

@end

NS_ASSUME_NONNULL_END
