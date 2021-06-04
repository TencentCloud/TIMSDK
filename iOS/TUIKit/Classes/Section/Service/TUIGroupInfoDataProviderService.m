
#import "TUIGroupInfoDataProviderService.h"
#import "TIMGroupInfo+DataProvider.h"
#import "TCServiceManager.h"
#import "NSString+TUICommon.h"
#import "TUIKit.h"
#import "NSBundle+TUIKIT.h"

@TCServiceRegister(TUIGroupInfoDataProviderServiceProtocol, TUIGroupInfoDataProviderService)

@implementation TUIGroupInfoDataProviderService

+ (BOOL)singleton
{
    return YES;
}

+ (id)shareInstance
{
    static TUIGroupInfoDataProviderService *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

-(NSString *) getGroupName:(V2TIMGroupInfo *) groupInfo{
    return groupInfo.groupName;
}

-(NSString *) getGroupID:(V2TIMGroupInfo *) groupInfo{
    return groupInfo.groupID;
}

-(NSString *) getGroupOwner:(V2TIMGroupInfo *) groupInfo{
    return groupInfo.owner;
}

-(NSString *) getNotification:(V2TIMGroupInfo *) groupInfo{
    return groupInfo.notification;
}

-(NSString *) getIntroduction:(V2TIMGroupInfo *) groupInfo{
    return groupInfo.introduction;
}

-(NSString *) getGroupType:(V2TIMGroupInfo *)groupInfo{

    if(groupInfo.groupType){
        if([groupInfo.groupType isEqualToString:@"Work"]){
            return TUILocalizableString(TUIKitWorkGroup); // @"讨论组";
        }
        else if([groupInfo.groupType isEqualToString:@"Public"]){
            return TUILocalizableString(TUIKitPublicGroup); // @"公开群";
        }
        else if([groupInfo.groupType isEqualToString:@"Meeting"]){
            return TUILocalizableString(TUIKitChatRoom); // @"聊天室";
        }
    }

    return @"";
}

-(NSString *)getAddOption:(V2TIMGroupAddOpt)option{
    switch (option) {
        case V2TIM_GROUP_ADD_FORBID:
            return TUILocalizableString(TUIKitGroupProfileJoinDisable); // @"禁止加入";
            break;
        case V2TIM_GROUP_ADD_AUTH:
            return TUILocalizableString(TUIKitGroupProfileAdminApprove); // @"管理员审批";
            break;
        case V2TIM_GROUP_ADD_ANY:
            return TUILocalizableString(TUIKitGroupProfileAutoApproval); // @"自动审批";
            break;
        default:
            break;
    }
    return @"";
}

-(uint32_t) getMemberNumber:(V2TIMGroupInfo *)groupInfo{
    return groupInfo.memberCount;
}

-(uint32_t) getMaxMemberNumber:(V2TIMGroupInfo *)groupInfo{
    return 0;
}
/*
-(BOOL) isMeOwner:(TIMGroupInfo *) groupInfo{
    return [groupInfo.owner isEqualToString:[[TIMManager sharedInstance] getLoginUser]];
}

-(BOOL) isPrivate:(TIMGroupInfo *) groupInfo{
    return [groupInfo.groupType isEqualToString:@"Private"];
}

-(BOOL) canInviteMember:(TIMGroupInfo *) groupInfo{
    if([groupInfo.groupType isEqualToString:@"Private"]){
        return YES;
    }
    else if([groupInfo.groupType isEqualToString:@"Public"]){
        return NO;
    }
    else if([groupInfo.groupType isEqualToString:@"ChatRoom"]){
        return NO;
    }
    return NO;
}

-(BOOL) canRemoveMember:(TIMGroupInfo *) groupInfo{
    return [self isMeOwner:groupInfo] && (groupInfo.memberNum > 1);
}

-(BOOL) canDelete:(TIMGroupInfo *)groupInfo{
    if([groupInfo isPrivate]){
        return NO;
    }
    else{
        if([groupInfo isMeOwner]){
            return YES;
        }
        else{
            return NO;
        }
    }
}
*/
@end
