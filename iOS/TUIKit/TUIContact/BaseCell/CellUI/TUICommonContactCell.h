//
//  TUICommonContactCell.h
//
//
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.


#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TUICommonContactCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUICommonContactCell : TUICommonTableViewCell

@property UIImageView *avatarView;
@property UILabel *titleLabel;

// The icon of indicating the user's online status
@property(nonatomic, strong) UIImageView *onlineStatusIcon;

@property(readonly) TUICommonContactCellData *contactData;

- (void)fillWithData:(TUICommonContactCellData *)contactData;

@end

NS_ASSUME_NONNULL_END
