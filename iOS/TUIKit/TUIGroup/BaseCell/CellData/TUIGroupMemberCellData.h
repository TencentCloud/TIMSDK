//
//  TUIGroupMemberCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/6/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupMemberCellData : NSObject

@property(nonatomic, strong) NSString *identifier;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) UIImage *avatarImage;

@property(nonatomic, strong) NSString *avatarUrl;

@property NSInteger tag;

@end
NS_ASSUME_NONNULL_END
