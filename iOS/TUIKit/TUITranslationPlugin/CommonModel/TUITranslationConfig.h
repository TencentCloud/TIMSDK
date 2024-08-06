//
//  TUITranslationConfig.h
//  TUITranslation
//
//  Created by xia on 2023/4/7.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUITranslationConfig : NSObject

+ (TUITranslationConfig *)defaultConfig;

/**
 * Translation target language code.
 */
@property(nonatomic, copy) NSString *targetLanguageCode;

/**
 * Translation target language name.
 */
@property(nonatomic, copy, readonly) NSString *targetLanguageName;

@end

NS_ASSUME_NONNULL_END
