//
//  TUIFitButton.h
//  TUICore
//
//  Created by wyl on 2022/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIFitButton : UIButton
//Rect 设置优先于 Size
@property (nonatomic, assign) CGRect titleRect;
@property (nonatomic, assign) CGRect imageRect;

@property (nonatomic, assign) CGSize imageSize;//居中
@property (nonatomic, assign) CGSize titleSize;//居中

@property (nonatomic, strong) UIImage * hoverImage;
@property (nonatomic, strong) UIImage * normalImage;

@end


@interface TUIBlockButton : TUIFitButton
@property (nonatomic,copy) void(^clickCallBack)(id button);
@end

NS_ASSUME_NONNULL_END
