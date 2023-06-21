
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TUIContactSelectViewDataProvider_Minimalist.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^ContactSelectFinishBlock_Minimalist)(NSArray<TUICommonContactSelectCellData_Minimalist *> *_Nonnull selectArray);

@interface TUIContactSelectController_Minimalist : UIViewController

@property(nonatomic, strong, readonly) NSMutableArray<TUICommonContactSelectCellData_Minimalist *> *selectArray;

@property(nonatomic, strong, nullable) TUIContactSelectViewDataProvider_Minimalist *viewModel;

/**
 * 选择结束回调
 * Callback for contact selection end
 */
@property(nonatomic, copy, nullable) ContactSelectFinishBlock_Minimalist finishBlock;

/**
 * 最多选择个数，默认值为 0 表示不限制
 * Maximum number of selected contacts, defalut value is 0 which means no limit
 */
@property(nonatomic, assign) NSInteger maxSelectCount;

/**
 * 自定义的数据列表
 * List of pre-selected users
 */
@property(nonatomic, strong, nullable) NSArray *sourceIds;

/**
 * 需要禁用的数据列表
 * List of pre-banned users
 */
@property(nonatomic, strong, nullable) NSArray *disableIds;

/**
 * Display name for sourceIds or disableIds
 */
@property(nonatomic, strong, nullable) NSDictionary *displayNames;

/**
 * Navigation title for view controller
 */
@property(nonatomic, copy, nullable) NSString *title;

- (void)finishTask;
@end

NS_ASSUME_NONNULL_END
