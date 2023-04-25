//
//  TUIWarningView.h
//
//  Created by summeryxia on 2022/7/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIWarningView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                         tips:(NSString *)tips
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(void(^)(void))action;

@end

NS_ASSUME_NONNULL_END
