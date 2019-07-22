#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIError : NSObject

+ (NSString *)strError:(NSInteger)code msg:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
