//
//  TUICustomerServicePluginConfig.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/6/16.
//

#import "TUICustomerServicePluginConfig.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import "TUICustomerServicePluginMenuView.h"
#import "TUICustomerServicePluginDataProvider.h"
#import "TUICustomerServicePluginExtensionObserver.h"
#import "TUICustomerServicePluginPrivateConfig.h"
#import "TUICustomerServicePluginProductInfo.h"

#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation TUICustomerServicePluginConfig

+ (TUICustomerServicePluginConfig *)sharedInstance {
    static dispatch_once_t onceToken;
    static TUICustomerServicePluginConfig * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUICustomerServicePluginConfig alloc] init];
        
    });
    return g_sharedInstance;
}

#pragma mark - Public
- (void)setCustomerServiceAccounts:(NSArray *)customerServiceAccounts {
    [TUICustomerServicePluginPrivateConfig sharedInstance].customerServiceAccounts = customerServiceAccounts;
}

- (NSArray *)menuItems {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pluginConfig:shouldUpdateOldMenuItems:)]) {
        return [self.delegate pluginConfig:self shouldUpdateOldMenuItems:[self defaultMenuItems]];
    }
    return [self defaultMenuItems];
}

- (NSArray *)commonPhrases {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pluginConfig:shouldUpdateCommonPhrases:)]) {
        return [self.delegate pluginConfig:self shouldUpdateCommonPhrases:[self defaultCommonPhrases]];
    }
    return [self defaultCommonPhrases];
}

- (TUICustomerServicePluginProductInfo *)productInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pluginConfigShouldUpdateProductInfo:)]) {
        return [self.delegate pluginConfigShouldUpdateProductInfo:self];
    }
    return [self defaultProductInfo];
}

#pragma mark - Private
- (NSArray *)defaultMenuItems {
    NSMutableArray *dataSource = [NSMutableArray new];
    
    TUICustomerServicePluginMenuCellData *product = [TUICustomerServicePluginMenuCellData new];
    product.title = TIMCommonLocalizableString(TUICustomerServiceSendProduct);
    product.target = TUICustomerServicePluginExtensionObserver.shareInstance;
    product.cselector = @selector(onProductClicked);
    [dataSource addObject:product];
    
    TUICustomerServicePluginMenuCellData *phase = [TUICustomerServicePluginMenuCellData new];
    phase.title = TIMCommonLocalizableString(TUICustomerServiceCommonPhrase);
    phase.target = TUICustomerServicePluginExtensionObserver.shareInstance;
    phase.cselector = @selector(onPhraseClicked);
    [dataSource addObject:phase];
    
    return [dataSource copy];
}

- (NSArray *)defaultCommonPhrases {
    return @[
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseStock),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseCheaper),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseGift),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseShipping),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseDelivery),
        TIMCommonLocalizableString(TUICustomerServiceCommonPhraseArrive),
    ];
}

- (TUICustomerServicePluginProductInfo *)defaultProductInfo {
    TUICustomerServicePluginProductInfo *info = [TUICustomerServicePluginProductInfo new];
    info.title = @"手工编织皮革提包2023新品女士迷你简约大方高端有档次";
    info.desc = @"¥788";
    info.picURL = @"https://qcloudimg.tencent-cloud.cn/raw/a811f634eab5023f973c9b224bc07a51.png";
    info.linkURL = @"https://cloud.tencent.com/document/product/269";
    return info;
}

@end
