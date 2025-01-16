
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TUICore/TUIGlobalization.h>
#import "TIMGroupInfo+TUIDataProvider.h"

@implementation V2TIMGroupInfo (TUIDataProvider)

- (BOOL)isMeOwner {
    return [self.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] || (self.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN);
}

- (BOOL)isPrivate {
    return [self.groupType isEqualToString:@"Work"];
}

- (BOOL)canInviteMember {
    return self.groupApproveOpt != V2TIM_GROUP_ADD_FORBID;
}

- (BOOL)canRemoveMember {
    return [self isMeOwner] && (self.memberCount > 1);
}

- (BOOL)canDismissGroup {
    if ([self isPrivate]) {
        return NO;
    } else {
        if ([self.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] || (self.role == V2TIM_GROUP_MEMBER_ROLE_SUPER)) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (BOOL)canSupportSetAdmain {
    BOOL isMeSuper = [self.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] || (self.role == V2TIM_GROUP_MEMBER_ROLE_SUPER);

    BOOL isCurrentGroupTypeSupportSetAdmain = ([self.groupType isEqualToString:@"Public"] || [self.groupType isEqualToString:@"Meeting"] ||
                                               [self.groupType isEqualToString:@"Community"] || [self.groupType isEqualToString:@"Private"]);

    return isMeSuper && isCurrentGroupTypeSupportSetAdmain && (self.memberCount > 1);
}
@end
