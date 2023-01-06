/**
 *  本文件声明了 TUITranslationView 类，负责实现消息文本翻译视图。
 *  文本类消息支持长按后翻译，翻译后视图位于消息气泡下方，展示翻译后文本。
 *
 *  When you long press the text messages, you can choose to translate it.
 *  Translation view will be displayed below the message bubble showing the translated text.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUITextView.h"

NS_ASSUME_NONNULL_BEGIN

@class TUITranslationView;
@protocol TUITranslationViewProtocol <NSObject>

- (void)translationViewWillForward:(NSString *)text;
- (void)translationViewWillHide:(TUITranslationView *)view;

@end

@interface TUITranslationView : UIView

@property (nonatomic, weak) id<TUITranslationViewProtocol> delegate;
@property (nonatomic, strong) UIImageView *loadingView;
@property (nonatomic, strong) TUITextView *textView;

- (instancetype)initWithBackgroundColor:(UIColor *)color;

- (void)startLoading;
- (void)stopLoading;

- (void)updateTransaltion:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
