#import <Foundation/Foundation.h>

@interface PAirSandbox : NSObject

+ (instancetype)sharedInstance;

- (void)enableSwipe;
- (void)showSandboxBrowser;

- (void)addAppGroup:(NSString *)groupId;

@end

