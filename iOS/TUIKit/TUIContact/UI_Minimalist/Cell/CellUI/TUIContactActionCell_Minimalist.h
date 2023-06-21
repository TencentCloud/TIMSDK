//
//  TUIContactActionCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICommonModel.h>
#import <UIKit/UIKit.h>
#import "TUIContactActionCellData_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactActionCell_Minimalist : TUICommonTableViewCell

@property UILabel *titleLabel;
@property TUIUnReadView *unRead;

@property(readonly) TUIContactActionCellData_Minimalist *actionData;

- (void)fillWithData:(TUIContactActionCellData_Minimalist *)contactData;

@end

NS_ASSUME_NONNULL_END
