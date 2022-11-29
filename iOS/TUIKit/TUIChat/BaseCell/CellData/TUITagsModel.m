//
//  TUITagsModel.m
//  TUITagDemo
//
//  Created by wyl on 2022/5/12.
//  Copyright © 2022 TUI. All rights reserved.
//

#import "TUITagsModel.h"

@implementation TUITagsUserModel

- (NSString *)getDisplayName {
    if(IS_NOT_EMPTY_NSSTRING(self.nameCard)) {
        return self.nameCard;
    }
    else if (IS_NOT_EMPTY_NSSTRING(self.friendRemark)) {
        return self.friendRemark;
    }
    else if (IS_NOT_EMPTY_NSSTRING(self.nickName)) {
        return self.nickName;
    }
    else {
        return self.userID;
    }
    return @"";
}
@end

@implementation TUITagsModel

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

- (NSMutableArray<TUITagsUserModel *> *)followUserModels {
    if (!_followUserModels) {
        _followUserModels = [NSMutableArray arrayWithCapacity:3];
    }
    return _followUserModels;
}

- (NSString *)descriptionFollowUserStr {
    if (self.followUserNames.count <=0) {
        return @"";
    }
    
    NSString *str = [self.followUserNames componentsJoinedByString:@","];
    return str;
}
@end
