//
//  TCommonPendencyCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import "TUICommonPendencyCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonPendencyCell : TUICommonTableViewCell

@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property UILabel *addSourceLabel;
@property UILabel *addWordingLabel;
@property UIButton *agreeButton;
@property UIButton *rejectButton;
@property UIStackView *stackView;

@property (nonatomic) TUICommonPendencyCellData *pendencyData;

- (void)fillWithData:(TUICommonPendencyCellData *)pendencyData;

@end

NS_ASSUME_NONNULL_END
