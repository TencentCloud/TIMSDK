
#import <UIKit/UIKit.h>
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN
/*********************************************
 *
 *  本文件实现了在资料卡中显示头像的 cell（参照微信），并在资料卡对应的文件中 TUIKitDemo\Setting\ProfileController.m 中预留了点击头像单元的响应，为今后修改头像的功能留出空间。
 *
 *  This file implements the cell that displays the avatar in the profile card (refer to WeChat), and reserves the response of clicking the avatar cell in TUIKitDemo\Setting\ProfileController.m
 *  in the file corresponding to the data card, which is reserved for the function of modifying the avatar in the future. space.
 *
 *********************************************/
@interface TUICommonAvatarCellData : TUICommonCellData;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property BOOL showAccessory;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSURL *avatarUrl;

@end

@interface TUICommonAvatarCell :TUICommonTableViewCell
@property UILabel *keyLabel;
@property UILabel *valueLabel;
@property UIImageView *avatar;
@property (readonly) TUICommonAvatarCellData *avatarData;


- (void)fillWithData:(TUICommonAvatarCellData *) avatarData;

@end

NS_ASSUME_NONNULL_END
