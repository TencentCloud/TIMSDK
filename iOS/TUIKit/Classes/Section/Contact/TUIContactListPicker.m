//
//  TUIContactListPicker.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/13.
//

#import "TUIContactListPicker.h"
#import "TContactListPickerCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import "UIImage+TUIKIT.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIKit.h"
#import "NSBundle+TUIKIT.h"

static NSString *kReuseIdentifier = @"PickerIdentifier";

@interface TUIContactListPicker()<UICollectionViewDelegate, UICollectionViewDataSource>
@property UICollectionView *collectionView;
@property UIButton *accessoryBtn;
@end

@implementation TUIContactListPicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    [self initControl];
    [self setupBinding];

    return self;
}

- (void)initControl
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;

    [self.collectionView registerClass:[TContactListPickerCell class] forCellWithReuseIdentifier:kReuseIdentifier];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];

    [self addSubview:_collectionView];

    _accessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_accessoryBtn setBackgroundImage:[UIImage tk_imageNamed:@"icon_cell_blue_normal"] forState:UIControlStateNormal];
    [_accessoryBtn setBackgroundImage:[UIImage tk_imageNamed:@"icon_cell_blue_normal"] forState:UIControlStateHighlighted];
    [_accessoryBtn setTitle:[NSString stringWithFormat:@" %@ ", TUILocalizableString(Confirm)] forState:UIControlStateNormal]; // @" 确定 "
    [self addSubview:_accessoryBtn];
}

- (void)setupBinding
{
    @weakify(self)
    [RACObserve(self, selectArray) subscribeNext:^(NSArray *x) {
        @strongify(self)
        [self.collectionView reloadData];
        self.accessoryBtn.enabled = [x count];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.selectArray count];
}

- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(35, collectionView.bounds.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TContactListPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];

    TCommonContactSelectCellData *data = self.selectArray[indexPath.row];
    if (data.avatarUrl) {
        [cell.avatar sd_setImageWithURL:data.avatarUrl placeholderImage:DefaultAvatarImage];
    } else if (data.avatarImage) {
        cell.avatar.image = data.avatarImage;
    } else {
        cell.avatar.image = DefaultAvatarImage;
    }    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.item >= self.selectArray.count) {
        return;
    }
    TCommonContactSelectCellData *data = self.selectArray[indexPath.item];
    if (self.onCancel) {
        self.onCancel(data);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.accessoryBtn.mm_sizeToFit().mm_height(30).mm_right(15).mm_top(13);
    self.collectionView.mm_left(15).mm_height(40).mm_width(self.accessoryBtn.mm_x - 30).mm__centerY(self.accessoryBtn.mm_centerY);

}

@end
