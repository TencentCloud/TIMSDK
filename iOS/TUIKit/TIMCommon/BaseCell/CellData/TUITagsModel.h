//
//  TUITagsModel.h
//  TUITagDemo
//
//  Created by wyl on 2022/5/12.
//  Copyright © 2022 TUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUITagsUserModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *friendRemark;
@property (nonatomic, copy) NSString *nameCard;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *faceURL;

- (NSString *)getDisplayName;
@end

@interface TUITagsModel : NSObject

/**
 * 标签名字
 * Label name
 */
@property (nonatomic, copy) NSString *name;

/**
 * 标签别名
 * Label alias
 */
@property (nonatomic, copy) NSString *alias;

/**
 * 标签名字颜色
 * The color of label displaying name
 */
@property (nonatomic, strong) UIColor *textColor;


@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, strong) UIColor *defaultColor;

@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic, copy) NSString * emojiKey;

@property (nonatomic, strong) NSMutableArray * followIDs;

@property (nonatomic, strong) NSMutableArray * followUserNames;

@property (nonatomic, strong) NSMutableArray <TUITagsUserModel *> * followUserModels;

@property (nonatomic, assign) double maxWidth;
@property (nonatomic, copy) NSString * emojiPath;

- (NSString *)descriptionFollowUserStr;

@end

NS_ASSUME_NONNULL_END
