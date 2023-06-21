//
//  TUIGroupNoticeCellData.h
//  TUIGroup
//
//  Created by harvy on 2022/1/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupNoticeCellData : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, weak) id target;
@property(nonatomic, assign) SEL selector;

@end

NS_ASSUME_NONNULL_END
