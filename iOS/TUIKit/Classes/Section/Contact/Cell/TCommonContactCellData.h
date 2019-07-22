#import <Foundation/Foundation.h>
#import "TCommonCell.h"

NS_ASSUME_NONNULL_BEGIN
@class TIMFriend;
@class TIMGroupInfo;

@interface TCommonContactCellData : TCommonCellData

- (instancetype)initWithFriend:(TIMFriend *)args;
- (instancetype)initWithGroupInfo:(TIMGroupInfo *)args;

@property TIMFriend *friendProfile;
@property NSString *identifier;

@property NSURL *avatarUrl;
@property NSString *title;
@property UIImage *avatarImage;

@end

NS_ASSUME_NONNULL_END
