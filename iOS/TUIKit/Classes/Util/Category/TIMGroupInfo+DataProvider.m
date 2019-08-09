
#import "TIMGroupInfo+DataProvider.h"
#import "TCServiceManager.h"
#import "TUIGroupInfoDataProviderServiceProtocol.h"


@implementation TIMGroupInfo(DataProvider)

-(NSString *) showGroupName{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getGroupName:self];
}

-(NSString *) showGroupID{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getGroupID:self];
}

-(NSString *) showGroupOwner{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getGroupOwner:self];
}

-(NSString *) showNotification{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getNotification:self];
}

-(NSString *) showIntroduction{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getIntroduction:self];
}

-(NSString *) showGroupType{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getGroupType:self];
}

-(uint32_t) showMemberNumber{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getMemberNumber:self];
}

-(uint32_t) showMaxMemberNumber{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getMaxMemberNumber:self];
}

-(NSString *) showAddOption{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getAddOption:self.addOpt];
}

-(NSString *) showAddOption:(TIMGroupAddOpt)option{
    id<TUIGroupInfoDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIGroupInfoDataProviderServiceProtocol)];
    return [expr getAddOption:option];
}

-(BOOL) isMeOwner{
    return [self.owner isEqualToString:[[TIMManager sharedInstance] getLoginUser]];
}

-(BOOL) isPrivate{
    return [self.groupType isEqualToString:@"Private"];
}

-(BOOL) canInviteMember{
    if([self.groupType isEqualToString:@"Private"]){
        return YES;
    }
    else if([self.groupType isEqualToString:@"Public"]){
        return NO;
    }
    else if([self.groupType isEqualToString:@"ChatRoom"]){
        return NO;
    }
    return NO;
}

-(BOOL) canRemoveMember{
    return [self isMeOwner] && (self.memberNum > 1);
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
