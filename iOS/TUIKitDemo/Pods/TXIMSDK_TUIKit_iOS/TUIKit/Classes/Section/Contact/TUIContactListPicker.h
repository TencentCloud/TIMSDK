//
//  TUIContactListPicker.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/13.
//

#import <UIKit/UIKit.h>
#import "TCommonContactSelectCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIContactListPicker : UIControl

@property (readonly) UIButton *accessoryBtn;

@property NSArray<TCommonContactSelectCellData *> *selectArray;

@end

NS_ASSUME_NONNULL_END
