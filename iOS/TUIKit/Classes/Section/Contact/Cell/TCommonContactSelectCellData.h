//
//  TCommonContactSelectCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//

#import "TCommonCell.h"
@class TIMFriend;
NS_ASSUME_NONNULL_BEGIN

@interface TCommonContactSelectCellData : TCommonCellData

- (void)updateFromFriend:(TIMFriend *)afriend;

@property NSURL *avatarUrl;
@property NSString *title;
@property UIImage *avatarImage;
@property NSString *identifier;

@property (nonatomic,getter=isSelected) BOOL selected;
@property (nonatomic,getter=isEnabled) BOOL enabled;

@end

NS_ASSUME_NONNULL_END
