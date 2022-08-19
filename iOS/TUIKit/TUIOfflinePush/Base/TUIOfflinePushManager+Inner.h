//
//  TUIOfflinePushManager+Inner.h
//  Pods
//
//  Created by harvy on 2022/5/10.
//

#import "TUIOfflinePushManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIOfflinePushManager ()

#pragma mark - Private - Override
- (BOOL)supportTPNS;
- (void)applyPushToken;

#pragma mark - Private - Response

- (void)onReportToken:(NSData *)deviceToken;
- (void)onReceiveOfflinePushEntity:(NSDictionary *)entity;

@property (nonatomic, assign, readonly) int apnsCertificateID;

@property (nonatomic, copy, readonly) NSString *tpnsConfigDomain;
@property (nonatomic, assign, readonly) int tpnsConfigAccessID;
@property (nonatomic, copy, readonly) NSString *tpnsConfigAccessKey;

@property (nonatomic, strong, nullable) id<UIApplicationDelegate> applicationDelegate;
- (void)loadApplicationDelegateIfNeeded;
- (void)unloadApplicationDelegateIfNeeded;

- (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
