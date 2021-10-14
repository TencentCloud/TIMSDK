
#import "TIMGroupInfo+TUIDataProvider.h"
#import "TUIGlobalization.h"

@implementation V2TIMGroupInfo(TUIDataProvider)

-(BOOL)isMeOwner {  // 已移入TUIGroupInfoDataProvider中, 待删除
    return [self.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] || (self.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN);
}

-(BOOL) isPrivate{
    return [self.groupType isEqualToString:@"Work"];
}

-(BOOL) canInviteMember{
    if([self.groupType isEqualToString:@"Work"]){
        return YES;
    }
    else if([self.groupType isEqualToString:@"Public"]){
        return NO;
    }
    else if([self.groupType isEqualToString:@"Meeting"]){
        return NO;
    }
    return NO;
}

-(BOOL) canRemoveMember{
    return [self isMeOwner] && (self.memberCount > 1);
}

-(BOOL) canDelete{
    if([self isPrivate]){
        return NO;
    }
    else{
        if([self isMeOwner]){
            return YES;
        }
        else{
            return NO;
        }
    }
}

@end
