

#ifndef TUIGroupInfoDataProviderServiceProtocol_h
#define TUIGroupInfoDataProviderServiceProtocol_h

#import "TCServiceProtocol.h"
@import UIKit;
#import "THeader.h"


@protocol TUIGroupInfoDataProviderServiceProtocol <NSObject>

-(NSString *) getGroupName:(V2TIMGroupInfo *) groupInfo;

-(NSString *) getGroupID:(V2TIMGroupInfo *) groupInfo;

-(NSString *) getGroupOwner:(V2TIMGroupInfo *) groupInfo;

-(NSString *) getNotification:(V2TIMGroupInfo *) groupInfo;

-(NSString *) getIntroduction:(V2TIMGroupInfo *) groupInfo;

-(NSString *) getGroupType:(V2TIMGroupInfo *) groupInfo;

-(uint32_t) getMemberNumber:(V2TIMGroupInfo *) groupInfo;

-(uint32_t) getMaxMemberNumber:(V2TIMGroupInfo *) groupInfo;

-(NSString *) getAddOption:(V2TIMGroupAddOpt) option;

/*
-(BOOL) isMeOwner:(TIMGroupInfo *) groupInfo;

-(BOOL) isPrivate:(TIMGroupInfo *) groupInfo;

-(BOOL) canInviteMember:(TIMGroupInfo *) groupInfo;

-(BOOL) canRemoveMember:(TIMGroupInfo *) groupInfo;

-(BOOL) canDelete:(TIMGroupInfo *) groupInfo;
*/

@end
#endif /* TUIGroupInfoDataProviderServiceProtocol_h */
