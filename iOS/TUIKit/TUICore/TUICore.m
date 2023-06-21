
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUICore.h"

#import <objc/runtime.h>

#import "TUIDefine.h"
#import "TUIThemeManager.h"
#import "TUIWeakProxy.h"

@implementation TUICore

+ (void)initialize {
    TUIRegisterThemeResourcePath(TUICoreThemePath, TUIThemeModuleCore);
    TUIRegisterThemeResourcePath(TUIBundlePath(@"TUICoreTheme_Minimalist", TUICoreBundle_Key_Class), TUIThemeModuleCore_Minimalist);
}

+ (void)registerService:(NSString *)serviceName object:(id<TUIServiceProtocol>)object {
    [TUIServiceManager.shareInstance registerService:serviceName service:object];
}

+ (void)unregisterService:(NSString *)serviceName {
    [TUIServiceManager.shareInstance unregisterService:serviceName];
}

+ (id<TUIServiceProtocol>)getService:(NSString *)serviceName {
    return [TUIServiceManager.shareInstance getService:serviceName];
}

+ (id)callService:(NSString *)serviceName method:(NSString *)method param:(nullable NSDictionary *)param {
    return [TUIServiceManager.shareInstance callService:serviceName method:method param:param resultCallback:nil];
}

+ (id)callService:(NSString *)serviceName
            method:(NSString *)method
             param:(nullable NSDictionary *)param
    resultCallback:(nullable TUICallServiceResultCallback)resultCallback {
    return [TUIServiceManager.shareInstance callService:serviceName method:method param:param resultCallback:resultCallback];
}

+ (void)registerEvent:(NSString *)key subKey:(NSString *)subKey object:(id<TUINotificationProtocol>)object {
    [TUIEventManager.shareInstance registerEvent:key subKey:subKey object:object];
}

+ (void)unRegisterEventByObject:(id<TUINotificationProtocol>)object {
    [TUIEventManager.shareInstance unRegisterEvent:object];
}
+ (void)unRegisterEvent:(nullable NSString *)key subKey:(nullable NSString *)subKey object:(nullable id<TUINotificationProtocol>)object {
    [TUIEventManager.shareInstance unRegisterEvent:key subKey:subKey object:object];
}

+ (void)notifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param {
    [TUIEventManager.shareInstance notifyEvent:key subKey:subKey object:anObject param:param];
}

+ (void)registerExtension:(NSString *)extensionID object:(id<TUIExtensionProtocol>)object {
    [TUIExtensionManager.shareInstance registerExtension:extensionID extension:object];
}

+ (void)unRegisterExtension:(NSString *)extensionID object:(id<TUIExtensionProtocol>)object {
    [TUIExtensionManager.shareInstance unRegisterExtension:extensionID extension:object];
}

+ (NSDictionary *)getExtensionInfo:(NSString *)extensionID param:(nullable NSDictionary *)param {
    return [TUIExtensionManager.shareInstance getExtensionInfo:extensionID param:param];
}

+ (NSArray<TUIExtensionInfo *> *)getExtensionList:(NSString *)extensionID param:(nullable NSDictionary *)param {
    return [TUIExtensionManager.shareInstance getExtensionList:extensionID param:param];
}

+ (BOOL)raiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param {
    return [TUIExtensionManager.shareInstance raiseExtension:extensionID parentView:parentView param:param];
}

+ (void)registerObjectFactory:(NSString *)factoryName objectFactory:(id<TUIObjectProtocol>)objectFactory {
    [TUIObjectFactoryManager.shareInstance registerObjectFactory:factoryName objectFactory:objectFactory];
}

+ (void)unRegisterObjectFactory:(NSString *)factoryName {
    [TUIObjectFactoryManager.shareInstance unRegisterObjectFactory:factoryName];
}

+ (id)createObject:(NSString *)factoryName key:(NSString *)key param:(NSDictionary *)param {
    return [TUIObjectFactoryManager.shareInstance createObject:factoryName method:key param:param];
}

@end

#pragma mark - TUIRoute

static const void *navigateValueCallback = @"navigateValueCallback";

@implementation NSObject (TUIRoute)

- (void)setNavigateValueCallback:(TUIValueResultCallback)callback {
    objc_setAssociatedObject(self, navigateValueCallback, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (TUIValueResultCallback)navigateValueCallback {
    return objc_getAssociatedObject(self, navigateValueCallback);
}

@end

@implementation UIViewController (TUIRoute)

- (void)pushViewController:(NSString *)viewControllerKey param:(nullable NSDictionary *)param forResult:(nullable TUIValueResultCallback)callback {
    NSAssert([self isKindOfClass:UINavigationController.class], @"self must be a navigation controller");
    UIViewController *vc = [TUIObjectFactoryManager.shareInstance createObject:viewControllerKey param:param];
    if ([vc isKindOfClass:UIViewController.class]) {
        vc.navigateValueCallback = callback;
        [(UINavigationController *)self pushViewController:vc animated:YES];
    } else {
        NSAssert(false, @"viewControllerKey not exists or invalid");
    }
}

- (void)presentViewController:(NSString *)viewControllerKey param:(nullable NSDictionary *)param forResult:(nullable TUIValueResultCallback)callback {
    [self presentViewController:viewControllerKey param:param embbedIn:nil forResult:callback];
}

- (void)presentViewController:(NSString *)viewControllerKey
                        param:(nullable NSDictionary *)param
                     embbedIn:(nullable UINavigationController *)navigationVC
                    forResult:(nullable TUIValueResultCallback)callback {
    UIViewController *vc = [TUIObjectFactoryManager.shareInstance createObject:viewControllerKey param:param];
    if ([vc isKindOfClass:UIViewController.class]) {
        vc.navigateValueCallback = callback;
        if (navigationVC) {
            if ([navigationVC isKindOfClass:UINavigationController.class]) {
                NSMutableArray *arrayM = [NSMutableArray array];
                if (navigationVC.viewControllers.count > 0) {
                    [arrayM addObjectsFromArray:navigationVC.viewControllers];
                }
                [arrayM addObject:vc];
                navigationVC.viewControllers = [NSArray arrayWithArray:arrayM];
                [self presentViewController:navigationVC animated:YES completion:nil];
            } else {
                NSAssert(false, @"navigationVC must be a navigation controller");
            }
        } else {
            [self presentViewController:vc animated:YES completion:nil];
        }
    } else {
        NSAssert(false, @"viewControllerKey not exists or invalid");
    }
}

@end

#pragma mark - TUIService

@interface TUIServiceManager ()

@property(nonatomic, strong) NSMapTable<NSString *, id<TUIServiceProtocol>> *serviceMap;

@end

@implementation TUIServiceManager

+ (instancetype)shareInstance {
    static id instance = nil;
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          instance = [[self alloc] init];
        });
    }
    return instance;
}

- (void)registerService:(NSString *)serviceName service:(id<TUIServiceProtocol>)service {
    NSAssert(serviceName.length > 0, @"invalid service name");
    NSAssert(service != nil, @"invalid service");

    if (serviceName && service) {
        @synchronized(self.serviceMap) {
            [self.serviceMap setObject:service forKey:serviceName];
        }
    }
}

- (void)unregisterService:(NSString *)serviceName {
    NSAssert(serviceName.length > 0, @"invalid service name");

    if (serviceName) {
        @synchronized(self.serviceMap) {
            [self.serviceMap removeObjectForKey:serviceName];
        }
    }
}

- (nullable id<TUIServiceProtocol>)getService:(NSString *)serviceName {
    id<TUIServiceProtocol> service = nil;
    @synchronized(self.serviceMap) {
        service = [self.serviceMap objectForKey:serviceName];
    }
    return service;
}

- (nullable id)callService:(NSString *)serviceName
                    method:(NSString *)method
                     param:(nullable NSDictionary *)param
            resultCallback:(nullable TUICallServiceResultCallback)resultCallback {
    NSAssert(serviceName.length > 0, @"invalid service name");
    NSAssert(method.length > 0, @"invalid method");

    id<TUIServiceProtocol> service = [self getService:serviceName];
    id result = nil;
    if (resultCallback) {
        if (service && [service respondsToSelector:@selector(onCall:param:resultCallback:)]) {
            result = [service onCall:method param:param resultCallback:resultCallback];
        }
    } else {
        if (service && [service respondsToSelector:@selector(onCall:param:)]) {
            result = [service onCall:method param:param];
        }
    }

    return result;
}

- (NSMapTable<NSString *, id<TUIServiceProtocol>> *)serviceMap {
    if (_serviceMap == nil) {
        _serviceMap = [NSMapTable strongToWeakObjectsMapTable];
    }
    return _serviceMap;
}

@end

#pragma mark - TUIEvent

@interface TUIEventManager ()

@property(nonatomic, strong) NSMutableArray<NSDictionary *> *eventList;

@end

@implementation TUIEventManager

+ (instancetype)shareInstance {
    static id instance = nil;
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          instance = [[self alloc] init];
        });
    }
    return instance;
}

- (void)registerEvent:(NSString *)key subKey:(NSString *)subKey object:(id<TUINotificationProtocol>)object {
    NSAssert(key.length > 0, @"invalid key");
    NSAssert(object != nil, @"invalid object");

    if (subKey.length == 0) {
        subKey = @"";
    }

    if (key && subKey && object) {
        NSDictionary *event = @{@"key" : [key copy], @"subKey" : [subKey copy], @"object" : [TUIWeakProxy proxyWithTarget:object]};

        @synchronized(self.eventList) {
            [self.eventList addObject:event];
        }
    }
}

- (void)unRegisterEvent:(id<TUINotificationProtocol>)object {
    [self unRegisterEvent:nil subKey:nil object:object];
}

- (void)unRegisterEvent:(nullable NSString *)key subKey:(nullable NSString *)subKey object:(nullable id<TUINotificationProtocol>)object {
    @synchronized(self.eventList) {
        NSMutableArray *removeEventList = [NSMutableArray array];
        for (NSDictionary *event in self.eventList) {
            NSString *pkey = [event objectForKey:@"key"];
            NSString *pSubKey = [event objectForKey:@"subKey"];
            id pObject = [event objectForKey:@"object"];

            if (pObject == nil || [(TUIWeakProxy *)pObject target] == nil) {
                [removeEventList addObject:event];
            }
            if (key == nil && subKey == nil && pObject == object) {
                [removeEventList addObject:event];
            } else if ([pkey isEqualToString:key] && subKey == nil && object == nil) {
                [removeEventList addObject:event];
            } else if ([pkey isEqualToString:key] && [subKey isEqualToString:pSubKey] && object == nil) {
                [removeEventList addObject:event];
            } else if ([pkey isEqualToString:key] && [subKey isEqualToString:pSubKey] && pObject == object) {
                [removeEventList addObject:event];
            }
        }
        [self.eventList removeObjectsInArray:removeEventList];
    }
}

- (void)notifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)object param:(nullable NSDictionary *)param {
    NSAssert(key.length > 0, @"invalid key");

    if (subKey.length == 0) {
        subKey = @"";
    }

    @synchronized(self.eventList) {
        for (NSDictionary *event in self.eventList) {
            NSString *pkey = [event objectForKey:@"key"];
            NSString *pSubKey = [event objectForKey:@"subKey"];

            if ([pkey isEqualToString:key] && [pSubKey isEqualToString:subKey]) {
                id<TUINotificationProtocol> pObject = [event objectForKey:@"object"];
                if (pObject) {
                    [pObject onNotifyEvent:key subKey:subKey object:object param:param];
                }
            }
        }
    }
}

- (NSMutableArray<NSDictionary *> *)eventList {
    if (_eventList == nil) {
        _eventList = [NSMutableArray array];
    }
    return _eventList;
}

@end

#pragma mark - TUIExtension

@implementation TUIExtensionInfo

@end

@interface TUIExtensionManager ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSHashTable<id<TUIExtensionProtocol>> *> *extensionMap;

@end

@implementation TUIExtensionManager

+ (instancetype)shareInstance {
    static id instance = nil;
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          instance = [[self alloc] init];
        });
    }
    return instance;
}

- (void)registerExtension:(NSString *)extensionID extension:(id<TUIExtensionProtocol>)extension {
    NSAssert(extensionID.length > 0, @"invalid extension id");
    NSAssert(extension != nil, @"invalid extension");

    if (extensionID && extension) {
        @synchronized(self.extensionMap) {
            NSHashTable *list = [self.extensionMap objectForKey:extensionID];
            if (list == nil) {
                list = [NSHashTable weakObjectsHashTable];
            }
            [list addObject:extension];
            [self.extensionMap setObject:list forKey:extensionID];
        }
    }
}

- (void)unRegisterExtension:(NSString *)extensionID extension:(id<TUIExtensionProtocol>)extension {
    NSAssert(extensionID.length > 0, @"invalid extension id");
    NSAssert(extension != nil, @"invalid extension");

    if (extensionID && extension) {
        @synchronized(self.extensionMap) {
            NSHashTable *list = [self.extensionMap objectForKey:extensionID];
            if (list == nil) {
                list = [NSHashTable weakObjectsHashTable];
            }
            [list removeObject:extension];
            [self.extensionMap setObject:list forKey:extensionID];
        }
    }
}

- (NSArray<TUIExtensionInfo *> *)getExtensionList:(NSString *)extensionID param:(nullable NSDictionary *)param {
    NSAssert(extensionID.length > 0, @"invalid extension id");

    NSHashTable *list = nil;
    @synchronized(self.extensionMap) {
        list = [self.extensionMap objectForKey:extensionID];
    }
    if (list == nil || list.count == 0) {
        return @[];
    }

    // get
    NSMutableArray *resultExtensionInfoList = [NSMutableArray array];
    for (id<TUIExtensionProtocol> observer in list) {
        if (observer && [observer respondsToSelector:@selector(onGetExtension:param:)]) {
            NSArray<TUIExtensionInfo *> *infoList = [observer onGetExtension:extensionID param:param];
            if (infoList) {
                [resultExtensionInfoList addObjectsFromArray:infoList];
            }
        }
    }

    // sort
    NSArray *result = [resultExtensionInfoList sortedArrayUsingComparator:^NSComparisonResult(TUIExtensionInfo *obj1, TUIExtensionInfo *obj2) {
      if (obj1.weight > obj2.weight) {
          return NSOrderedAscending;
      } else {
          return NSOrderedDescending;
      }
    }];

    return result;
}

- (BOOL)raiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param {
    NSAssert(extensionID.length > 0, @"invalid extension id");
    NSAssert(parentView != nil, @"invalid parent view");

    NSHashTable *list = nil;
    @synchronized(self.extensionMap) {
        list = [self.extensionMap objectForKey:extensionID];
    }
    if (list == nil || list.count == 0) {
        return NO;
    }

    BOOL isResponserExist = NO;
    for (id<TUIExtensionProtocol> observer in list) {
        if (observer && [observer respondsToSelector:@selector(onRaiseExtension:parentView:param:)]) {
            isResponserExist = [observer onRaiseExtension:extensionID parentView:parentView param:param];
            if (isResponserExist) {
                break;
            }
        }
    }
    return isResponserExist;
}

- (NSDictionary *)getExtensionInfo:(NSString *)extensionID param:(nullable NSDictionary *)param {
    NSAssert(extensionID.length > 0, @"invalid extension id");

    NSHashTable *list = nil;
    @synchronized(self.extensionMap) {
        list = [self.extensionMap objectForKey:extensionID];
    }
    if (list == nil || list.count == 0) {
        return nil;
    }

    for (id<TUIExtensionProtocol> observer in list) {
        if (observer && [observer respondsToSelector:@selector(onGetExtensionInfo:param:)]) {
            NSDictionary *info = [observer onGetExtensionInfo:extensionID param:param];
            if (info) {
                return info;
            }
        }
    }
    return nil;
}

- (NSMutableDictionary<NSString *, NSHashTable<id<TUIExtensionProtocol>> *> *)extensionMap {
    if (_extensionMap == nil) {
        _extensionMap = [NSMutableDictionary dictionary];
    }
    return _extensionMap;
}
@end

#pragma mark - TUIObjectFactory

@interface TUIObjectFactoryManager ()

@property(nonatomic, strong) NSMapTable<NSString *, id<TUIObjectProtocol>> *objectFactoryMap;

@end

@implementation TUIObjectFactoryManager : NSObject

+ (instancetype)shareInstance {
    static id instance = nil;
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          instance = [[self alloc] init];
        });
    }
    return instance;
}

- (void)registerObjectFactory:(NSString *)factoryName objectFactory:(id<TUIObjectProtocol>)objectFactory {
    NSAssert(factoryName.length > 0, @"invalid factory name");
    NSAssert(objectFactory != nil, @"invalid object factory");

    if (factoryName && objectFactory) {
        @synchronized(self.objectFactoryMap) {
            [self.objectFactoryMap setObject:objectFactory forKey:factoryName];
        }
    }
}

- (void)unRegisterObjectFactory:(NSString *)factoryName {
    NSAssert(factoryName.length > 0, @"invalid factory name");

    if (factoryName) {
        @synchronized(self.objectFactoryMap) {
            [self.objectFactoryMap removeObjectForKey:factoryName];
        }
    }
}

- (nullable id)createObject:(NSString *)factoryName method:(NSString *)method param:(nullable NSDictionary *)param {
    NSAssert(factoryName.length > 0, @"invalid factory name");
    NSAssert(method.length > 0, @"invalid method");

    id<TUIObjectProtocol> factory = nil;
    @synchronized(self.objectFactoryMap) {
        factory = [self.objectFactoryMap objectForKey:factoryName];
    }

    if (factory && [factory respondsToSelector:@selector(onCreateObject:param:)]) {
        return [factory onCreateObject:method param:param];
    }

    return nil;
}

- (nullable id)createObject:(NSString *)method param:(NSDictionary *)param {
    NSAssert(method.length > 0, @"invalid method");

    NSArray<id<TUIObjectProtocol>> *list = nil;
    @synchronized(self.objectFactoryMap) {
        list = self.objectFactoryMap.objectEnumerator.allObjects;
    }
    if (list == nil || list.count == 0) {
        return nil;
    }

    for (id<TUIObjectProtocol> factory in list) {
        if (factory && [factory respondsToSelector:@selector(onCreateObject:param:)]) {
            id obj = [factory onCreateObject:method param:param];
            if (obj) {
                return obj;
            }
        }
    }

    return nil;
}

- (NSMapTable<NSString *, id<TUIObjectProtocol>> *)objectFactoryMap {
    if (_objectFactoryMap == nil) {
        _objectFactoryMap = [NSMapTable strongToWeakObjectsMapTable];
    }
    return _objectFactoryMap;
}

@end
