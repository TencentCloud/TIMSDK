#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TCUploadHelper : NSObject

+ (instancetype)shareInstance;

- (void)upload:(NSString*)userId image:(UIImage *)image completion:(void (^)(int errCode, NSString *imageSaveUrl))completion;

@end
