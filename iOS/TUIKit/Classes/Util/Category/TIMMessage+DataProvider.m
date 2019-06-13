//
//  TIMMessage+DataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import "TIMMessage+DataProvider.h"
#import "TCServiceManager.h"
#import "TUIMessageDataProviderServiceProtocol.h"

@implementation TIMMessage (DataProvider)

- (NSString *)getDisplayString
{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getDisplayString:self];
}

@end
