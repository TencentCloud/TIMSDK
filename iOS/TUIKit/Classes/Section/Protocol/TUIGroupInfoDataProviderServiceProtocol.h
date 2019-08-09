

#ifndef TUIGroupInfoDataProviderServiceProtocol_h
#define TUIGroupInfoDataProviderServiceProtocol_h

#import "TCServiceProtocol.h"
@import UIKit;
#import <ImSDK/ImSDK.h>


@protocol TUIGroupInfoDataProviderServiceProtocol <NSObject>

-(NSString *) getGroupName:(TIMGroupInfo *) groupInfo;

-(NSString *) getGroupID:(TIMGroupInfo *) groupInfo;

-(NSString *) getGroupOwner:(TIMGroupInfo *) groupInfo;

-(NSString *) getNotification:(TIMGroupInfo *) groupInfo;

-(NSString *) getIntroduction:(TIMGroupInfo *) groupInfo;

-(NSString *) getGroupType:(TIMGroupInfo *) groupInfo;

-(uint32_t) getMemberNumber:(TIMGroupInfo *) groupInfo;

-(uint32_t) getMaxMemberNumber:(TIMGroupInfo *) groupInfo;

-(NSString *) getAddOption:(TIMGroupAddOpt) option;

/*
-(BOOL) isMeOwner:(TIMGroupInfo *) groupInfo;

-(BOOL) isPrivate:(TIMGroupInfo *) groupInfo;

-(BOOL) canInviteMember:(TIMGroupInfo *) groupInfo;

-(BOOL) canRemoveMember:(TIMGroupInfo *) groupInfo;

-(BOOL) canDelete:(TIMGroupInfo *) groupInfo;
*/

@end
#endif /* TUIGroupInfoDataProviderServiceProtocol_h */
