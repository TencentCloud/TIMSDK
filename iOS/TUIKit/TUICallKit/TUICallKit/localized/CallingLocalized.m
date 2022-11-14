//
//  CallingLocalized.m
//  Pods
//
//  Created by abyyxwang on 2021/5/6.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "CallingLocalized.h"

#pragma mark - Base

NSBundle *TUICallingBundle(void) {
    NSURL *callingKitBundleURL = [[NSBundle mainBundle] URLForResource:@"TUICallingKitBundle" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:callingKitBundleURL];
}

NSString *TUICallingLocalizeFromTable(NSString *key, NSString *table) {
    return [TUICallingBundle() localizedStringForKey:key value:@"" table:table];
}

NSString *TUICallingLocalizeFromTableAndCommon(NSString *key, NSString *common, NSString *table) {
    return TUICallingLocalizeFromTable(key, table);
}

#pragma mark - Replace String

NSString *TUICallingLocalizeReplaceXX(NSString *origin, NSString *xxx_replace) {
    if (xxx_replace == nil) { xxx_replace = @"";}
    return [origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace];
}

NSString *TUICallingLocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace) {
    if (yyy_replace == nil) { yyy_replace = @"";}
    return [TUICallingLocalizeReplaceXX(origin, xxx_replace) stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace];
}

NSString *TUICallingLocalizeReplaceThreeCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace) {
    if (zzz_replace == nil) { zzz_replace = @"";}
    return [TUICallingLocalizeReplace(origin, xxx_replace, yyy_replace) stringByReplacingOccurrencesOfString:@"zzz" withString:zzz_replace];
}

NSString *TUICallingLocalizeReplaceFourCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace) {
    if (mmm_replace == nil) { mmm_replace = @"";}
    return [TUICallingLocalizeReplaceThreeCharacter(origin, xxx_replace, yyy_replace, zzz_replace) stringByReplacingOccurrencesOfString:@"mmm" withString:mmm_replace];
}

NSString *TUICallingLocalizeReplaceFiveCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace, NSString *nnn_replace) {
    if (nnn_replace == nil) { nnn_replace = @"";}
    return [TUICallingLocalizeReplaceFourCharacter(origin, xxx_replace, yyy_replace, zzz_replace, mmm_replace) stringByReplacingOccurrencesOfString:@"nnn" withString:nnn_replace];
}

#pragma mark - Calling

NSString *const TUICalling_Localize_TableName = @"CallingLocalized";
NSString *TUICallingLocalize(NSString *key) {
    return TUICallingLocalizeFromTable(key, TUICalling_Localize_TableName);
}
