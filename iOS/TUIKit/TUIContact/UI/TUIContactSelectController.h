#import <UIKit/UIKit.h>
#import "TUIDefine.h"
#import "TUIContactSelectViewDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ContactSelectFinishBlock)(NSArray<TUICommonContactSelectCellData *> * _Nonnull selectArray);

@interface TUIContactSelectController : UIViewController

@property (nonatomic) TUIContactSelectViewDataProvider * _Nullable viewModel;

/**
 * 选择结束回调
 * Callback for contact selection end
 */
@property (nonatomic, copy) ContactSelectFinishBlock _Nullable finishBlock;

/**
 * 最多选择个数
 * Maximum number of selected contacts
 */
@property NSInteger maxSelectCount;

/**
 * 自定义的数据列表
 * List of pre-selected users
 */
@property NSArray * _Nullable sourceIds;

/**
 * 需要禁用的数据列表
 * List of pre-banned users
 */
@property NSArray * _Nullable disableIds;

@end

NS_ASSUME_NONNULL_END
