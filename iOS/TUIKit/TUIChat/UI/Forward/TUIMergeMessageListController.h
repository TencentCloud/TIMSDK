//
//  TUIMergeMessageListController.h
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import <UIKit/UIKit.h>
#import "TUIDefine.h"
#import "TUIBaseMessageControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMergeMessageListController : UITableViewController

@property (nonatomic, weak) id<TUIBaseMessageControllerDelegate> delegate;
@property (nonatomic, strong) V2TIMMergerElem *mergerElem;
@property (nonatomic, copy) dispatch_block_t willCloseCallback;

@end

NS_ASSUME_NONNULL_END
