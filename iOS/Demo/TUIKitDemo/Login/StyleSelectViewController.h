//
//  StyleSelectViewController.h
//  TUIKitDemo
//
//  Created by wyl on 2022/11/7.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class StyleSelectCellModel;
typedef void(^StyleSelectCallback)(StyleSelectCellModel *);

@protocol StyleSelectControllerDelegate <NSObject>

- (void)onSelectStyle:(StyleSelectCellModel *)cellModel;

@end


@interface StyleSelectCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *chooseIconView;

@property (nonatomic, strong) StyleSelectCellModel *cellModel;

@end

@interface StyleSelectCellModel : NSObject

@property (nonatomic, copy) NSString *styleID;
@property (nonatomic, strong) NSString *styleName;
@property (nonatomic, assign) BOOL selected;

@end

@interface StyleSelectViewController : UIViewController

@property (nonatomic, weak) id<StyleSelectControllerDelegate> delegate;

+ (BOOL)isClassicEntrance;

@end

NS_ASSUME_NONNULL_END
