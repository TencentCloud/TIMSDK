//
//  TUITranslationConfig.h
//  TUITranslation
//
//  Created by xia on 2023/4/7.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUITranslationConfig : NSObject

+ (TUITranslationConfig *)defaultConfig;

/**
 * 翻译目标语言码
 * Translation target language code.
 */
@property(nonatomic, copy) NSString *targetLanguageCode;

/**
 * 翻译目标语言名称。
 * Translation target language name.
 */
@property(nonatomic, copy, readonly) NSString *targetLanguageName;

@end

NS_ASSUME_NONNULL_END
