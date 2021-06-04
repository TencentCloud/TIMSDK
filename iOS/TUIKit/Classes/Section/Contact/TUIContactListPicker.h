//
//  TUIContactListPicker.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/13.
//

#import <UIKit/UIKit.h>
#import "TCommonContactSelectCellData.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIContactListPickerOnCancel)(TCommonContactSelectCellData *data);

@interface TUIContactListPicker : UIControl

@property (readonly) UIButton *accessoryBtn;

@property NSArray<TCommonContactSelectCellData *> *selectArray;

// 取消选中
@property (nonatomic, copy) TUIContactListPickerOnCancel onCancel;

@end

NS_ASSUME_NONNULL_END
