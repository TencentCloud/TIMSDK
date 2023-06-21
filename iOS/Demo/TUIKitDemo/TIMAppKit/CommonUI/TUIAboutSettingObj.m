//
//  TUIAboutSettingObj.m
//  TUIKitDemo
//
//  Created by wyl on 2022/2/9.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUIAboutSettingObj.h"

@implementation TUIAboutSettingObj
- (instancetype)init {
    return [self initWithTitle:nil subTitle:nil cellClass:[NSObject class]];
}

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle cellClass:(Class)cellClass {
    if (self = [super init]) {
        _title = title;
        _subtitle = subTitle;
        _cellClass = cellClass;
        _cellHeight = 52;
    }
    return self;
}

@end
