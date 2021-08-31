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
#import "TUIMergeMessageCell.h"
#import "TUIFaceView.h"
#import "TUIKit.h"
#import "NSString+TUICommon.h"
#import "TIMMessage+DataProvider.h"
#import "TIMUserProfile+DataProvider.h"
#import "TUIJoinGroupMessageCellData.h"
#import "NSBundle+TUIKIT.h"
#import "TUIKitListenerManager.h"

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

- (NSString *)getShowName:(V2TIMMessage *)message {
    NSString *showName = message.sender;
    if (message.nameCard.length > 0) {
        showName = message.nameCard;
    } else if (message.friendRemark.length > 0) {
        showName = message.friendRemark;
    } else if (message.nickName.length > 0) {
        showName = message.nickName;
    }
    return showName;
}

- (NSString *)getDisplayString:(V2TIMMessage *)msg
{
    NSString *str;
    if(msg.status == V2TIM_MSG_STATUS_LOCAL_REVOKED){
        if(msg.isSelf){
            str = TUILocalizableString(TUIKitMessageTipsYouRecallMessage); // @"你撤回了一条消息";
        }
        else if(msg.groupID != nil){
            //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
            NSString *userString = msg.nameCard;;
            if(userString.length == 0){
                userString = msg.nickName;
            }
            if (userString.length == 0) {
                userString = msg.sender;
            }
            str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsRecallMessageFormat), userString]; // "\"%@\"撤回了一条消息";
        }
        else if(msg.userID != nil){
            str = TUILocalizableString(TUIkitMessageTipsOthersRecallMessage);   // @"对方撤回了一条消息";
        }
    } else {
        switch (msg.elemType) {
            case V2TIM_ELEM_TYPE_TEXT:
            {
                // 处理表情的国际化
                NSString *content = msg.textElem.text;
                str = [self localizableStringWithFaceContent:content];
            }
                break;
            case V2TIM_ELEM_TYPE_CUSTOM:
            {
                str = TUILocalizableString(TUIKitMessageTipsUnsupportCustomMessage);; // 不支持的自定义消息;
            }
                break;
            case V2TIM_ELEM_TYPE_IMAGE:
            {
                str = TUILocalizableString(TUIkitMessageTypeImage); // @"[图片]";
            }
                break;
            case V2TIM_ELEM_TYPE_SOUND:
            {
                str = TUILocalizableString(TUIKitMessageTypeVoice); // @"[语音]";
            }
                break;
            case V2TIM_ELEM_TYPE_VIDEO:
            {
                str = TUILocalizableString(TUIkitMessageTypeVideo); // @"[视频]";
            }
                break;
            case V2TIM_ELEM_TYPE_FILE:
            {
                str = TUILocalizableString(TUIkitMessageTypeFile); // @"[文件]";
            }
                break;
            case V2TIM_ELEM_TYPE_FACE:
            {
                str = TUILocalizableString(TUIKitMessageTypeAnimateEmoji); // @"[动画表情]";
            }
                break;
            case V2TIM_ELEM_TYPE_GROUP_TIPS:
            {
                V2TIMGroupTipsElem *tips = msg.groupTipsElem;
                NSString *opUser = [self getOpUserName:tips.opMember];
                NSMutableArray<NSString *> *userList = [self getUserNameList:tips.memberList];
                switch (tips.type) {
                        case V2TIM_GROUP_TIPS_TYPE_JOIN:
                        {
                            if (opUser.length > 0) {
                                if ((userList.count == 0) ||
                                    (userList.count == 1 && [opUser isEqualToString:userList.firstObject])) {
                                    str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsJoinGroupFormat), opUser]; // @"\"%@\"加入群组
                                } else {
                                    NSString *users = [userList componentsJoinedByString:@"、"];
                                    str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsInviteJoinGroupFormat), opUser, users]; // \"%@\"邀请\"%@\"加入群组
                                }
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_INVITE:
                        {
                            if (userList.count > 0) {
                                NSString *users = [userList componentsJoinedByString:@"、"];
                                str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsInviteJoinGroupFormat), opUser, users]; // \"%@\"邀请\"%@\"加入群组
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_QUIT:
                        {
                            if (opUser.length > 0) {
                                str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsLeaveGroupFormat), opUser]; // \"%@\"退出了群聊
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_KICKED:
                        {
                            if (userList.count > 0) {
                                NSString *users = [userList componentsJoinedByString:@"、"];
                                str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsKickoffGroupFormat), opUser, users]; // \"%@\"将\"%@\"踢出群组
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_SET_ADMIN:
                        {
                            if (userList.count > 0) {
                                NSString *users = [userList componentsJoinedByString:@"、"];
                                str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsSettAdminFormat), users]; // \"%@\"被设置管理员
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN:
                        {
                            if (userList.count > 0) {
                                NSString *users = [userList componentsJoinedByString:@"、"];
                                str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsCancelAdminFormat), users]; // \"%@\"被取消管理员
                            }
                        }
                            break;
                        case V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE:
                        {
                            str = [NSString stringWithFormat:@"\"%@\"", opUser];
                            for (V2TIMGroupChangeInfo *info in tips.groupChangeInfoList) {
                                switch (info.type) {
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_NAME:
                                    {
                                        str = [NSString stringWithFormat:TUILocalizableString(TUIkitMessageTipsEditGroupNameFormat), str, info.value]; // %@修改群名为\"%@\"、
                                    }
                                        break;
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION:
                                    {
                                        str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsEditGroupIntroFormat), str, info.value]; // %@修改群简介为\"%@\"、
                                    }
                                        break;
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION:
                                    {
                                        str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsEditGroupAnnounceFormat), str, info.value]; // %@修改群公告为\"%@\"、
                                    }
                                        break;
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_FACE:
                                    {
                                        str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsEditGroupAvatarFormat), str]; // %@修改群头像、
                                    }
                                        break;
                                    case V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER:
                                    {
                                        // %@修改群主为\"%@\"、
                                        if (userList.count) {
                                            str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsEditGroupOwnerFormat), str, userList.firstObject];
                                        } else {
                                            str = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsEditGroupOwnerFormat), str, info.value];
                                        }
                                    }
                                        break;
                                    default:
                                        break;
                                }
                            }
                            if (str.length > 0) {
                                str = [str substringToIndex:str.length - 1];
                            }
                        }
                            break;
                    case V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE:
                    {
                        for (V2TIMGroupChangeInfo *info in tips.memberChangeInfoList) {
                            if ([info isKindOfClass:V2TIMGroupMemberChangeInfo.class]) {
                                NSString *userId = [(V2TIMGroupMemberChangeInfo *)info userID];
                                int32_t muteTime = [(V2TIMGroupMemberChangeInfo *)info muteTime];
                                NSString *myId = V2TIMManager.sharedInstance.getLoginUser;
                                str = [NSString stringWithFormat:@"%@%@", [userId isEqualToString:myId] ? TUILocalizableString(You) : userId, muteTime == 0 ? TUILocalizableString(TUIKitMessageTipsUnmute): TUILocalizableString(TUIKitMessageTipsMute)];
                                break;
                            }
                        }
                    }
                        break;
                        default:
                            break;
                    }
            }
                break;
            case V2TIM_ELEM_TYPE_MERGER:
            {
                str = [NSString stringWithFormat:@"[%@]", TUILocalizableString(TUIKitRelayChatHistory)];
            }
                break;
            default:
                break;
        }
//        for (int i = 0; i < msg.elemCount; ++i) {
//
//            else if([elem isKindOfClass:[TIMGroupTipsElem class]]){
//
//            }
//            else if ([elem isKindOfClass:[TIMGroupSystemElem class]]) {
//                // TODO: 退群消息由于SDK的bug，导致经常接收不到
//                // GroupSeystem的conv->groupId为空
//                TIMGroupSystemElem *tips = (TIMGroupSystemElem *)elem;
//                switch (tips.type) {
//                    case TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE: {
//                        str = @"您所在的群已解散";
//                    }
//                        break;
//                    default:
//                        break;
//                }
//            }
//        }
    }
    return str;
}

-(TUIMessageCellData *) getCellData:(V2TIMMessage *)message{
    TUIMessageCellData *data = nil;
    switch (message.elemType) {
        case V2TIM_ELEM_TYPE_TEXT:
        {
            data = [self getTextCellData:message fromElem:message.textElem];
        }
            break;
        case V2TIM_ELEM_TYPE_IMAGE:
        {
            data = [self getImageCellData:message fromElem:message.imageElem];
        }
            break;
        case V2TIM_ELEM_TYPE_SOUND:
        {
            data = [self getVoiceCellData:message fromElem:message.soundElem];
        }
            break;
        case V2TIM_ELEM_TYPE_VIDEO:
        {
            data = [self getVideoCellData:message fromElem:message.videoElem];
        }
            break;
        case V2TIM_ELEM_TYPE_FILE:
        {
            data = [self getFileCellData:message fromElem:message.fileElem];
        }
            break;
        case V2TIM_ELEM_TYPE_FACE:
        {
            data = [self getFaceCellData:message fromElem:message.faceElem];
        }
            break;
        case V2TIM_ELEM_TYPE_GROUP_TIPS:
        {
            data = [self getSystemCellData:message fromElem:message.groupTipsElem];
        }
            break;
        case V2TIM_ELEM_TYPE_MERGER:
        {
            data = [self getMergerCellData:message fromElem:message.mergerElem];
        }
            break;
        default:
            break;
    }
    data.avatarUrl = [NSURL URLWithString:message.faceURL];
    return data;
}

- (TUITextMessageCellData *) getTextCellData:(V2TIMMessage *)message  fromElem:(V2TIMTextElem *)elem{
    TUITextMessageCellData *textData = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    textData.content = elem.text;
    return textData;
}

- (TUIFaceMessageCellData *) getFaceCellData:(V2TIMMessage *)message  fromElem:(V2TIMFaceElem *)elem{
    TUIFaceMessageCellData *faceData = [[TUIFaceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    faceData.groupIndex = elem.index;
    faceData.faceName = [[NSString alloc] initWithData:elem.data encoding:NSUTF8StringEncoding];
    for (TFaceGroup *group in [TUIKit sharedInstance].config.faceGroups) {
        if(group.groupIndex == faceData.groupIndex){
            NSString *path = [group.groupPath stringByAppendingPathComponent:faceData.faceName];
            faceData.path = path;
            break;
        }
    }
    faceData.reuseId = TFaceMessageCell_ReuseId;
    return faceData;
}

- (TUIImageMessageCellData *) getImageCellData:(V2TIMMessage *)message fromElem:(V2TIMImageElem *)elem{
    TUIImageMessageCellData *imageData = [[TUIImageMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    imageData.path = [elem.path safePathString];
    imageData.items = [NSMutableArray array];
    for (V2TIMImage *item in elem.imageList) {
        TUIImageItem *itemData = [[TUIImageItem alloc] init];
        itemData.uuid = item.uuid;
        itemData.size = CGSizeMake(item.width, item.height);
//        itemData.url = item.url;
        if(item.type == V2TIM_IMAGE_TYPE_THUMB){
            itemData.type = TImage_Type_Thumb;
        }
        else if(item.type == V2TIM_IMAGE_TYPE_LARGE){
            itemData.type = TImage_Type_Large;
        }
        else if(item.type == V2TIM_IMAGE_TYPE_ORIGIN){
            itemData.type = TImage_Type_Origin;
        }
        [imageData.items addObject:itemData];
    }
    return imageData;
}

- (TUIVoiceMessageCellData *) getVoiceCellData:(V2TIMMessage *) message fromElem:(V2TIMSoundElem *) elem{
    TUIVoiceMessageCellData *soundData = [[TUIVoiceMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    soundData.duration = elem.duration;
    soundData.length = elem.dataSize;
    soundData.uuid = elem.uuid;
    soundData.path = elem.path;
    return soundData;
}

- (TUIVideoMessageCellData *) getVideoCellData:(V2TIMMessage *)message fromElem:(V2TIMVideoElem *) elem{
    TUIVideoMessageCellData *videoData = [[TUIVideoMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    videoData.videoPath = [elem.videoPath safePathString];
    videoData.snapshotPath = [elem.snapshotPath safePathString];

    videoData.videoItem = [[TUIVideoItem alloc] init];
    videoData.videoItem.uuid = elem.videoUUID;
    videoData.videoItem.type = elem.videoType;
    videoData.videoItem.length = elem.videoSize;
    videoData.videoItem.duration = elem.duration;

    videoData.snapshotItem = [[TUISnapshotItem alloc] init];
    videoData.snapshotItem.uuid = elem.snapshotUUID;
//    videoData.snapshotItem.type = elem.snaps;
    videoData.snapshotItem.length = elem.snapshotSize;
    videoData.snapshotItem.size = CGSizeMake(elem.snapshotWidth, elem.snapshotHeight);

    return videoData;
}

- (TUIFileMessageCellData *) getFileCellData:(V2TIMMessage *)message fromElem:(V2TIMFileElem *)elem{
    TUIFileMessageCellData *fileData = [[TUIFileMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    fileData.path = [elem.path safePathString];
    fileData.fileName = elem.filename;
    fileData.length = elem.fileSize;
    fileData.uuid = elem.uuid;
    return fileData;
}

- (TUIMessageCellData *)getMergerCellData:(V2TIMMessage *)message fromElem:(V2TIMMergerElem *)elem {
    
    if (elem.layersOverLimit) {
        TUITextMessageCellData *limitCell = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
        limitCell.content = TUILocalizableString(TUIKitRelayLayerLimitTips);
        return limitCell;
    }
    
    TUIMergeMessageCellData *relayData = [[TUIMergeMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    relayData.title = elem.title;
    relayData.abstractList = [NSArray arrayWithArray:elem.abstractList];
    relayData.mergerElem = elem;
    return relayData;
}

- (TUISystemMessageCellData *) getSystemCellData:(V2TIMMessage *)message fromElem:(V2TIMGroupTipsElem *)elem{
    V2TIMGroupTipsElem *tip = (V2TIMGroupTipsElem *)elem;
    NSString *opUserName = [self getOpUserName:tip.opMember];
    NSMutableArray<NSString *> *userNameList = [self getUserNameList:tip.memberList];
    NSMutableArray<NSString *> *userIDList = [self getUserIDList:tip.memberList];
    if(tip.type == V2TIM_GROUP_TIPS_TYPE_JOIN || tip.type == V2TIM_GROUP_TIPS_TYPE_INVITE || tip.type == V2TIM_GROUP_TIPS_TYPE_KICKED || tip.type == V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE || tip.type == V2TIM_GROUP_TIPS_TYPE_QUIT){
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [self getDisplayString:message];
        joinGroupData.opUserName = opUserName;
        joinGroupData.opUserID = tip.opMember.userID;
        joinGroupData.userNameList = userNameList;
        joinGroupData.userIDList = userIDList;
        return joinGroupData;
    } else {
        //其他群Tips消息正常处理
        TUISystemMessageCellData *sysdata = [[TUISystemMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        sysdata.content = [self getDisplayString:message];
        if (sysdata.content.length) {
            return sysdata;
        }
    }
    return nil;
}

- (TUISystemMessageCellData *) getRevokeCellData:(V2TIMMessage *)message{

    TUISystemMessageCellData *revoke = [[TUISystemMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    if(message.isSelf){
        revoke.content = TUILocalizableString(TUIKitMessageTipsYouRecallMessage); // @"你撤回了一条消息";
        revoke.innerMessage = message;
        return revoke;
    } else if (message.userID.length > 0){
        revoke.content = TUILocalizableString(TUIkitMessageTipsOthersRecallMessage); // @"对方撤回了一条消息";
        revoke.innerMessage = message;
        return revoke;
    } else if (message.groupID.length > 0) {
        //对于群组消息的名称显示，优先显示群名片，昵称优先级其次，用户ID优先级最低。
        NSString *userName = message.sender;
        if (message.nameCard.length > 0) {
            userName = message.nameCard;
        } else if (message.nickName.length > 0) {
            userName = message.nickName;
        }
        TUIJoinGroupMessageCellData *joinGroupData = [[TUIJoinGroupMessageCellData alloc] initWithDirection:MsgDirectionIncoming];
        joinGroupData.content = [NSString stringWithFormat:TUILocalizableString(TUIKitMessageTipsRecallMessageFormat), userName]; //  @"\"%@\"撤回了一条消息"
        joinGroupData.opUserID = message.sender;
        joinGroupData.opUserName = userName;
        return joinGroupData;
    }
    return nil;
}

-(NSString *)getOpUserName:(V2TIMGroupMemberInfo *)info{
    NSString *opUser;
    if (info.nameCard.length > 0){
        opUser = info.nameCard;
    } else if (info.nickName.length > 0) {
        opUser = info.nickName;
    } else {
        opUser = info.userID;
    }
    return opUser;
}

-(NSMutableArray *)getUserNameList:(NSArray<V2TIMGroupMemberInfo *> *)infoList{
    NSMutableArray<NSString *> *userNameList = [NSMutableArray array];
    for (V2TIMGroupMemberInfo *info in infoList) {
        if(info.nameCard.length > 0) {
            [userNameList addObject:info.nameCard];
        } else if (info.nickName.length > 0){
            [userNameList addObject:info.nickName];
        }else{
            [userNameList addObject:info.userID];
        }
    }
    return userNameList;
}

-(NSMutableArray *)getUserIDList:(NSArray<V2TIMGroupMemberInfo *> *)infoList{
    NSMutableArray<NSString *> *userIDList = [NSMutableArray array];
    for (V2TIMGroupMemberInfo *info in infoList) {
        [userIDList addObject:info.userID];
    }
    return userIDList;
}

#pragma mark - 表情国际化
- (NSString *)localizableStringWithFaceContent:(NSString *)faceContent
{
    NSString *content = faceContent?:@"";
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (re) {
        NSArray *resultArray = [re matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        TFaceGroup *group = [TUIKit sharedInstance].config.faceGroups[0];
        NSMutableArray *waitingReplaceM = [NSMutableArray array];
        for(NSTextCheckingResult *match in resultArray) {
            NSRange range = [match range];
            NSString *subStr = [content substringWithRange:range];
            for (TFaceCellData *face in group.faces) {
                if ([face.name isEqualToString:subStr]) {
                    [waitingReplaceM addObject:@{
                        @"range":NSStringFromRange(range),
                        @"localizableStr": face.localizableName.length?face.localizableName:face.name
                    }];
                    break;
                }
            }
        }
        
        if (waitingReplaceM.count) {
            // 从后往前替换，否则会引起位置问题
            for (int i = (int)waitingReplaceM.count -1; i >= 0; i--) {
                NSRange range = NSRangeFromString(waitingReplaceM[i][@"range"]);
                NSString *localizableStr = waitingReplaceM[i][@"localizableStr"];
                content = [content stringByReplacingCharactersInRange:range withString:localizableStr];
            }
        }
    }
    return content;
}

@end
