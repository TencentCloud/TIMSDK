//
//  TUILiveGiftInfo.m
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import "TUILiveGiftInfo.h"

@implementation TUILiveGiftInfo

- (instancetype)initWithGiftName:(NSString *)name
                           value:(NSInteger)value
                            icon:(NSString *)iconUrl
                         context:(nonnull id)context
{
    if (self = [super init]) {
        _title = [name copy];
        _value = value;
        _giftPicUrl = [iconUrl copy];
        _context = context;
    }
    return self;
}

@end
