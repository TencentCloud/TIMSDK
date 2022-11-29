
#import <UIKit/UIKit.h>

@class TUIGroupInfoController_Minimalist;
@class TUIGroupMemberCellData;
@class V2TIMGroupInfo;

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIGroupInfoController
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIGroupInfoController_Minimalist : UITableViewController

@property (nonatomic, strong) NSString *groupId;


- (void)updateData;
- (void)updateGroupInfo;
@end
