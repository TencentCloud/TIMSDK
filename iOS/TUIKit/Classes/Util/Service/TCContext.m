#import "TCContext.h"

@interface TCContext()

@property(nonatomic, strong) NSMutableDictionary *servicesByName;

@end

@implementation TCContext

+ (instancetype)shareInstance
{
    static dispatch_once_t p;
    static id TCInstance = nil;

    dispatch_once(&p, ^{
        TCInstance = [[[self class] alloc] init];
    });

    return TCInstance;
}

- (void)addServiceWithImplInstance:(id)implInstance serviceName:(NSString *)serviceName
{
    [[TCContext shareInstance].servicesByName setObject:implInstance forKey:serviceName];
}

- (void)removeServiceInstanceWithServiceName:(NSString *)serviceName
{
    [[TCContext shareInstance].servicesByName removeObjectForKey:serviceName];
}

- (id)getServiceInstanceFromServiceName:(NSString *)serviceName
{
    return [[TCContext shareInstance].servicesByName objectForKey:serviceName];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.servicesByName  = [[NSMutableDictionary alloc] initWithCapacity:1];
    }

    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    TCContext *context = [[self.class allocWithZone:zone] init];

    context.servicesByName = self.servicesByName;

    return context;
}

@end
