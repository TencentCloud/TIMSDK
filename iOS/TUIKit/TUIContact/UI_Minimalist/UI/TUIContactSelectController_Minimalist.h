#import <UIKit/UIKit.h>
#import "TUIDefine.h"
#import "TUIContactSelectViewDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ContactSelectFinishBlock_Minimalist)(NSArray<TUICommonContactSelectCellData *> * _Nonnull selectArray);

@interface TUIContactSelectController_Minimalist : UIViewController

@property (nonatomic, strong, nullable) TUIContactSelectViewDataProvider *viewModel;

/**
 * 选择结束回调
 * Callback for contact selection end
 */
@property (nonatomic, copy, nullable) ContactSelectFinishBlock_Minimalist finishBlock;

/**
 * 最多选择个数
 * Maximum number of selected contacts
 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/**
 * 自定义的数据列表
 * List of pre-selected users
 */
@property (nonatomic, strong, nullable) NSArray *sourceIds;

/**
 * 需要禁用的数据列表
 * List of pre-banned users
 */
@property (nonatomic, strong, nullable) NSArray *disableIds;

/**
 * Display name for sourceIds or disableIds
 */
@property (nonatomic, strong, nullable) NSDictionary *displayNames;

/**
 * Navigation title for view controller
 */
@property (nonatomic, copy, nullable) NSString *title;

@end

NS_ASSUME_NONNULL_END
