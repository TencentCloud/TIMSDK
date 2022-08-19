
#import <UIKit/UIKit.h>
#import "TUIGroupMemberCellData.h"

@interface TUIGroupMemberCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *head;

@property (nonatomic, strong) UILabel *name;

+ (CGSize)getSize;

@property (nonatomic, strong) TUIGroupMemberCellData *data;

@end
