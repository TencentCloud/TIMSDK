//
//  TUITranslationViewData.h
//  TUIChat
//

#import <Foundation/Foundation.h>
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUITranslationViewStatus) {
    TUITranslationViewStatusUnknown = 0,
    TUITranslationViewStatusHidden = 1,
    TUITranslationViewStatusLoading = 2,
    TUITranslationViewStatusShown = 3,
};

@interface TUITranslationViewData : NSObject

@property (nonatomic, assign) TUITranslationViewStatus status;

/// Translated text.
@property (nonatomic, copy) NSString *text;

/// Size of translation view.
@property (nonatomic, assign, readonly) CGSize size;

/// The width of translation view is affected by the width of container.
- (void)setContainerWidth:(CGFloat)width;
- (void)setMessage:(V2TIMMessage *)message;

- (void)loadSavedData;
/// Calculate the size of view according to containerWidth, status and text.
- (void)calcSize;

- (BOOL)isHidden;
- (BOOL)shouldLoadSavedData;

@end

NS_ASSUME_NONNULL_END
