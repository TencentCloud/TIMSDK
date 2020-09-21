#import <Foundation/Foundation.h>
#import "TCServiceProtocol.h"


@interface TCContext : NSObject <NSCopying>

+ (instancetype)shareInstance;

- (void)addServiceWithImplInstance:(id)implInstance serviceName:(NSString *)serviceName;

- (void)removeServiceInstanceWithServiceName:(NSString *)serviceName;

- (id)getServiceInstanceFromServiceName:(NSString *)serviceName;

@end
