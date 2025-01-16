//
//  TUIGroupMemberTableViewCell_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TUICommonGroupInfoCellData_Minimalist.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupMemberTableViewCell_Minimalist : TUICommonTableViewCell
@property(nonatomic, strong) UIImageView *avatarView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *detailLabel;
@property(nonatomic, strong) UIView *separtorView;
@property (nonatomic, copy) void (^tapAction)(void); 

- (void)fillWithData:(TUIGroupMemberCellData_Minimalist *)data;
@end

NS_ASSUME_NONNULL_END
