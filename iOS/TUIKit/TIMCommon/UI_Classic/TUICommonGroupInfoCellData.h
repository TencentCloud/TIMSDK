//
//  TUICommonGroupInfoCellData.h
//  TIMCommon
//
//  Created by yiliangwang on 2024/12/26.
//  Copyright © 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupMemberCellData : NSObject

@property(nonatomic, strong) NSString *identifier;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) UIImage *avatarImage;

@property(nonatomic, strong) NSString *avatarUrl;

@property NSInteger tag;

@end

@interface TUIGroupMembersCellData : NSObject

@property(nonatomic, strong) NSMutableArray *members;
- (CGFloat)heightOfWidth:(CGFloat)width;

@end

@interface TUICommonGroupInfoCellData : NSObject

@end

NS_ASSUME_NONNULL_END
