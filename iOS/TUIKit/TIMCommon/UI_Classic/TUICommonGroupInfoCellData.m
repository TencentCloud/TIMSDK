//
//  TUICommonGroupInfoCellData.m
//  TIMCommon
//
//  Created by yiliangwang on 2024/12/26.
//  Copyright © 2024 Tencent. All rights reserved.

#import "TUICommonGroupInfoCellData.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/UIView+TUILayout.h>

@implementation TUIGroupMemberCellData

@end

@implementation TUIGroupMembersCellData

+ (CGSize)getSize {
    CGSize headSize = TGroupMemberCell_Head_Size;
    if (headSize.width * TGroupMembersCell_Column_Count + TGroupMembersCell_Margin * (TGroupMembersCell_Column_Count + 1) > Screen_Width) {
        CGFloat wd = (Screen_Width - (TGroupMembersCell_Margin * (TGroupMembersCell_Column_Count + 1))) / TGroupMembersCell_Column_Count;
        headSize = CGSizeMake(wd, wd);
    }
    return CGSizeMake(headSize.width, headSize.height + TGroupMemberCell_Name_Height + TGroupMemberCell_Margin);
}

+ (CGFloat)getHeight:(TUIGroupMembersCellData *)data {
    NSInteger row = ceil(data.members.count * 1.0 / TGroupMembersCell_Column_Count);
    if (row > TGroupMembersCell_Row_Count) {
        row = TGroupMembersCell_Row_Count;
    }
    CGFloat height = row * [self getSize].height + (row + 1) * TGroupMembersCell_Margin;
    return height;
}


- (CGFloat)heightOfWidth:(CGFloat)width {
    return [self.class getHeight:self];
}

@end


@implementation TUICommonGroupInfoCellData

@end
