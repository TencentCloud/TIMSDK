//
//  TUIGroupMemberTableViewCell_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//

#import "TUICommonModel.h"
#import "TUIGroupMemberCellData_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupMemberTableViewCell_Minimalist : TUICommonTableViewCell
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *separtorView;

- (void)fillWithData:(TUIGroupMemberCellData_Minimalist *)data;
@end

NS_ASSUME_NONNULL_END
