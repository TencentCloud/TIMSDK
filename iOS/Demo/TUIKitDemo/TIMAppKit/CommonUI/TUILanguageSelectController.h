//
//  TUILanguageSelectController.h
//  TUIKitDemo
//
//  Created by harvy on 2022/1/6.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUILanguageSelectCellModel;
typedef void (^TUILanguageSelectCallback)(TUILanguageSelectCellModel *);

@protocol TUILanguageSelectControllerDelegate <NSObject>

- (void)onSelectLanguage:(TUILanguageSelectCellModel *)cellModel;

@end

@interface TUILanguageSelectCell : UITableViewCell

@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIImageView *chooseIconView;

@property(nonatomic, strong) TUILanguageSelectCellModel *cellModel;

@end

@interface TUILanguageSelectCellModel : NSObject

@property(nonatomic, copy) NSString *languageID;
@property(nonatomic, strong) NSString *languageName;
@property(nonatomic, assign) BOOL selected;

@end

@interface TUILanguageSelectController : UIViewController

@property(nonatomic, weak) id<TUILanguageSelectControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
