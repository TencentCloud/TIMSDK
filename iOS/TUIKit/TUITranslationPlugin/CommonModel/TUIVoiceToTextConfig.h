//
//  TUIVoiceToTextConfig.h
//  TTUIVoiceToText
//
//  Created by xia on 2023/8/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIVoiceToTextConfig : NSObject

+ (TUIVoiceToTextConfig *)defaultConfig;

/**
 * 识别目标语言码
 * Recognize target language code.
 */
@property(nonatomic, copy) NSString *targetLanguageCode;

/**
 * 识别目标语言名称。
 * Recognize target language name.
 */
@property(nonatomic, copy, readonly) NSString *targetLanguageName;

@end

NS_ASSUME_NONNULL_END
