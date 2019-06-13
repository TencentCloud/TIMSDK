//
//  TUIKitConfig.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/5.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUIFaceView.h"
#import "TUIInputMoreCell.h"

typedef NS_ENUM(NSInteger, TUIKitAvatarType) {
    TAvatarTypeNone,             /*矩形直角头像*/
    TAvatarTypeRounded,          /*圆形头像*/
    TAvatarTypeRadiusCorner,     /*圆角头像*/
};

@interface TUIKitConfig : NSObject
/**
 * 表情列表
 */
@property (nonatomic, strong) NSArray<TFaceGroup *> *faceGroups;
/**
 *  头像类型
 */
@property (nonatomic, assign) TUIKitAvatarType avatarType;
/**
 *  头像圆角大小
 */
@property (nonatomic, assign) CGFloat avatarCornerRadius;
/**
 * 默认头像图片
 */
@property (nonatomic, strong) UIImage *defaultAvatarImage;
/**
 * 默认群组头像图片
 */
@property (nonatomic, strong) UIImage *defaultGroupAvatarImage;

+ (TUIKitConfig *)defaultConfig;

@end
