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

#define TUIOfflinePush_Business_NormalMsg  1  //普通消息推送
#define TUIOfflinePush_Business_Call       2  //音视频通话推送

@implementation TUIOfflinePushManager

NSString *_groupID;
NSString *_userID;

+ (void)load
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onLoginSucc) name:@"TUILoginSuccessNotification" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onLogoutSucc) name:@"TUILogoutSuccessNotification" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onApplicationDidLaunch) name:UIApplicationDidFinishLaunchingNotification object:nil];
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

+ (void)onApplicationDidLaunch
{
    if ([self.shareManager respondsToSelector:@selector(loadApplicationDelegateIfNeeded)]) {
        [self.shareManager loadApplicationDelegateIfNeeded];
    }
}

- (void)registerService
{
    NSLog(@"[TUIOfflinePushManager] %s", __func__);
    // 0. 接管 appDelegate
    [self loadApplicationDelegateIfNeeded];
    
    // 1. 申请 token
    [self applyPushToken];
    
    // 2. 响应离线推送
    // - 当点击了通知栏的离线推送后启动 APP，先缓存当前的推送信息，登录成功之后再执行跳转
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
        // 企业证书 ID
        // 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，
        // 控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。
        confg.businessID = self.apnsCertificateID;
        confg.token = deviceToken;
        confg.isTPNSToken = supportTPNS;
        [[V2TIMManager sharedInstance] setAPNS:confg succ:^{
             NSLog(@"%s, succ, %@", __func__, supportTPNS ? @"TPNS": @"APNS");
        } fail:^(int code, NSString *msg) {
             NSLog(@"%s, fail, %d, %@", __func__, code, msg);
        }];
    }
}

- (void)onReceiveOfflinePushEntity:(NSDictionary *)entity
{
    NSLog(@"[TUIOfflinePushManager] %s, %@", __func__, entity);

    // 回调业务层，如果业务层返回YES，则不再执行默认逻辑
    BOOL filter = [self onReceiveRemoteNotification:entity];
    if (filter) {
        return;
    }
    
    // 默认逻辑
    if (entity == nil ||
        ![entity.allKeys containsObject:@"action"] ||
        ![entity.allKeys containsObject:@"chatType"]) {
        return;
    }
    // 业务，   action : 1 普通文本推送；2 音视频通话推送
    // 聊天类型，chatType : 1 单聊；2 群聊
    NSString *action = entity[@"action"];
    NSString *chatType = entity[@"chatType"];
    if (action == nil || chatType == nil) {
        return;
    }

    // action : 1 普通消息推送
    if ([action intValue] == TUIOfflinePush_Business_NormalMsg) {
        if ([chatType intValue] == 1) {   //C2C
            _userID = entity[@"sender"];
        } else if ([chatType intValue] == 2) { //Group
            _groupID = entity[@"sender"];
        }
        if ([[V2TIMManager sharedInstance] getLoginStatus] == V2TIM_STATUS_LOGINED) {
            [self onReceiveNormalMessageOfflinePush];
        }
    }
    // action : 2 音视频通话推送
    else if ([action intValue] == TUIOfflinePush_Business_Call) {
        // 如果是音视频通话，无需单独处理，TUIKit (TUICalling 内部会自动处理音视频通话)
    }
}

- (void)onReceiveNormalMessageOfflinePush
{
    NSLog(@"[TUIOfflinePushManager] %s, groupId:%@, userId:%@", __func__, _groupID, _userID);
    // 异步处理，防止出现时序问题, 特别是当前正在登录操作中
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_groupID.length > 0 || _userID.length > 0) {
            [weakSelf jumpToCustomVC:_userID groupID:_groupID];
            _groupID = nil;
            _userID = nil;
        }
    });
}


#pragma mark - 配置参数及回调
// 获取 apns 的证书 ID
- (int)apnsCertificateID
{
    // 反射方法
    SEL selector = NSSelectorFromString(@"push_certificateIDForAPNS");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return 0;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    
    // 调用方法
    [invocation invoke];
    
    // 获取返回值
    int busiID = 0;
    if (signature.methodReturnLength) {
        [invocation getReturnValue:&busiID];
    }
    
    return busiID;
}

- (NSString *)tpnsConfigDomain
{
    // 反射方法
    SEL selector = NSSelectorFromString(@"push_accessID:accessKey:domain:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    
    // 设置参数
    int accessID = 0;
    NSString *accessKey = nil;
    NSString *domain = nil;
    
    void *p_id = &accessID;
    void *p_accessKey = &accessKey;
    void *p_domain = &domain;
    [invocation setArgument:&p_id atIndex:2];
    [invocation setArgument:&p_accessKey atIndex:3];
    [invocation setArgument:&p_domain atIndex:4];
    
    // 调用方法
    [invocation invoke];
    
    return domain;
}

- (int)tpnsConfigAccessID
{
    // 反射方法
    SEL selector = NSSelectorFromString(@"push_accessID:accessKey:domain:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return 0;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    
    // 设置参数
    int accessID = 0;
    NSString *accessKey = nil;
    NSString *domain = nil;
    
    void *p_id = &accessID;
    void *p_accessKey = &accessKey;
    void *p_domain = &domain;
    [invocation setArgument:&p_id atIndex:2];
    [invocation setArgument:&p_accessKey atIndex:3];
    [invocation setArgument:&p_domain atIndex:4];
    
    // 调用方法
    [invocation invoke];
    
    return accessID;
}

- (NSString *)tpnsConfigAccessKey
{
    // 反射方法
    SEL selector = NSSelectorFromString(@"push_accessID:accessKey:domain:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return nil;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    
    // 设置参数
    int accessID = 0;
    NSString *accessKey = nil;
    NSString *domain = nil;
    
    void *p_id = &accessID;
    void *p_accessKey = &accessKey;
    void *p_domain = &domain;
    [invocation setArgument:&p_id atIndex:2];
    [invocation setArgument:&p_accessKey atIndex:3];
    [invocation setArgument:&p_domain atIndex:4];
    
    // 调用方法
    [invocation invoke];
    
    return accessKey;
}

// 点击推送后统一跳转
- (void)jumpToCustomVC:(NSString *)userID groupID:(NSString *)groupID
{
    // 反射方法
    SEL selector = NSSelectorFromString(@"navigateToTUIChatViewController:groupID:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    
    // 设置参数
    [invocation setArgument:&userID atIndex:2];
    [invocation setArgument:&groupID atIndex:3];
    
    // 调用方法
    [invocation invoke];
}

// 收到离线推送
- (BOOL)onReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 反射方法
    SEL selector = NSSelectorFromString(@"processTUIOfflinePushNotification:");
    NSMethodSignature *signature = [self.applicationDelegate.class instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        return NO;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.applicationDelegate;
    invocation.selector = selector;
    
    // 设置参数
    [invocation setArgument:&userInfo atIndex:2];
    
    
    // 调用方法
    [invocation invoke];
    
    // 获取返回值
    BOOL filter = NO;
    if (signature.methodReturnLength) {
        [invocation getReturnValue:&filter];
    }
    
    return filter;
}

#pragma mark - 接管系统 AppDelegate
// 接管系统代理
- (void)loadApplicationDelegateIfNeeded
{
    // 接管系统 appDelegate
    if (![UIApplication.sharedApplication.delegate isEqual:self]) {
        self.applicationDelegate = UIApplication.sharedApplication.delegate;
        UIApplication.sharedApplication.delegate = self;
    }
}

// 恢复系统代理
- (void)unloadApplicationDelegateIfNeeded
{
    // 恢复系统 delegate
    if (![self.applicationDelegate isEqual:self]) {
        UIApplication.sharedApplication.delegate = self.applicationDelegate;
        self.applicationDelegate = nil;
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL response = NO;
    if (self.applicationDelegate) {
        // 托管了
        if ([self.applicationDelegate isEqual:self]) {
            // 错误情况 - 嵌套循环调用托管，导致 TUIOfflinePushManager 丢掉了 AppDelegate 的引用
            // 尽可能的不 crash
            if ([NSStringFromSelector(aSelector) isEqualToString:@"respondsToSelector:"]) {
                // 此时已经死循环了，直接返回 NO 以避免 crash
                return NO;
            } else {
                response = [super respondsToSelector:aSelector];
            }
        } else {
            // 托管的是业务层的 AppDelegate
            // 1. 优先判断业务的 AppDelegate 是否实现该方法
            //   业务如果实现了，TUIOfflinePushManager 就认为自己实现了
            //   当 TUIOfflinePushManager 实际未实现该方法时，会走「快速转发」流程，再次将消息转发给 AppDelegate
            response = [self.applicationDelegate respondsToSelector:aSelector];
            
            // 2. 如果业务层没实现，再判断自己是否实现
            if (response == NO) {
                response = [super respondsToSelector:aSelector];
            }
        }
    } else {
        // 未托管
        response = [super respondsToSelector:aSelector];
    }
    return response;
}

// 快速转发
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.applicationDelegate respondsToSelector:aSelector]) {
        return self.applicationDelegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end
