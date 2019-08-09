
#import "TUIGroupInfoDataProviderService.h"
#import "TIMGroupInfo+DataProvider.h"
#import "TCServiceManager.h"
#import "NSString+Common.h"
#import "THeader.h"
#import <ImSDK/ImSDK.h>
#import "TUIKit.h"

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

-(NSString *) getGroupName:(TIMGroupInfo *) groupInfo{
    return groupInfo.groupName;
}

-(NSString *) getGroupID:(TIMGroupInfo *) groupInfo{
    return groupInfo.group;
}

-(NSString *) getGroupOwner:(TIMGroupInfo *) groupInfo{
    return groupInfo.owner;
}

-(NSString *) getNotification:(TIMGroupInfo *) groupInfo{
    return groupInfo.notification;
}

-(NSString *) getIntroduction:(TIMGroupInfo *) groupInfo{
    return groupInfo.introduction;
}

-(NSString *) getGroupType:(TIMGroupInfo *)groupInfo{

    if(groupInfo.groupType){
        if([groupInfo.groupType isEqualToString:@"Private"]){
            return @"讨论组";
        }
        else if([groupInfo.groupType isEqualToString:@"Public"]){
            return @"公开群";
        }
        else if([groupInfo.groupType isEqualToString:@"ChatRoom"]){
            return @"聊天室";
        }
    }

    return @"";
}

-(NSString *)getAddOption:(TIMGroupAddOpt)option{
    switch (option) {
        case TIM_GROUP_ADD_FORBID:
            return @"禁止加入";
            break;
        case TIM_GROUP_ADD_AUTH:
            return @"管理员审批";
            break;
        case TIM_GROUP_ADD_ANY:
            return @"自动审批";
            break;
        default:
            break;
    }
    return @"";
}

-(uint32_t) getMemberNumber:(TIMGroupInfo *)groupInfo{
    return groupInfo.memberNum;
}

-(uint32_t) getMaxMemberNumber:(TIMGroupInfo *)groupInfo{
    return groupInfo.maxMemberNum;
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
