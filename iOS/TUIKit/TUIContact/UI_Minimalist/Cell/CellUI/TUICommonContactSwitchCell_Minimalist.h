//
//  TUIContactCommonSwitchCell_Minimalist.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonContactSwitchCellData_Minimalist : TUICommonCellData

@property NSString *title;
@property NSString *desc;
@property(getter=isOn) BOOL on;
@property CGFloat margin;
@property SEL cswitchSelector;

@end

@interface TUICommonContactSwitchCell_Minimalist : TUICommonTableViewCell

@property UILabel *titleLabel;  // main title label
@property UILabel *descLabel;   // detail title label below the main title label, used for explaining details
@property UISwitch *switcher;

@property(readonly) TUICommonContactSwitchCellData_Minimalist *switchData;

- (void)fillWithData:(TUICommonContactSwitchCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
