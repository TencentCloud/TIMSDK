//
//  CreatGroupAvatar.h
//  THeadImgs
//
//  Created by ITD on 2017/3/25.
//  Copyright © 2017年 ITD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreatGroupAvatar : NSObject

+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(NSData *groupAvatar))finished;

@end
