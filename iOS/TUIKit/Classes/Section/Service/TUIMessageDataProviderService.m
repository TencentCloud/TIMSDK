//
//  TElemDataProviderService.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import "TUIMessageDataProviderService.h"
#import "TCServiceManager.h"
#import "TUITextMessageCell.h"
#import "TUISystemMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "TUIImageMessageCell.h"
#import "TUIFaceMessageCell.h"
#import "TUIVideoMessageCell.h"
#import "TUIFileMessageCell.h"
#import "TUIFaceView.h"
#import "TUIKit.h"
#import "NSString+Common.h"
#import "TIMUserProfile+DataProvider.h"
#import "TUIJoinGroupMessageCellData.h"
#import <ImSDK/ImSDK.h>

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
        else if([[msg getConversation] getType] == TIM_GROUP){
            //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
            NSString *userString = [msg getSenderGroupMemberProfile].nameCard;;
            
            if(userString.length == 0){
                TIMUserProfile *userProfile = [[TIMFriendshipManager sharedInstance] queryUserProfile:msg.sender];
                userString = userProfile.showName;
            }
            if(userString.length == 0 || userString == nil){//由于上一行代码的 showName 为异步，所以为了防止异步拉空的情况，在此再进行一次校验。
                userString = msg.sender;
            }
            
            str = [NSString stringWithFormat:@"\"%@\"撤回了一条消息", userString];
            
        }
        else if([[msg getConversation] getType] == TIM_C2C){
            str = @"对方撤回了一条消息";
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

                NSString *opUser = [self getOpUserFromTip:tips];
                NSMutableArray<NSString *> *userList = [self getUserListFromTip:tips];
            

                switch (tips.type) {
                    case TIM_GROUP_TIPS_TYPE_INFO_CHANGE:
                    {
                        for (TIMGroupTipsElemGroupInfo *info in tips.groupChangeList) {
                            switch (info.type) {
                                case TIM_GROUP_INFO_CHANGE_GROUP_NAME:
                                {
                                    str = [NSString stringWithFormat:@"\"%@\"修改群名为\"%@\"", opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_INTRODUCTION:
                                {
                                    str = [NSString stringWithFormat:@"\"%@\"修改群简介为\"%@\"", opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_NOTIFICATION:
                                {
                                    str = [NSString stringWithFormat:@"\"%@\"修改群公告为\"%@\"", opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_OWNER:
                                {
                                    str = [NSString stringWithFormat:@"\"%@\"修改群主为\"%@\"", opUser, info.value];
                                }
                                    break;
                                case TIM_GROUP_INFO_CHANGE_GROUP_FACE:
                                {
                                    str = [NSString stringWithFormat:@"\"%@\"修改群头像", opUser];
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
                        NSString *users = [userList componentsJoinedByString:@"、"];
                        str = [NSString stringWithFormat:@"\"%@\"将\"%@\"踢出群组", opUser, users];
                    }
                        break;
                    case TIM_GROUP_TIPS_TYPE_INVITE:
                    {
                        NSString *userID = [tips.userList componentsJoinedByString:@"、"];
                        NSString *users = [userList componentsJoinedByString:@"、"];
                        if ([tips.opUser isEqualToString:userID]) {
                            str = [NSString stringWithFormat:@"\"%@\"加入群组", opUser];
                        } else {
                            str = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入群组", opUser, users];
                        }
                    }
                        break;
                    case TIM_GROUP_TIPS_TYPE_QUIT_GRP:
                    {
                        if (tips.opUser.length) {
                            str = [NSString stringWithFormat:@"\"%@\"退出了群聊", opUser];
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
            else if ([elem isKindOfClass:[TIMGroupSystemElem class]]) {
                // TODO: 退群消息由于SDK的bug，导致经常接收不到
                // GroupSeystem的conv->groupId为空
                TIMGroupSystemElem *tips = (TIMGroupSystemElem *)elem;
                switch (tips.type) {
                    case TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE: {
                        str = @"您所在的群已解散";
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

-(TUIMessageCellData *) getCellData:(TIMMessage *)message fromElem:(TIMElem *)elem{
    TUIMessageCellData *data = nil;
    if([elem isKindOfClass:[TIMTextElem class]]){
       data = [self getTextCellData:message fromElem:(TIMTextElem *)elem];
        
    }else if([elem isKindOfClass:[TIMFaceElem class]]){
        
        data = [self getFaceCellData:message fromElem:(TIMFaceElem *)elem];
        
    }else if([elem isKindOfClass:[TIMImageElem class]]){
        
        data = [self getImageCellData:message fromElem:(TIMImageElem *)elem];
        
    }else if([elem isKindOfClass:[TIMSoundElem class]]){
        
        data = [self getVoiceCellData:message fromElem:(TIMSoundElem *)elem];
        
    }else if([elem isKindOfClass:[TIMVideoElem class]]){
        
        data = [self getVideoCellData:message fromElem:(TIMVideoElem *)elem];
        
    }else if([elem isKindOfClass:[TIMFileElem class]]){
        
        data = [self getFileCellData:message fromElem:(TIMFileElem *)elem];
        
    }else{
        data = [self getSystemCellData:message formElem:elem];
    }
    //赋值头像 URL，否则消息单元不回显示对方头像
    data.avatarUrl = [NSURL URLWithString:[[TIMFriendshipManager sharedInstance] queryUserProfile:message.sender].faceURL];
    return data;
}

- (TUITextMessageCellData *) getTextCellData:(TIMMessage *)message  fromElem:(TIMTextElem *)elem{
    TIMTextElem *text = (TIMTextElem *)elem;
    TUITextMessageCellData *textData = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    textData.content = text.text;
    return textData;
}

- (TUIFaceMessageCellData *) getFaceCellData:(TIMMessage *)message  fromElem:(TIMFaceElem *)elem{
    
    TIMFaceElem *face = (TIMFaceElem *)elem;
    TUIFaceMessageCellData *faceData = [[TUIFaceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    faceData.groupIndex = face.index;
    faceData.faceName = [[NSString alloc] initWithData:face.data encoding:NSUTF8StringEncoding];
    for (TFaceGroup *group in [TUIKit sharedInstance].config.faceGroups) {
        if(group.groupIndex == faceData.groupIndex){
            NSString *path = [group.groupPath stringByAppendingPathComponent:faceData.faceName];
            faceData.path = path;
            break;
        }
    }
    faceData.reuseId = TFaceMessageCell_ReuseId;
    
    //如果没有查询到该表情，或者表情在本机无法解析，返回一个文字消息，提示无法解析。
    UIImage *image = [[TUIImageCache sharedInstance] getFaceFromCache:faceData.path];
    if(image == nil || faceData.groupIndex == 0){//第 0 组为[微笑]这类的文本类表情符号，这样强制将第 0 组表情转为文字，可更好的匹配旧版本表情。
        TUITextMessageCellData *textData = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
        textData.content = faceData.faceName;
        return textData;
    }
    
    
    return faceData;
}

- (TUIImageMessageCellData *) getImageCellData:(TIMMessage *)message fromElem:(TIMImageElem *)elem{
    TIMImageElem *image = (TIMImageElem *)elem;
    TUIImageMessageCellData *imageData = [[TUIImageMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    imageData.path = [image.path safePathString];
    imageData.items = [NSMutableArray array];
    for (TIMImage *item in image.imageList) {
        TUIImageItem *itemData = [[TUIImageItem alloc] init];
        itemData.uuid = item.uuid;
        itemData.size = CGSizeMake(item.width, item.height);
        itemData.url = item.url;
        if(item.type == TIM_IMAGE_TYPE_THUMB){
            itemData.type = TImage_Type_Thumb;
        }
        else if(item.type == TIM_IMAGE_TYPE_LARGE){
            itemData.type = TImage_Type_Large;
        }
        else if(item.type == TIM_IMAGE_TYPE_ORIGIN){
            itemData.type = TImage_Type_Origin;
        }
        [imageData.items addObject:itemData];
    }
    return imageData;
}

- (TUIVoiceMessageCellData *) getVoiceCellData:(TIMMessage *) message fromElem:(TIMSoundElem *) elem{
    TIMSoundElem *sound = (TIMSoundElem *)elem;
    TUIVoiceMessageCellData *soundData = [[TUIVoiceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    soundData.duration = sound.second;
    soundData.length = sound.dataSize;
    soundData.uuid = sound.uuid;
    
    return soundData;
}

- (TUIVideoMessageCellData *) getVideoCellData:(TIMMessage *)message fromElem:(TIMVideoElem *) elem{
    TIMVideoElem *video = (TIMVideoElem *)elem;
    TUIVideoMessageCellData *videoData = [[TUIVideoMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    videoData.videoPath = [video.videoPath safePathString];
    videoData.snapshotPath = [video.snapshotPath safePathString];
    
    videoData.videoItem = [[TUIVideoItem alloc] init];
    videoData.videoItem.uuid = video.video.uuid;
    videoData.videoItem.type = video.video.type;
    videoData.videoItem.length = video.video.size;
    videoData.videoItem.duration = video.video.duration;
    
    videoData.snapshotItem = [[TUISnapshotItem alloc] init];
    videoData.snapshotItem.uuid = video.snapshot.uuid;
    videoData.snapshotItem.type = video.snapshot.type;
    videoData.snapshotItem.length = video.snapshot.size;
    videoData.snapshotItem.size = CGSizeMake(video.snapshot.width, video.snapshot.height);
    
    return videoData;
    
}

- (TUIFileMessageCellData *) getFileCellData:(TIMMessage *)message fromElem:(TIMFileElem *)elem{
    TIMFileElem *file = (TIMFileElem *)elem;
    TUIFileMessageCellData *fileData = [[TUIFileMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    fileData.path = [file.path safePathString];
    fileData.fileName = file.filename;
    fileData.length = file.fileSize;
    fileData.uuid = file.uuid;
    
    return fileData;
}

- (TUISystemMessageCellData *) getSystemCellData:(TIMMessage *)message formElem:(TIMElem *)elem{
    if ([elem isKindOfClass:[TIMCustomElem class]]) {
        TIMCustomElem *custom = (TIMCustomElem *)elem;
        
        //系统信息中，对创建群、邀请、提出、退群、撤回、修改群信息（公告昵称等）的用户名添加了触摸响应。
        //触摸响应通过 TUIJoinGroupMessageCell（继承自 TUISystemMessageCell）实现。
        //触摸用户名可以跳转到对应的用户信息界面。
        
        if (custom.data.bytes) {
            if (strcmp(custom.data.bytes, "group_create") == 0) {
                TIMUserProfile *userProfile = [[TIMFriendshipManager sharedInstance] queryUserProfile:message.sender];
                TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
                if (userProfile) {
                    [joinGroupData.userName addObject:userProfile.showName];
                    [joinGroupData.userID addObject:userProfile.identifier];
                }
                //此信息在刚刚创建群时显示，所以暂时不需要考虑群名片，因为此时群名片必定未设置。
                joinGroupData.content = [self getDisplayString:message];
                if(joinGroupData.userName.count && joinGroupData.userName.count == joinGroupData.userID.count){
                    return joinGroupData;
                }
            }
        }
    } else if ([elem isKindOfClass:[TIMGroupTipsElem class]]){
        //对群信息小灰条特殊处理。
        TIMGroupTipsElem *tip = (TIMGroupTipsElem *)elem;
        NSString *opUser = [self getOpUserFromTip:tip];
        NSMutableArray<NSString *> *userList = [self getUserListFromTip:tip];
        if(tip.type == TIM_GROUP_TIPS_TYPE_INVITE){
            //入群与踢出不同，在入群时，opUser 可能和 user 为同一人。
            TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            joinGroupData.content = [self getDisplayString:message];
            if(opUser.length) //addObject 参数为 nil 时非常容易使得程序崩溃。所以此处添加一个判定，防止崩溃发生。
                [joinGroupData.userName addObject:opUser];
            if(tip.opUser.length)
                [joinGroupData.userID addObject:tip.opUser];
            if(userList.count && ![tip.opUser isEqualToString:tip.userList[0]]){//此处加入判定，如果是自主入群，即 opUser和userlist相同 则不再重复添加 userList 信息。
                [joinGroupData.userName addObjectsFromArray:userList];//多人入群的昵称
                [joinGroupData.userID addObjectsFromArray:tip.userList];//多人入群的ID，用于跳转到用户界面。
            }
            if(joinGroupData.userName.count && joinGroupData.userName.count == joinGroupData.userID.count){
            return joinGroupData;
            }
            
        } else if(tip.type == TIM_GROUP_TIPS_TYPE_KICKED){
            TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            joinGroupData.content = [self getDisplayString:message];
            if(opUser.length)
                [joinGroupData.userName addObject:opUser];
            if(tip.opUser.length)
                [joinGroupData.userID addObject:tip.opUser];
            if(userList.count){
                [joinGroupData.userName addObjectsFromArray:userList];//多人入群的昵称
                [joinGroupData.userID addObjectsFromArray:tip.userList];//多人入群的ID，用于跳转到用户界面。
            }
            if(joinGroupData.userName.count && joinGroupData.userName.count == joinGroupData.userID.count){
                return joinGroupData;
            }
        } else if(tip.type == TIM_GROUP_TIPS_TYPE_INFO_CHANGE){
            TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            joinGroupData.content = [self getDisplayString:message];
            if(opUser.length)
                [joinGroupData.userName addObject:opUser];
            if(tip.opUser.length)
                [joinGroupData.userID addObject:tip.opUser];
            if(joinGroupData.userName.count && joinGroupData.userName.count == joinGroupData.userID.count){
                return joinGroupData;
            }
        }else if(tip.type == TIM_GROUP_TIPS_TYPE_QUIT_GRP){
            TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            joinGroupData.content = [self getDisplayString:message];
            if(opUser.length)
                [joinGroupData.userName addObject:opUser];
            if(tip.opUser.length)
                [joinGroupData.userID addObject:tip.opUser];
            if(joinGroupData.userName.count && joinGroupData.userName.count == joinGroupData.userID.count){
                return joinGroupData;
            }
        }
        else{
        //其他群Tips消息正常处理
            TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
            sysdata.content = [self getDisplayString:message];
            if (sysdata.content.length) {
                return sysdata;
            }
        }
        
    }else {
        //其他系统消息正常处理
        TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        sysdata.content = [self getDisplayString:message];
        if (sysdata.content.length) {
            return sysdata;
        }
    }
    return nil;
}

- (TUISystemMessageCellData *) getRevokeCellData:(TIMMessage *)message{

    TUISystemMessageCellData *revoke = [[TUISystemMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    
    //此处若根据 message.Status 返回撤回字符串的话，会在 messageController 的 onRevoke 回调时发生错误，因为回调函数为异步，执行至此处时 status 还未更改，导致返回错误结果。若强行等待/同步可能造成更大问题。
    //所以此处将 getDisplayString 中的处理逻辑复制到此处。在今后更改撤回消息的逻辑时，注意要在此处和 getDisplayString 中同步更改。
    //TODO 在今后发现更好的解决方案时，进一步在此优化。
    //revoke.content = [self getDisplayString:message];
    if ([[message getConversation] getType] == TIM_GROUP) {
        //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
        NSString *userString = [message getSenderGroupMemberProfile].nameCard;;
        if(userString.length == 0){
            TIMUserProfile *userProfile = [[TIMFriendshipManager sharedInstance] queryUserProfile:message.sender];
            userString = userProfile.showName;
        }
        if(userString.length == 0 || userString == nil)//由于上一行代码的 showName 为异步，所以为了防止异步拉空的情况，在此再进行一次校验。
            userString = message.sender;
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [NSString stringWithFormat:@"\"%@\"撤回了一条消息", userString];
        if(userString.length)
            [joinGroupData.userName addObject:userString];
        if(message.sender.length)
            [joinGroupData.userID addObject:message.sender];
        if(joinGroupData.userName.count && joinGroupData.userName.count == joinGroupData.userID.count){
            return joinGroupData;
        }
    }
    
    
    
    if(message.isSelf){
        revoke.content = @"你撤回了一条消息";
    }
    else if ([[message getConversation] getType] == TIM_C2C){
        revoke.content = @"对方撤回了一条消息";
    }
    
    revoke.innerMessage = message;
    
    return revoke;

}
-(NSString *)getOpUserFromTip:(TIMGroupTipsElem *)tip{
      NSString *opUser = [NSString string];
    if(![tip.opGroupMemberInfo.nameCard isEqualToString:@""]){
        opUser = tip.opGroupMemberInfo.nameCard;
    }else if(![tip.opUserInfo.nickname isEqualToString:@""]) {
        opUser = tip.opUserInfo.nickname;
    }else {
        opUser = tip.opUser;
    }
    return opUser;
}

-(NSMutableArray *)getUserListFromTip:(TIMGroupTipsElem *)tip{
    NSMutableArray<NSString *> *userList = [NSMutableArray arrayWithCapacity:tip.userList.count];
    for(int i = 0 ; i < tip.userList.count ; i++){
        NSString *userID = tip.userList[i];
        NSString *nameCard = [tip.changedGroupMemberInfo objectForKey:userID].nameCard;
        NSString *nickName = [tip.changedUserInfo objectForKey:userID].nickname;
        if(![nameCard isEqualToString:@""]){
            userList[i] = nameCard;
        }else if(![nickName isEqualToString:@""]){
            userList[i] = nickName;
        }else{
            userList[i] = userID;
        }
    }
    return userList;
}

@end
