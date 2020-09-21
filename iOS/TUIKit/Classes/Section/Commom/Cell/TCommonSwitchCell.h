//
//  TCommonSwitchCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import <UIKit/UIKit.h>
#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCommonSwitchCellData : TCommonCellData

@property NSString *title;
@property (getter=isOn) BOOL on;
@property CGFloat margin;
@property SEL cswitchSelector;

@end

@interface TCommonSwitchCell : TCommonTableViewCell
@property UILabel *titleLabel;
@property UISwitch *switcher;

@property (readonly) TCommonSwitchCellData *switchData;

- (void)fillWithData:(TCommonSwitchCellData *)data;

@end

NS_ASSUME_NONNULL_END
