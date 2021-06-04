//
//  TUIMergeMessageListController.h
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import <UIKit/UIKit.h>
#import "TUIKit.h"

@protocol TMessageControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface TUIMergeMessageListController : UITableViewController

@property (nonatomic, weak) id<TMessageControllerDelegate> delegate;
@property (nonatomic, strong) V2TIMMergerElem *mergerElem;
@property (nonatomic, copy) dispatch_block_t willCloseCallback;

@end

NS_ASSUME_NONNULL_END
