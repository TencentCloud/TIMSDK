//
//  UIAlertController+TUICustomStyle.h
//  TUIChat
//
//  Created by wyl on 2022/10/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomActionSheetItem : NSObject

@property (nonatomic, copy) NSString * title;

@property (nonatomic, strong) UIImage * leftMark;

@property (nonatomic, assign) UIAlertActionStyle actionStyle;

@property (nonatomic, copy) void (^actionHandler)(UIAlertAction *action);

- (instancetype)initWithTitle:(NSString *)title leftMark:(UIImage *)leftMark withActionHandler:(void (^)(UIAlertAction *action)) actionHandler ;
@end

@interface UIAlertController (TUICustomStyle)

- (void)configItems:(NSArray<TUICustomActionSheetItem *> *)Items;

@end

NS_ASSUME_NONNULL_END
