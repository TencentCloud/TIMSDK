//
//  TUITagsModel.h
//  TUITagDemo
//
//  Created by wyl on 2022/5/12.
//  Copyright © 2022 TUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUITagsUserModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *friendRemark;
@property (nonatomic, copy) NSString *nameCard;
@property (nonatomic, copy) NSString *nickName;

- (NSString *)getDisplayName;
@end

@interface TUITagsModel : NSObject

/// 标签名字
@property (nonatomic, copy) NSString *name;
/// 别名
@property (nonatomic, copy) NSString *alias;

/// 标签名字颜色
@property (nonatomic, strong) UIColor *textColor;
/// 是否选中
@property (nonatomic, assign) BOOL isSelect;

/// 默认颜色
@property (nonatomic, strong) UIColor *defaultColor;
/// 选中颜色
@property (nonatomic, strong) UIColor *selectColor;



@property (nonatomic, copy) NSString * emojiKey;
@property (nonatomic, strong) NSMutableArray * followIDs;
@property (nonatomic, strong) NSMutableArray * followUserNames;
@property (nonatomic, assign) double maxWidth;
@property (nonatomic, copy) NSString * emojiPath;

- (NSString *)descriptionFollowUserStr;

@end

NS_ASSUME_NONNULL_END
