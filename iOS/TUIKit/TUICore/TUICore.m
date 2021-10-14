#import "TUICore.h"
#import <objc/runtime.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/ldsyms.h>

static NSMutableArray *serviceList = nil;
static NSMutableArray<NSMapTable *> *eventList = nil;
static NSMutableArray<NSMapTable *> *extensionList = nil;
static NSMutableDictionary *objectHashMap = nil;

@implementation TUICore

+ (void)initialize {
    serviceList = [NSMutableArray array];
    eventList = [NSMutableArray array];
    extensionList = [NSMutableArray array];
    objectHashMap = [NSMutableDictionary dictionary];
}

+ (void)registerService:(NSString *)serviceName object:(id<TUIServiceProtocol>)object {
    if (serviceName.length == 0) {
        NSLog(@"invalid serviceName");
        return;
    }
    if (object == nil) {
        NSLog(@"invalid object");
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"serviceName"] = serviceName;
    param[@"object"] = object;
    [serviceList addObject:param];
}

+ (id)callService:(NSString *)serviceName method:(NSString *)method param:(nullable NSDictionary *)param {
    if (serviceName.length == 0) {
        NSLog(@"invalid serviceName");
        NSAssert(NO, @"invalid serviceName");
        return nil;
    }
    if (method.length == 0) {
        NSLog(@"invalid method");
        NSAssert(NO, @"invalid method");
        return nil;
    }
    for (NSDictionary *service in serviceList) {
        NSString *pServiceName = service[@"serviceName"];
        if ([pServiceName isEqualToString:serviceName]) {
            id<TUIServiceProtocol> pObject = service[@"object"];
            if (pObject) {
                return [pObject onCall:method param:param];
            }
        }
    }
    
    return nil;
}

+ (void)registerEvent:(NSString *)key subKey:(NSString *)subKey object:(id<TUINotificationProtocol>)object {
    if (key.length == 0) {
        NSLog(@"invalid key");
        return;
    }
    if (subKey.length == 0) {
        subKey = @"";
    }
    
    NSMapTable *event = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:3];
    [event setObject:[key copy] forKey:@"key"];
    [event setObject:[subKey copy] forKey:@"subKey"];
    [event setObject:object forKey:@"object"];
    
    @synchronized (eventList) {
        [eventList addObject:event];
    }
}

+ (void)unRegisterEventByObject:(id<TUINotificationProtocol>)object {
    [self unRegisterEvent:nil subKey:nil object:object];
}
+ (void)unRegisterEvent:(nullable NSString *)key subKey:(nullable NSString *)subKey object:(nullable id<TUINotificationProtocol>)object {

    @synchronized (eventList) {
        
        NSMutableArray *removeEventList = [NSMutableArray array];
        for (NSMapTable *event in eventList) {
            NSString *pkey = [event objectForKey:@"key"];
            NSString *pSubKey = [event objectForKey:@"subKey"];
            id pObject = [event objectForKey:@"object"];
            
            if (pObject == nil) {
                [removeEventList addObject:event];
            }
            if (key == nil && subKey == nil && pObject == object) {
                [removeEventList addObject:event];
            }
            else if ([pkey isEqualToString:key] && subKey == nil && object == nil) {
                [removeEventList addObject:event];
            }
            else if ([pkey isEqualToString:key] && [subKey isEqualToString:pSubKey] && object == nil) {
                [removeEventList addObject:event];
            }
            else if ([pkey isEqualToString:key] && [subKey isEqualToString:pSubKey] && pObject == object) {
                [removeEventList addObject:event];
            }
        }
        [eventList removeObjectsInArray:removeEventList];
    }
}

+ (void)notifyEvent:(NSString *)key subKey:(NSString *)subKey object:(nullable id)anObject param:(nullable NSDictionary *)param {
    if (key.length == 0) {
        NSLog(@"invalid key");
        return;
    }
    if (subKey.length == 0) {
        subKey = @"";
    }
    
    @synchronized (eventList) {
        for (NSMapTable *event in eventList) {
            NSString *pkey = [event objectForKey:@"key"];
            NSString *pSubKey = [event objectForKey:@"subKey"];
            
            if ([pkey isEqualToString:key] && [pSubKey isEqualToString:subKey]) {
                id<TUINotificationProtocol> pObject = [event objectForKey:@"object"];
                if (pObject) {
                    [pObject onNotifyEvent:key subKey:subKey object:anObject param:param];
                }
            }
        }
    }
}

+ (void)registerExtension:(NSString *)key object:(id<TUIExtensionProtocol>)object {
    if (key.length == 0) {
        NSLog(@"invalid key");
        return;
    }
    if (object == nil) {
        NSLog(@"invalid object");
        return;
    }
    NSMapTable *extension = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:3];
    [extension setObject:[key copy] forKey:@"key"];
    [extension setObject:object forKey:@"object"];
    
    @synchronized (extensionList) {
        [extensionList addObject:extension];
    }
}

+ (void)unRegisterExtension:(NSString *)key object:(id<TUIExtensionProtocol>)object {
    if (key.length == 0) {
        NSLog(@"invalid key");
        return;
    }
    
    @synchronized (extensionList) {
        NSMutableArray *removeExtensionList = [NSMutableArray array];
        for (NSMapTable *extension in extensionList) {
            NSString *pkey = [extension objectForKey:@"key"];
            id pObject = [extension objectForKey:@"object"];
            
            if (pObject == nil) {
                [removeExtensionList addObject:extension];
            }
            else if ([pkey isEqualToString:key]) {
                [removeExtensionList addObject:extension];
            }
        }
        [extensionList removeObjectsInArray:removeExtensionList];
    }
}

+ (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param {
    if (key.length == 0) {
        NSLog(@"invalid key");
        return nil;
    }
    
    @synchronized (extensionList) {
        for (NSMapTable *extension in extensionList) {
            NSString *pkey = [extension objectForKey:@"key"];
            if ([pkey isEqualToString:key]) {
                id<TUIExtensionProtocol> pObject = [extension objectForKey:@"object"];
                if (pObject) {
                    NSDictionary *info = [pObject getExtensionInfo:key param:param];
                    if (info) {
                        return info;
                    }
                }
            }
        }
    }
    return nil;
}
@end
