//
//  TUIContactSelectController.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//

#import <UIKit/UIKit.h>
#import "TCommonContactSelectCellData.h"
#import "TContactSelectViewModel.h"

typedef void(^ContactSelectFinishBlock)(NSArray<TCommonContactSelectCellData *> * _Nonnull selectArray);

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactSelectController : UIViewController

@property (nonatomic) TContactSelectViewModel *viewModel;

/**
 * 选择结束回调
 */
@property (nonatomic, copy) ContactSelectFinishBlock finishBlock;

/**
 * 最多选择个数
 */
@property NSInteger maxSelectCount;

@end

NS_ASSUME_NONNULL_END
