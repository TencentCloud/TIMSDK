//
//  TUICallKitSelectGroupMemberCell.h
//  Pods
//
//  Created by vincepzhang on 2023/4/7.
//  Copyright © 2021 Tencent. All rights reserved


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TUICallKitGroupMemberInfo;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallKitSelectGroupMemberCell : UITableViewCell

- (void)configCell:(TUICallKitGroupMemberInfo *)userInfo isAdded:(BOOL)isAdded;

@end

NS_ASSUME_NONNULL_END
