
#import <UIKit/UIKit.h>
#import "TUIContactViewDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIContactControllerListener_Minimalist <NSObject>
@optional
- (void)onSelectFriend:(TUICommonContactCell *)cell;
- (void)onAddNewFriend:(TUICommonTableViewCell *)cell;
- (void)onGroupConversation:(TUICommonTableViewCell *)cell;
@end

@interface TUIContactController_Minimalist : UIViewController

@property (nonatomic, strong) TUIContactViewDataProvider *viewModel;
@property (nonatomic, weak) id<TUIContactControllerListener_Minimalist> delegate;
@property UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
