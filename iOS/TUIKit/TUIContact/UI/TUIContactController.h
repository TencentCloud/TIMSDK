
#import <UIKit/UIKit.h>
#import "TUIContactViewDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIContactControllerListener <NSObject>
@optional
- (void)onSelectFriend:(TUICommonContactCell *)cell;
- (void)onAddNewFriend:(TUICommonTableViewCell *)cell;
- (void)onGroupConversation:(TUICommonTableViewCell *)cell;
@end

@interface TUIContactController : UIViewController

@property (nonatomic, strong) TUIContactViewDataProvider *viewModel;
@property (nonatomic, weak) id<TUIContactControllerListener> delegate;
@property UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
