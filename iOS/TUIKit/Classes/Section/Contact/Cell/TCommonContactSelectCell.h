//
//  TCommonContactSelectCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//

#import "TCommonCell.h"
#import "TCommonContactSelectCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCommonContactSelectCell : TCommonTableViewCell

@property UIButton *selectButton;
@property UIImageView *avatarView;
@property UILabel *titleLabel;

@property (readonly) TCommonContactSelectCellData *selectData;

- (void)fillWithData:(TCommonContactSelectCellData *)selectData;

@end

NS_ASSUME_NONNULL_END
