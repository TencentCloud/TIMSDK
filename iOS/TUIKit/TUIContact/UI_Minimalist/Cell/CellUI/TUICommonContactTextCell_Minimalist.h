//
//  TUIContactCommonTextCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonContactTextCellData_Minimalist : TUICommonCellData

@property NSString *key;
@property NSString *value;
@property BOOL showAccessory;
@property UIColor *keyColor;
@property UIColor *valueColor;

/**
 * Allow valueLabel to be displayed on multiple lines
 */
@property BOOL enableMultiLineValue;

@property(nonatomic, assign) UIEdgeInsets keyEdgeInsets;

@end

@interface TUICommonContactTextCell_Minimalist : TUICommonTableViewCell
@property UILabel *keyLabel;
@property UILabel *valueLabel;
@property(readonly) TUICommonContactTextCellData_Minimalist *textData;

- (void)fillWithData:(TUICommonContactTextCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
