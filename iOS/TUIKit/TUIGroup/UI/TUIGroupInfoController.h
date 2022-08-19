
#import <UIKit/UIKit.h>

@class TUIGroupInfoController;
@class TUIGroupMemberCellData;
@class V2TIMGroupInfo;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIGroupInfoController
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIGroupInfoController : UITableViewController

@property (nonatomic, strong) NSString *groupId;


- (void)updateData;
- (void)updateGroupInfo;
@end
