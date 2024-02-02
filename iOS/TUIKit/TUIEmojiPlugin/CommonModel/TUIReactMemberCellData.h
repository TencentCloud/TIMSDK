//
//  TUIReactMemberCellData.h
//  TUITagDemo
//
//  Created by wyl on 2022/5/12.
//  Copyright © 2022 TUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
#import "TUIReactModel.h"

@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReactMemberCellData : NSObject

@property(nonatomic, copy) NSString *emojiName;

@property(nonatomic, copy) NSString *emojiPath;

@property(nonatomic, assign) CGFloat cellHeight;

@property(nonatomic, copy) NSString *friendRemark;

@property(nonatomic, copy) NSString *nickName;

@property(nonatomic, copy) NSString *faceURL;

@property(nonatomic, copy) NSString *userID;

@property(nonatomic, assign) BOOL isCurrentUser;

- (NSString *)displayName;

@property(nonatomic, strong) TUIReactModel * tagModel;

@end

NS_ASSUME_NONNULL_END
