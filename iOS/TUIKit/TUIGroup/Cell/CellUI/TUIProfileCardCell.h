#import <UIKit/UIKit.h>
#import "TUICommonModel.h"
@class TUIProfileCardCell;
@protocol TUIProfileCardDelegate <NSObject>

- (void)didTapOnAvatar:(TUIProfileCardCell *)cell;

@end


@interface TUIProfileCardCellData : TUICommonCellData
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

@interface TUIProfileCardCell : TUICommonTableViewCell
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *identifier;
@property (nonatomic, strong) UILabel *signature;
@property (nonatomic, strong) UIImageView *genderIcon;
@property (nonatomic, strong) TUIProfileCardCellData *cardData;
@property (nonatomic, weak)  id<TUIProfileCardDelegate> delegate;
- (void)fillWithData:(TUIProfileCardCellData *)data;
@end
