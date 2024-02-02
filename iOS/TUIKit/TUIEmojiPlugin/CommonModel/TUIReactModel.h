//
//  TUIReactModel.h
//  TUITagDemo
//
//  Created by wyl on 2022/5/12.
//  Copyright © 2022 TUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIRelationUserModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIReactUserModel : TUIRelationUserModel

@end

@interface TUIReactModel : NSObject

+ (TUIReactModel *)createTagsModelByReaction:(V2TIMMessageReaction *)reaction;
/**
 * 标签名字
 * Label name
 */
@property(nonatomic, copy) NSString *name;

/**
 * 标签别名
 * Label alias
 */
@property(nonatomic, copy) NSString *alias;

/**
 * 标签名字颜色
 * The color of label displaying name
 */
@property(nonatomic, strong) UIColor *textColor;

@property(nonatomic, assign) BOOL isSelect;

@property(nonatomic, strong) UIColor *defaultColor;

@property(nonatomic, strong) UIColor *selectColor;

@property(nonatomic, copy) NSString *emojiKey;

@property(nonatomic, strong) NSMutableArray *followIDs;

@property(nonatomic, strong) NSMutableArray *followUserNames;

@property(nonatomic, strong) NSMutableArray<TUIReactUserModel *> *followUserModels;

@property(nonatomic, assign) double maxWidth;
@property(nonatomic, copy) NSString *emojiPath;

@property(nonatomic, assign) NSInteger totalUserCount;
@property(nonatomic, assign) BOOL reactedByMyself;

- (NSString *)descriptionFollowUserStr;

@end

NS_ASSUME_NONNULL_END
