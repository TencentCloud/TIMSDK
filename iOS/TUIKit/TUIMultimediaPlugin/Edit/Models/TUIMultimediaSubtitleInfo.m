// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaSubtitleInfo.h"
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"

@implementation TUIMultimediaSubtitleInfo
- (instancetype)init {
    return [self initWithText:@"" color:UIColor.whiteColor];
}
- (instancetype)initWithText:(NSString *)text color:(UIColor *)color {
    self = [super init];
    if (self != nil) {
        _text = text;
        _color = color;
    }
    return self;
}
- (id)copyWithZone:(nullable NSZone *)zone {
    TUIMultimediaSubtitleInfo *cp = [[[self class] allocWithZone:zone] init];
    cp.text = _text;
    cp.color = _color;
    return cp;
}

@end
