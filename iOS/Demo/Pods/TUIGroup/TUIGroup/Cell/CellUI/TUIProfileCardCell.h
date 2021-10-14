#import <UIKit/UIKit.h>
#import "TUICommonModel.h"
@class TUIProfileCardCell;
@protocol TUIProfileCardDelegate <NSObject>
/**
 *  点击头像的回调委托。
 *  您可以通过该委托实现点击头像显示大图的功能。
 *
 *  @param cell 被点击的头像所在的 cell，
 */
- (void)didTapOnAvatar:(TUIProfileCardCell *)cell;

@end


@interface TUIProfileCardCellData : TUICommonCellData
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *signature;
//实现根据性别展示iCon的需求。
@property (nonatomic, strong) UIImage *genderIconImage;
@property (nonatomic, strong) NSString *genderString;
@property BOOL showAccessory;
@end

@interface TUIProfileCardCell : TUICommonTableViewCell
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *identifier;
@property (nonatomic, strong) UILabel *signature;
@property (nonatomic, strong) UIImageView *genderIcon;
@property (nonatomic, strong) TUIProfileCardCellData *cardData;
//实现点击头像的回调委托。
@property (nonatomic, weak)  id<TUIProfileCardDelegate> delegate;
- (void)fillWithData:(TUIProfileCardCellData *)data;
@end
