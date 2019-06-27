//
//  TUIGroupPendencyCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/18.
//

#import "TCommonCell.h"
#import "TUIGroupPendencyCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupPendencyCell : TCommonTableViewCell
@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property UILabel *addWordingLabel;
@property UIButton *agreeButton;

@property TUIGroupPendencyCellData *pendencyData;

- (void)fillWithData:(TUIGroupPendencyCellData *)pendencyData;

@end

NS_ASSUME_NONNULL_END
