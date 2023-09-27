//
//  TCommonPendencyCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import "TUICommonPendencyCellData_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonPendencyCell_Minimalist : TUICommonTableViewCell

@property(nonatomic,strong) UIImageView *avatarView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *addSourceLabel;
@property(nonatomic,strong) UILabel *addWordingLabel;
@property(nonatomic,strong) UIButton *agreeButton;
@property(nonatomic,strong) UIButton *rejectButton;
@property(nonatomic,strong) UIStackView *stackView;
@property(nonatomic,strong) TUICommonPendencyCellData_Minimalist *pendencyData;

- (void)fillWithData:(TUICommonPendencyCellData_Minimalist *)pendencyData;

@end

NS_ASSUME_NONNULL_END
