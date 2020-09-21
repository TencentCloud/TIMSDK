#import "TCServiceManager.h"
#import "TCContext.h"
#import <objc/runtime.h>

@interface TCServiceItem : NSObject
@property int priority;
@property NSString *className;
@end

@implementation TCServiceItem

- (NSComparisonResult)compare:(TCServiceItem *)obj
{
    if (self.priority < obj.priority) {
        return (NSComparisonResult)NSOrderedDescending;
    }

    if (self.priority > obj.priority) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
}

@end

@interface TCServiceManager()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<TCServiceItem *> *> *allServicesDict;
@property (nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation TCServiceManager

+ (instancetype)shareInstance
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)registerService:(Protocol *)service implClass:(Class)implClass
{
    [self registerService:service implClass:implClass withPriority:INT_MAX];
}

- (void)registerService:(Protocol *)service implClass:(Class)implClass withPriority:(int)priority
{
    NSParameterAssert(service != nil);
    NSParameterAssert(implClass != nil);

    if (![implClass conformsToProtocol:service]) {
        if (self.enableException) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ module does not comply with %@ protocol", NSStringFromClass(implClass), NSStringFromProtocol(service)] userInfo:nil];
        }
        return;
    }


    NSString *key = NSStringFromProtocol(service);
    NSString *value = NSStringFromClass(implClass);

    if (key.length > 0 && value.length > 0) {
        TCServiceItem *item = TCServiceItem.new;
        item.priority = priority;
        item.className = value;

        [self.lock lock];
        NSMutableArray *items = [self.allServicesDict objectForKey:key];
        if (!items) {
            self.allServicesDict[key] = [NSMutableArray arrayWithObject:item];
        } else {
            [items insertObject:item atIndex:0];
            [items sortUsingSelector:@selector(compare:)];
            // set higher priority class to be used instance
            if (items.firstObject == item) {
                [self removeServiceInstance:service];
            }
        }
        [self.lock unlock];
    }
}

- (void)unregisterService:(Protocol *)service implClass:(Class)implClass;
{
    NSParameterAssert(service != nil);
    NSParameterAssert(implClass != nil);

    NSString *key = NSStringFromProtocol(service);
    NSString *value = NSStringFromClass(implClass);

    if (key.length > 0 && value.length > 0) {
        [self.lock lock];
        NSMutableArray<TCServiceItem *> *items = [self.allServicesDict objectForKey:key];
        if (items && items.count > 0) {
            if ([items.firstObject.className isEqualToString:value]) {
                [self removeServiceInstance:service];
            }
            NSMutableIndexSet *idx = [NSMutableIndexSet new];
            for (int i = 0; i < items.count; i++) {
                if ([items[i].className isEqualToString:value])
                {
                    [idx addIndex:i];
                }
            }
            [items removeObjectsAtIndexes:idx];
        }
        [self.lock unlock];
    }
}

- (id)createService:(Protocol *)service
{
    return [self createService:service withServiceName:nil];
}

- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName {
    return [self createService:service withServiceName:serviceName shouldCache:YES];
}

- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName shouldCache:(BOOL)shouldCache {
    if (!serviceName.length) {
        serviceName = NSStringFromProtocol(service);
    }
    id implInstance = nil;

    if (![self checkValidService:service]) {
        if (self.enableException) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ protocol does not been registed", NSStringFromProtocol(service)] userInfo:nil];
        }

    }

    NSString *serviceStr = serviceName;
    if (shouldCache) {
        id protocolImpl = [[TCContext shareInstance] getServiceInstanceFromServiceName:serviceStr];
        if (protocolImpl) {
            return protocolImpl;
        }
    }

    Class implClass = [self serviceImplClass:service];
    if ([[implClass class] respondsToSelector:@selector(singleton)]) {
        if ([[implClass class] singleton]) {
            if ([[implClass class] respondsToSelector:@selector(shareInstance)])
                implInstance = [[implClass class] shareInstance];
            else
                implInstance = [[implClass alloc] init];
            if (shouldCache) {
                [[TCContext shareInstance] addServiceWithImplInstance:implInstance serviceName:serviceStr];
                return implInstance;
            } else {
                return implInstance;
            }
        }
    }
    return [[implClass alloc] init];
}

- (id)getServiceInstance:(Protocol *)service
{
    NSString *key = NSStringFromProtocol(service);
    return [[TCContext shareInstance] getServiceInstanceFromServiceName:key];
}

- (void)removeServiceInstance:(Protocol *)service
{
    NSString *key = NSStringFromProtocol(service);
    [[TCContext shareInstance] removeServiceInstanceWithServiceName:key];
}


#pragma mark - private
- (Class)serviceImplClass:(Protocol *)service
{
    NSArray<TCServiceItem *> *serviceImpls = [[self servicesDict] objectForKey:NSStringFromProtocol(service)];
    if (serviceImpls.count > 0) {
        return NSClassFromString(serviceImpls[0].className);
    }
    return nil;
}

- (BOOL)checkValidService:(Protocol *)service
{
    NSArray<TCServiceItem *> *serviceImpls = [[self servicesDict] objectForKey:NSStringFromProtocol(service)];
    if (serviceImpls.count > 0) {
        return YES;
    }
    return NO;
}

- (NSMutableDictionary *)allServicesDict
{
    if (!_allServicesDict) {
        _allServicesDict = [NSMutableDictionary dictionary];
    }
    return _allServicesDict;
}

- (NSRecursiveLock *)lock
{
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

- (NSDictionary<NSString *, NSArray<TCServiceItem *> *> *)servicesDict
{
    [self.lock lock];
    NSDictionary *dict = [self.allServicesDict copy];
    [self.lock unlock];
    return dict;
}


@end
