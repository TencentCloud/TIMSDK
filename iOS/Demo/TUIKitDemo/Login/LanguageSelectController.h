//
//  LanguageSelectController.h
//  TUIKitDemo
//
//  Created by harvy on 2022/1/6.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LanguageSelectCellModel;
typedef void(^LanguageSelectCallback)(LanguageSelectCellModel *);

@protocol LanguageSelectControllerDelegate <NSObject>

- (void)onSelectLanguage:(LanguageSelectCellModel *)cellModel;

@end


@interface LanguageSelectCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *chooseIconView;

@property (nonatomic, strong) LanguageSelectCellModel *cellModel;

@end

@interface LanguageSelectCellModel : NSObject

@property (nonatomic, copy) NSString *languageID;
@property (nonatomic, strong) NSString *languageName;
@property (nonatomic, assign) BOOL selected;

@end

@interface LanguageSelectController : UIViewController

@property (nonatomic, weak) id<LanguageSelectControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
