#import <UIKit/UIKit.h>
#import "TCommonCell.h"

@interface TUIProfileCardCellData : TCommonCellData
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *signature;
@property BOOL showAccessory;
@end

@interface TUIProfileCardCell : TCommonTableViewCell
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *identifier;
@property (nonatomic, strong) UILabel *signature;

@property (nonatomic, strong) TUIProfileCardCellData *cardData;
- (void)fillWithData:(TUIProfileCardCellData *)data;
@end
