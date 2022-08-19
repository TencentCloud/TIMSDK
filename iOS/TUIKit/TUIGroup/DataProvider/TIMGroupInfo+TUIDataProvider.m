
#import "TIMGroupInfo+TUIDataProvider.h"
#import "TUIGlobalization.h"

@implementation V2TIMGroupInfo(TUIDataProvider)

- (BOOL)isMeOwner {
    return [self.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] || (self.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN);
}

- (BOOL)isPrivate{
    return [self.groupType isEqualToString:@"Work"];
}

- (BOOL)canInviteMember{
    if([self.groupType isEqualToString:@"Work"] || [self.groupType isEqualToString:@"Community"] || [self.groupType isEqualToString:@"Private"]){
        return YES;
    }
    return NO;
}

- (BOOL)canRemoveMember{
    return [self isMeOwner] && (self.memberCount > 1);
}

- (BOOL)canDelete{
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
