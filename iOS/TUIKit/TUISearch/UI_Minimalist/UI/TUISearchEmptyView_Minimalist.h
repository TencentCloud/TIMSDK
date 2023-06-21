//
//  TUISearchEmptyView_Minimalist.h
//  TUISearch
//
//  Created by wyl on 2022/12/19.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUISearchEmptyView_Minimalist : UIView

@property(nonatomic, strong) UIImageView *midImage;
@property(nonatomic, strong) UILabel *tipsLabel;

- (instancetype)initWithImage:(UIImage *)img Text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
