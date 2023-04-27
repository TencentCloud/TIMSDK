//
//  TUITranslationLanguageController.h
//  TUITranslation
//
//  Created by xia on 2023/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUITranslationLanguageController : UIViewController

@property (nonatomic, copy) void (^onSelectedLanguage)(NSString *languageName);

@end

NS_ASSUME_NONNULL_END
