//
//  TAddHelper.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TLetter_Key @"key"
#define TLetter_Value @"value"

@interface TAddHelper : NSObject
+ (NSMutableArray *)arrayWithFirstLetterFormat:(NSArray *)array;
+ (NSString *)getFirstLetter:(NSString *)str;
@end
