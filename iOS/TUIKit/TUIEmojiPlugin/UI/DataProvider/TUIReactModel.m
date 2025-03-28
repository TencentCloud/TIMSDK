//
//  TUIReactModel.m
//  TUITagDemo
//
//  Created by wyl on 2022/5/12.
//  Copyright © 2022 TUI. All rights reserved.
//

#import "TUIReactModel.h"
#import <TIMCommon/NSString+TUIEmoji.h>

@implementation TUIReactUserModel

- (NSString *)getDisplayName {
    if (IS_NOT_EMPTY_NSSTRING(self.nameCard)) {
        return self.nameCard;
    } else if (IS_NOT_EMPTY_NSSTRING(self.friendRemark)) {
        return self.friendRemark;
    } else if (IS_NOT_EMPTY_NSSTRING(self.nickName)) {
        return self.nickName;
    } else {
        return self.userID;
    }
    return @"";
}

@end

@implementation TUIReactModel

- (NSMutableArray *)followIDs {
    if (!_followIDs) {
        _followIDs = [NSMutableArray arrayWithCapacity:3];
    }
    return _followIDs;
}

- (NSMutableArray *)followUserNames {
    if (!_followUserNames) {
        _followUserNames = [NSMutableArray arrayWithCapacity:3];
    }
    return _followUserNames;
}

- (NSMutableArray<TUIReactUserModel *> *)followUserModels {
    if (!_followUserModels) {
        _followUserModels = [NSMutableArray arrayWithCapacity:3];
    }
    return _followUserModels;
}

- (NSString *)descriptionFollowUserStr {
    if (self.followUserNames.count <= 0) {
        return @"";
    }

    NSString *str = [self.followUserNames componentsJoinedByString:@","];
    return str;
}

+ (TUIReactModel *)createTagsModelByReaction:(V2TIMMessageReaction *)reaction {
    NSString *reactionID = reaction.reactionID;
    uint32_t totalUserCount = reaction.totalUserCount;
    NSArray *partialUserList = reaction.partialUserList;
    TUIReactModel *model = [[TUIReactModel alloc] init];
    model.defaultColor = [TIMCommonDynamicColor(@"", @"#444444") colorWithAlphaComponent:0.1];
    model.textColor = TIMCommonDynamicColor(@"chat_react_desc_color", @"#888888");
    model.emojiKey = reactionID;
    model.emojiPath = [reactionID getEmojiImagePath];
    model.reactedByMyself = reaction.reactedByMyself;
    model.totalUserCount = reaction.totalUserCount;
    
    for (V2TIMUserInfo *obj in partialUserList) {
        TUIReactUserModel *userModel = [[TUIReactUserModel alloc] init];
        userModel.userID = obj.userID;
        userModel.nickName = obj.nickName;
        userModel.faceURL = obj.faceURL;
        if (userModel && userModel.userID.length > 0) {
            [model.followIDs addObject:obj.userID];
        }
        NSString *name = [userModel getDisplayName];
        if (name.length > 0) {
            [model.followUserNames addObject:name];
        }
        
        if (userModel) {
            [model.followUserModels addObject:userModel];
        }
    }
    return model;
}
@end
