//
//  CallingLocalized.m
//  Pods
//
//  Created by abyyxwang on 2021/5/6.
//

#import "CallingLocalized.h"
#import "TUIGlobalization.h"

#pragma mark - Base

NSBundle *CallingBundle(void) {
    NSURL *callingKitBundleURL = [[NSBundle mainBundle] URLForResource:@"TUICallingKitBundle" withExtension:@"bundle"];
    NSString *path = [[NSBundle bundleWithURL:callingKitBundleURL] pathForResource:[TUIGlobalization tk_localizableLanguageKey] ofType:@"lproj"];
    return [NSBundle bundleWithPath:path];
}

NSString *TCLLocalizeFromTable(NSString *key, NSString *table) {
    return [CallingBundle() localizedStringForKey:key value:@"" table:table];
}

NSString *TCLLocalizeFromTableAndCommon(NSString *key, NSString *common, NSString *table) {
    return TCLLocalizeFromTable(key, table);
}

#pragma mark - Replace String

NSString *LocalizeReplaceXX(NSString *origin, NSString *xxx_replace) {
    if (xxx_replace == nil) { xxx_replace = @"";}
    return [origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace];
}

NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace) {
    if (yyy_replace == nil) { yyy_replace = @"";}
    return [LocalizeReplaceXX(origin, xxx_replace) stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace];
}

NSString *LocalizeReplaceThreeCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace) {
    if (zzz_replace == nil) { zzz_replace = @"";}
    return [LocalizeReplace(origin, xxx_replace, yyy_replace) stringByReplacingOccurrencesOfString:@"zzz" withString:zzz_replace];
}

NSString *LocalizeReplaceFourCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace) {
    if (mmm_replace == nil) { mmm_replace = @"";}
    return [LocalizeReplaceThreeCharacter(origin, xxx_replace, yyy_replace, zzz_replace) stringByReplacingOccurrencesOfString:@"mmm" withString:mmm_replace];
}

NSString *LocalizeReplaceFiveCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace, NSString *nnn_replace) {
    if (nnn_replace == nil) { nnn_replace = @"";}
    return [LocalizeReplaceFourCharacter(origin, xxx_replace, yyy_replace, zzz_replace, mmm_replace) stringByReplacingOccurrencesOfString:@"nnn" withString:nnn_replace];
}

#pragma mark - Calling

NSString *const Calling_Localize_TableName = @"CallingLocalized";
NSString *CallingLocalize(NSString *key) {
    return TCLLocalizeFromTable(key, Calling_Localize_TableName);
}
