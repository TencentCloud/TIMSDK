//
//  TCommonFriendCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import <UIKit/UIKit.h>
#import "TCommonContactCellData.h"
#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCommonContactCell : TCommonTableViewCell

@property UIImageView *avatarView;
@property UILabel *titleLabel;

@property (readonly) TCommonContactCellData *contactData;

- (void)fillWithData:(TCommonContactCellData *)contactData;

@end

NS_ASSUME_NONNULL_END
