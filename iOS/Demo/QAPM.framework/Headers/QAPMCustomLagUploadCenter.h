//
//  QAPMCustomLagUploadCenter.h
//  QAPM
//
//  Created by v_wxyawang on 2020/03/16.
//  Copyright © 2020年 com.tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QAPMCustomLagUploadCenter : NSObject
+ (instancetype)manager;
/**
 用户自定义卡顿数据操作调用,外部用户接口。
 @param customStack      自定义custom，一个customStack为一个time_slices，请注意格式。
 @param stage 自定义场景名，默认场景为"others"。
 @return 返回值为0表示上报失败，返回1表示成功。
*/
                      
- (int)customLooperMeta:(NSString *)stage customStack:(NSArray *)customStack;

@end
