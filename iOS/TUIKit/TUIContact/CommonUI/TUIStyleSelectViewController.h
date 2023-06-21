//
//  TUIStyleSelectViewController.h
//  TUIKitDemo
//
//  Created by wyl on 2022/11/7.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#define kTUIKitFirstInitAppStyleID @"Classic";  // Classic / Minimalist

@class TUIStyleSelectCellModel;
typedef void (^StyleSelectCallback)(TUIStyleSelectCellModel *);

@protocol TUIStyleSelectControllerDelegate <NSObject>

- (void)onSelectStyle:(TUIStyleSelectCellModel *)cellModel;

@end

@interface TUIStyleSelectCell : UITableViewCell

@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIImageView *chooseIconView;

@property(nonatomic, strong) TUIStyleSelectCellModel *cellModel;

@end

@interface TUIStyleSelectCellModel : NSObject

@property(nonatomic, copy) NSString *styleID;
@property(nonatomic, strong) NSString *styleName;
@property(nonatomic, assign) BOOL selected;

@end

@interface TUIStyleSelectViewController : UIViewController

@property(nonatomic, weak) id<TUIStyleSelectControllerDelegate> delegate;

+ (BOOL)isClassicEntrance;
- (void)setBackGroundColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
