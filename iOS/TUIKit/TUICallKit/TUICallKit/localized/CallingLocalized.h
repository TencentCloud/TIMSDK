//
//  CallingLocalized.h
//  Pods
//
//  Created by abyyxwang on 2021/5/6.
//  Copyright © 2021 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Base

extern NSBundle *TUICallingBundle(void);
extern NSString *TUICallingLocalizeFromTable(NSString *key, NSString *table);
extern NSString *TUICallingLocalizeFromTableAndCommon(NSString *key, NSString *common, NSString *table);

#pragma mark - Replace String

extern NSString *TUICallingLocalizeReplaceXX(NSString *origin, NSString *xxx_replace);
extern NSString *TUICallingLocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace);
extern NSString *TUICallingLocalizeReplaceThreeCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace);
extern NSString *TUICallingLocalizeReplaceFourCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace);
extern NSString *TUICallingLocalizeReplaceFiveCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace, NSString *nnn_replace);

#pragma mark - TRTC

extern NSString *const TUICalling_Localize_TableName;
extern NSString *TUICallingLocalize(NSString *key);

NS_ASSUME_NONNULL_END
