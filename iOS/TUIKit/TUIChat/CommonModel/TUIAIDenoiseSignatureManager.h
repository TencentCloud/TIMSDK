//
//  TUIAIDenoiseSignatureManager.h
//  TUIChat
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIAIDenoiseSignatureManager : NSObject

@property (nonatomic, copy, readonly) NSString *signature;

+ (instancetype)sharedInstance;

- (void)updateSignature;

@end

NS_ASSUME_NONNULL_END
