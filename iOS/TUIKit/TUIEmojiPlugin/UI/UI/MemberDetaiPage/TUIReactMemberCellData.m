//
//  TUIReactMemberCellData.m
//  TUITagDemo
//
//  Created by wyl on 2022/5/12.
//  Copyright © 2022 TUI. All rights reserved.
//

#import "TUIReactMemberCellData.h"

@implementation TUIReactMemberCellData

- (NSString *)displayName {
    if (IS_NOT_EMPTY_NSSTRING(self.friendRemark)) {
        return self.friendRemark;
    } else if (IS_NOT_EMPTY_NSSTRING(self.nickName)) {
        return self.nickName;
    } else {
        return self.userID;
    }
    return @"";
}

- (CGFloat)cellHeight {
    return kScale390(72);
}

@end
