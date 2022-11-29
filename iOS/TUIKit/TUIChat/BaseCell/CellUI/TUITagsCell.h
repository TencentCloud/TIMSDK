//
//  TUITagsCell.h
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//

#import <UIKit/UIKit.h>
@class TUITagsModel;
#define MaxTagSize [UIScreen mainScreen].bounds.size.width *0.25 * 3 - 20

NS_ASSUME_NONNULL_BEGIN

@interface TUITagsCell : UIView

@property (nonatomic, strong) TUITagsModel *model;

@property (nonatomic, assign) CGFloat ItemWidth;
@property (nonatomic, copy) void (^emojiClickCallback)(TUITagsModel *model);
@property (nonatomic, copy) void (^userClickCallback)(TUITagsModel *model,NSInteger btnTagIndex);
@property (nonatomic, copy) void (^moreClickCallback)(void);
@end

NS_ASSUME_NONNULL_END
