//
//  TUIOfflinePushManager.m
//  TUIOfflinePush
//
//  Created by harvy on 2022/5/6.
//

#import <ImSDK_Plus/ImSDK_Plus.h>
#import "TUIOfflinePushManager.h"
#import "TUIOfflinePushManager+Inner.h"
#import "TUIOfflinePushManager+Advance.h"

#define TUIOfflinePush_Business_NormalMsg  1
#define TUIOfflinePush_Business_Call       2

@implementation TUIOfflinePushManager

NSString *_groupID;
NSString *_userID;

+ (void)load
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onLoginSucc) name:@"TUILoginSuccessNotification" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onLogoutSucc) name:@"TUILogoutSuccessNotification" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onApplicationDidLaunch:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

static id _instance;

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}


+ (void)onLoginSucc
{
    if ([self.shareManager respondsToSelector:@selector(registerService)]) {
        [self.shareManager registerService];
    }
}

+ (void)onLogoutSucc
{
    if ([self.shareManager respondsToSelector:@selector(unregisterService)]) {
        [self.shareManager unregisterService];
    }
}

+ (void)onApplicationDidLaunch:(NSNotification *)notice
{
    if ([self.shareManager respondsToSelector:@selector(loadApplicationDelegateIfNeeded)]) {
        [self.shareManager loadApplicationDelegateIfNeeded];
    }
    
    if ([self.shareManager respondsToSelector:@selector(handleLanuchInfoIfNeeded:)] ) {
        [self.shareManager handleLanuchInfoIfNeeded:notice.userInfo];
    }
}

- (void)registerService
{
    NSLog(@"[TUIOfflinePushManager] %s", __func__);
    /**
     * 接管 appDelegate
     * Take over appDelegate
     */
    [self loadApplicationDelegateIfNeeded];
    
    /**
     * 新能力分发
     * Distrubute new ability
     */
    if ([self respondsToSelector:@selector(registerForVOIPPush)]) {
        [self registerForVOIPPush];
    }
    
    /**
     * 申请 token
     * Apply the push token
     */
    [self applyPushToken];
    
    /**
     * 响应离线推送
     * 当点击了通知栏的离线推送后启动 APP，先缓存当前的推送信息，登录成功之后再执行跳转
     *
     * Process received offline push
     * When the offline push notification bar is clicked, start the APP, and then cache the current push information first, and then execute the redirection after the login is successful.
     */
    [self onReceiveNormalMessageOfflinePush];
}

- (void)onReportToken:(NSData *)deviceToken
{
    NSLog(@"[TUIOfflinePushManager] %s", __func__);
    BOOL supportTPNS = NO;
    if ([self respondsToSelector:@selector(supportTPNS)]) {
        supportTPNS = [self supportTPNS];
    }
    if (deviceToken) {
        V2TIMAPNSConfig *confg = [[V2TIMAPNSConfig alloc] init];
        confg.businessID = self.apnsCertificateID;
        confg.token = deviceToken;
        confg.isTPNSToken = supportTPNS;
        [[V2TIMManager sharedInstance] setAPNS:confg succ:^{
             NSLog(@"%s, succ, %@, id:%zd", __func__, supportTPNS ? @"TPNS": @"APNS", confg.businessID);
        } fail:^(int code, NSString *msg) {
             NSLog(@"%s, fail, %d, %@", __func__, code, msg);
        }];
    }
}

- (void)handleLanuchInfoIfNeeded:(NSDictionary *)launchOptions
{
    if (launchOptions == nil || ![launchOptions isKindOfClass:NSDictionary.class] ||
        ![launchOptions.allKeys containsObject:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        return;
    }
    
    NSDictionary *remoteDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (![remoteDictionary isKindOfClass:NSDictionary.class] || ![remoteDictionary.allKeys containsObject:@"ext"]) {
        return;
    }
    NSDictionary *extParam = [self jsonSring2Dictionary:remoteDictionary[@"ext"]];
    if (extParam == nil ||
        ![extParam.allKeys containsObject:@"entity"]) {
        return;
    }
    
    NSDictionary *entity = extParam[@"entity"];
    [self onReceiveOfflinePushEntity:entity];
}

- (void)onReceiveOfflinePushEntity:(NSDictionary *)entity
{
    NSLog(@"[TUIOfflinePushManager] %s, %@", __func__, entity);

    BOOL filter = [self onReceiveRemoteNotification:entity];
    if (filter) {
        return;
    }
    
    if (entity == nil ||
        ![entity.allKeys containsObject:@"action"] ||
        ![entity.allKeys containsObject:@"chatType"]) {
        return;
    }
    
    NSString *action = entity[@"action"];
    NSString *chatType = entity[@"chatType"];
    if (action == nil || chatType == nil) {
        return;
    }

    if ([action intValue] == TUIOfflinePush_Business_NormalMsg) {
        if ([chatType intValue] == 1) {
            _userID = entity[@"sender"];
        } else if ([chatType intValue] == 2) {
            _groupID = entity[@"sender"];
        }
        if ([[V2TIMManager sharedInstance] getLoginStatus] == V2TIM_STATUS_LOGINED) {
            [self onReceiveNormalMessageOfflinePush];
        }
    }

    else if ([action intValue] == TUIOfflinePush_Business_Call) {
        /**
         * 如果是音视频通话，无需单独处理，TUICalling 内部会自动处理音视频通话
         * If it is an audio and video call, there is no need to handle it separately, TUICalling will automatically handle the audio and video call.
         */
    }
}

- (void)onReceiveNormalMessageOfflinePush
{
    NSLog(@"[TUIOfflinePushManager] %s, groupId:%@, userId:%@", __func__, _groupID, _userID);
    /**
     * 异步处理，防止出现时序问题, 特别是当前正在登录操作中
     * Asynchronous processing to prevent timing problems, especially when a login operation is currently in progress
     */
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_groupID.length > 0 || _userID.length > 0) {
            [weakSelf jumpToCustomVC:_userID groupID:_groupID];
            _groupID = nil;
            _userID = nil;
        }
    });
}


#pragma mark - Configuration
- (int)apnsCertificateID
{
    SEL selector = NSSelectorFromString(@"push_certificateIDForAPNS");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return 0;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    [invocation invoke];
    
    int busiID = 0;
    if (signature.methodReturnLength) {
        [invocation getReturnValue:&busiID];
    }
    
    return busiID;
}

- (NSString *)tpnsConfigDomain
{
    SEL selector = NSSelectorFromString(@"push_accessID:accessKey:domain:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    
    int accessID = 0;
    NSString *accessKey = nil;
    NSString *domain = nil;
    
    void *p_id = &accessID;
    void *p_accessKey = &accessKey;
    void *p_domain = &domain;
    [invocation setArgument:&p_id atIndex:2];
    [invocation setArgument:&p_accessKey atIndex:3];
    [invocation setArgument:&p_domain atIndex:4];

    [invocation invoke];
    
    return domain;
}

- (int)tpnsConfigAccessID
{
    SEL selector = NSSelectorFromString(@"push_accessID:accessKey:domain:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return 0;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    
    int accessID = 0;
    NSString *accessKey = nil;
    NSString *domain = nil;
    
    void *p_id = &accessID;
    void *p_accessKey = &accessKey;
    void *p_domain = &domain;
    [invocation setArgument:&p_id atIndex:2];
    [invocation setArgument:&p_accessKey atIndex:3];
    [invocation setArgument:&p_domain atIndex:4];
    
    [invocation invoke];
    
    return accessID;
}

- (NSString *)tpnsConfigAccessKey
{
    SEL selector = NSSelectorFromString(@"push_accessID:accessKey:domain:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    
    int accessID = 0;
    NSString *accessKey = nil;
    NSString *domain = nil;
    
    void *p_id = &accessID;
    void *p_accessKey = &accessKey;
    void *p_domain = &domain;
    [invocation setArgument:&p_id atIndex:2];
    [invocation setArgument:&p_accessKey atIndex:3];
    [invocation setArgument:&p_domain atIndex:4];
    
    [invocation invoke];
    
    return accessKey;
}

- (void)jumpToCustomVC:(NSString *)userID groupID:(NSString *)groupID
{
    SEL selector = NSSelectorFromString(@"navigateToTUIChatViewController:groupID:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    [invocation setArgument:&userID atIndex:2];
    [invocation setArgument:&groupID atIndex:3];
    [invocation invoke];
}

- (BOOL)onReceiveRemoteNotification:(NSDictionary *)userInfo
{
    SEL selector = NSSelectorFromString(@"processTUIOfflinePushNotification:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return NO;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    [invocation setArgument:&userInfo atIndex:2];
    [invocation invoke];
    BOOL filter = NO;
    if (signature.methodReturnLength) {
        [invocation getReturnValue:&filter];
    }
    return filter;
}

#pragma mark - Take over AppDelegate
- (void)loadApplicationDelegateIfNeeded
{
    if (![UIApplication.sharedApplication.delegate isEqual:self]) {
        self.applicationDelegate = UIApplication.sharedApplication.delegate;
        UIApplication.sharedApplication.delegate = self;
    }
}

- (void)unloadApplicationDelegateIfNeeded
{
    if (![self.applicationDelegate isEqual:self]) {
        UIApplication.sharedApplication.delegate = self.applicationDelegate;
        self.applicationDelegate = nil;
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL response = NO;
    if (self.applicationDelegate) {
        /**
         * 托管了
         * AppDelegate has been taken over
         */
        if ([self.applicationDelegate isEqual:self]) {
            /**
             * 错误情况 - 嵌套循环调用托管，导致 TUIOfflinePushManager 丢掉了 AppDelegate 的引用
             * 尽可能的不 crash
             *
             * Error Condition - Nested loop calls cause TUIOfflinePushManager to lose reference to AppDelegate
             * Try not to crash as much as possible
             */
            if ([NSStringFromSelector(aSelector) isEqualToString:@"respondsToSelector:"]) {
                /**
                 * 此时已经死循环了，直接返回 NO 以避免 crash
                 * At this point, it is already in an infinite loop, return NO directly to avoid crash
                 */
                return NO;
            } else {
                response = [super respondsToSelector:aSelector];
            }
        } else {
            /**
             * 托管的是业务层的 AppDelegate
             * At this point, the AppDelegate of the business layer has been taken over
             */
            
            /**
             * 优先判断业务的 AppDelegate 是否实现该方法
             * - 业务如果实现了，TUIOfflinePushManager 就认为自己实现了
             * - 当 TUIOfflinePushManager 实际未实现该方法时，会走「快速转发」流程，再次将消息转发给 AppDelegate
             *
             * Prioritize whether the AppDelegate implements this method
             * - If the AppDelegate implements it, TUIOfflinePushManager thinks it has implemented it
             * - When TUIOfflinePushManager does not actually implement this method, it will go through the "fast forwarding" process and forward the message to AppDelegate again
             */
            response = [self.applicationDelegate respondsToSelector:aSelector];
            
            /**
             * 如果业务层没实现，再判断自己是否实现
             * If the AppDelegate does not implement this method, then judge whether it is implemented by itself
             */
            if (response == NO) {
                response = [super respondsToSelector:aSelector];
            }
        }
    } else {
        /**
         * 托管了
         * AppDelegate has not been taken over
         */
        response = [super respondsToSelector:aSelector];
    }
    return response;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.applicationDelegate respondsToSelector:aSelector]) {
        return self.applicationDelegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - Utils
- (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Json parse failed: %@", jsonString);
        return nil;
    }
    return dic;
}

@end
