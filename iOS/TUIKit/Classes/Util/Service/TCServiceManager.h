#import <Foundation/Foundation.h>
#import "TCAnnotation.h"

@interface TCServiceManager : NSObject

@property(nonatomic, assign) BOOL enableException;

+ (instancetype)shareInstance;

- (void)registerService:(Protocol *)service implClass:(Class)implClass;
- (void)registerService:(Protocol *)service implClass:(Class)implClass withPriority:(int)priority;

- (void)unregisterService:(Protocol *)service implClass:(Class)implClass;

- (id)createService:(Protocol *)service;
- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName;
- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName shouldCache:(BOOL)shouldCache;

- (id)getServiceInstance:(Protocol *)service;
- (void)removeServiceInstance:(Protocol *)service;

@end
