#import <Foundation/Foundation.h>
#import "TCAnnotation.h"

@protocol TCServiceProtocol <NSObject>

@optional

+ (BOOL)singleton;

+ (id)shareInstance;

@end