//
//  TElemDataProviderService.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import "TUIMessageDataProviderService.h"
#import "TCServiceManager.h"
@import ImSDK;

@TCServiceRegister(TUIMessageDataProviderServiceProtocol, TUIMessageDataProviderService)

@implementation TUIMessageDataProviderService

+ (BOOL)singleton
{
    return YES;
}

+ (id)shareInstance
{
    static TUIMessageDataProviderService *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (NSString *)getDisplayString:(TIMMessage *)msg
{
    NSString *str;
    if(msg.status == TIM_MSG_STATUS_LOCAL_REVOKED){
        if(msg.isSelf){
            str = @"你撤回了一条消息";
        }
        else{
            str = [NSString stringWithFormat:@"\"%@\"撤回了一条消息", msg.sender];
        }
    } else {
        for (int i = 0; i < msg.elemCount; ++i) {
            TIMElem *elem = [msg getElem:i];
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                str = text.text;
                break;
            }
            else if([elem isKindOfClass:[TIMCustomElem class]]){
                TIMCustomElem *custom = (TIMCustomElem *)elem;
                str = custom.ext;
                break;
            }
            else if([elem isKindOfClass:[TIMImageElem class]]){
                str = @"[图片]";
                break;
            }
            else if([elem isKindOfClass:[TIMSoundElem class]]){
                str = @"[语音]";
                break;
            }
            else if([elem isKindOfClass:[TIMVideoElem class]]){
                str = @"[视频]";
                break;
            }
            else if([elem isKindOfClass:[TIMFaceElem class]]){
                str = @"[动画表情]";
                break;
            }
            else if([elem isKindOfClass:[TIMFileElem class]]){
                str = @"[文件]";
                break;
            }
            else if([elem isKindOfClass:[TIMGroupTipsElem class]]){
                TIMGroupTipsElem *tips = (TIMGroupTipsElem *)elem;
                switch (tips.type) {
                    case TIM_GROUP_TIPS_TYPE_INFO_CHANGE:
                    {
                        for (TIMGroupTipsElemGroupInfo *info in tips.groupChangeList) {
                            switch (info.type) {
                                case TIM_GROUP_INFO_CHANGE_GROUP_NAME:
                                {
                                    str = [NSString stringWithFormat:@"\"%@\"修改群名为\"%@\"", tips.opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_INTRODUCTION:
                                {
                                    str = [NSString stringWithFormat:@"\"%@\"修改群简介为\"%@\"", tips.opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_NOTIFICATION:
                                {
                                    str = [NSString stringWithFormat:@"\"%@\"修改群公告为\"%@\"", tips.opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_OWNER:
                                {
                                    str = [NSString stringWithFormat:@"\"%@\"修改群主为\"%@\"", tips.opUser, info.value];
                                }
                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                        break;
                    case TIM_GROUP_TIPS_TYPE_KICKED:
                    {
                        NSString *users = [tips.userList componentsJoinedByString:@"、"];
                        str = [NSString stringWithFormat:@"\"%@\"将\"%@\"踢出群组", tips.opUser, users];
                    }
                        break;
                    case TIM_GROUP_TIPS_TYPE_INVITE:
                    {
                        NSString *users = [tips.userList componentsJoinedByString:@"、"];
                        if ([tips.opUser isEqualToString:users]) {
                            str = [NSString stringWithFormat:@"\"%@\"加入群组", tips.opUser];
                        } else {
                            str = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入群组", tips.opUser, users];
                        }
                    }
                        break;
                    case TIM_GROUP_TIPS_TYPE_QUIT_GRP:
                    {
                        if (tips.opUser.length) {
                            str = [NSString stringWithFormat:@"您所在的群已被\"%@\"解散", tips.opUser];
                        } else {
                            str = @"您所在的群已解散";
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
        }
    }
    return str;
}
@end
