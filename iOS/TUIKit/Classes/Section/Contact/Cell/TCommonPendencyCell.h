//
//  TCommonPendencyCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TCommonCell.h"
#import "TCommonPendencyCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCommonPendencyCell : TCommonTableViewCell

@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property UILabel *addSourceLabel;
@property UILabel *addWordingLabel;
@property UIButton *agreeButton;

@property (nonatomic) TCommonPendencyCellData *pendencyData;

- (void)fillWithData:(TCommonPendencyCellData *)pendencyData;

@end

NS_ASSUME_NONNULL_END
