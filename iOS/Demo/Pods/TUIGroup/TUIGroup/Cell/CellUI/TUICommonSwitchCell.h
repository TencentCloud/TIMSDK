//
//  TUICommonSwitchCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/10.
//

#import <UIKit/UIKit.h>
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonSwitchCellData : TUICommonCellData

@property NSString *title;
@property (getter=isOn) BOOL on;
@property CGFloat margin;
@property SEL cswitchSelector;

@end

@interface TUICommonSwitchCell : TUICommonTableViewCell
@property UILabel *titleLabel;
@property UISwitch *switcher;

@property (readonly) TUICommonSwitchCellData *switchData;

- (void)fillWithData:(TUICommonSwitchCellData *)data;

@end

NS_ASSUME_NONNULL_END
