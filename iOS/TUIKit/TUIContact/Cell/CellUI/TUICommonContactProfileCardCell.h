#import <UIKit/UIKit.h>
#import "TUICommonModel.h"

@class TUICommonContactProfileCardCell;

@protocol TUIContactProfileCardDelegate <NSObject>

- (void)didTapOnAvatar:(TUICommonContactProfileCardCell *)cell;

@end


@interface TUICommonContactProfileCardCellData : TUICommonCellData

@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, strong) UIImage *genderIconImage;
@property (nonatomic, strong) NSString *genderString;
@property BOOL showAccessory;
@property BOOL showSignature;

@end

@interface TUICommonContactProfileCardCell : TUICommonTableViewCell

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *identifier;
@property (nonatomic, strong) UILabel *signature;
@property (nonatomic, strong) UIImageView *genderIcon;
@property (nonatomic, strong) TUICommonContactProfileCardCellData *cardData;

@property (nonatomic, weak)  id<TUIContactProfileCardDelegate> delegate;

- (void)fillWithData:(TUICommonContactProfileCardCellData *)data;
@end
