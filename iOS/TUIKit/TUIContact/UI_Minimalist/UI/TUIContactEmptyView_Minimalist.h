//
//  TUIContactEmptyView_Minimalist.h
//  TUIContact
//
//  Created by wyl on 2023/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactEmptyView_Minimalist : UIView
@property (nonatomic, strong) UIImageView *midImage;
@property (nonatomic, strong) UILabel *tipsLabel;

- (instancetype)initWithImage:(UIImage *)img Text:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
