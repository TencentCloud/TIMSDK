#import <UIKit/UIKit.h>
#import "TCommonContactSelectCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIContactListPicker : UIControl

@property (readonly) UIButton *accessoryBtn;

@property NSArray<TCommonContactSelectCellData *> *selectArray;

@end

NS_ASSUME_NONNULL_END
