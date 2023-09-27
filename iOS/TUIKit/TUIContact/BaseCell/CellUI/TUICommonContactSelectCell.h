//
//  TUICommonContactSelectCell.h
//
//
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonContactSelectCell : TUICommonTableViewCell

@property UIButton *selectButton;
@property UIImageView *avatarView;
@property UILabel *titleLabel;

@property(readonly) TUICommonContactSelectCellData *selectData;

- (void)fillWithData:(TUICommonContactSelectCellData *)selectData;

@end

NS_ASSUME_NONNULL_END
