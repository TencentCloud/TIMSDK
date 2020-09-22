//
//  TIMMessage+DataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import "TIMMessage+DataProvider.h"
#import "TCServiceManager.h"
#import "TUIMessageDataProviderServiceProtocol.h"

@implementation V2TIMMessage (DataProvider)

-(id)cellData{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getCellData:self];
}

- (NSString *)getShowName
{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getShowName:self];
}

- (NSString *)getDisplayString
{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getDisplayString:self];
}

- (TUISystemMessageCellData *) revokeCellData{
    id<TUIMessageDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIMessageDataProviderServiceProtocol)];
    return [expr getRevokeCellData:self];
}

@end
