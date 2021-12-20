//
//  TUIChatPopMenu.h
//  TUIChat
//
//  Created by harvy on 2021/11/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIChatPopMenuActionCallback)(void);

@interface TUIChatPopMenuAction : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) TUIChatPopMenuActionCallback callback;

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                     callback:(TUIChatPopMenuActionCallback)callback;
@end


@interface TUIChatPopMenu : UIView

- (void)addAction:(TUIChatPopMenuAction *)action;
- (void)setArrawPosition:(CGPoint)point adjustHeight:(CGFloat)adjustHeight;
- (void)showInView:(UIView * __nullable)window;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
