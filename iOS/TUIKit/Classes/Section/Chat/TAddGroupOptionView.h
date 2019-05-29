//
//  TAddGroupOptionView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAddGroupOptionView;
@protocol TAddGroupOptionViewDelegate <NSObject>
- (void)didTapInAddGroupOptionView:(TAddGroupOptionView *)view;
@end

@interface TAddGroupOptionData : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSObject *value;
@end

@interface TAddGroupOptionViewData : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) TAddGroupOptionData *value;
@end

@interface TAddGroupOptionView : UIView
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subTitle;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, weak) id<TAddGroupOptionViewDelegate> delegate;
- (void)setData:(TAddGroupOptionViewData *)data;
@end
