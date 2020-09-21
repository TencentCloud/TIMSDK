
#import <UIKit/UIKit.h>
#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN
/*********************************************
 *
 *  本文件实现了在资料卡中显示头像的 cell（参照微信），并在资料卡对应的文件中 TUIKitDemo\Setting\ProfileController.m 中预留了点击头像单元的响应，为今后修改头像的功能留出空间。
 *
 *********************************************/
@interface TCommonAvatarCellData : TCommonCellData;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property BOOL showAccessory;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSURL *avatarUrl;

@end

@interface TCommonAvatarCell :TCommonTableViewCell
@property UILabel *keyLabel;
@property UILabel *valueLabel;
@property UIImageView *avatar;
@property (readonly) TCommonAvatarCellData *avatarData;


- (void)fillWithData:(TCommonAvatarCellData *) avatarData;

@end

NS_ASSUME_NONNULL_END
