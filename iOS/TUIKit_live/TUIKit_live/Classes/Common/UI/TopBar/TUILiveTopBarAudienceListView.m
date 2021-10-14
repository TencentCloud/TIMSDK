//
//  TUILiveTopBarAudienceListView.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by coddyliu on 2020/9/19.
//

#import "TUILiveTopBarAudienceListView.h"
#import "TUILiveAnchorInfo.h"
#import "TUILiveColor.h"
#import "SDWebImage.h"
#import "Masonry.h"
#import <QuartzCore/QuartzCore.h>
@interface TUILiveTopBarAudienceListView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, strong) NSArray<UIColor *> *audienceWeightLabelColors; // 金色，银色，铜色，灰黑色
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation TUILiveTopBarAudienceListView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.audienceWeightLabelColors = @[RGB(243, 242, 144), RGB(217, 222, 224), RGB(206, 190, 171), RGB(153, 154, 155)];
        [self constructSubViews];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutUI];
    });
}

- (void)constructSubViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.bounds.size.height, self.bounds.size.height);
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 9.0, *)) {
          self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    }
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:TUILiveAudienceAvatarCell.class forCellWithReuseIdentifier:@"TUILiveAudienceAvatarCell"];
}

- (void)layoutUI {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    if ([self.collectionView.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(self.bounds.size.height, self.bounds.size.height)];
    }
    [self.collectionView reloadData];
}

/// 有更新时，最快间隔1秒刷新一次列表
- (void)setAudienceList:(NSArray *)audienceList {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_audienceList = audienceList;
        [self.collectionView reloadData];
    });
}

- (void)config:(UILabel *)label weight:(CGFloat)weightValue {
    if (weightValue < 10000.0) {
        label.text = [NSString stringWithFormat:@"%0.1f", weightValue];
    } else {
        NSString *weightStr = [NSString stringWithFormat:@"%0.1f万", weightValue/10000.0];
        label.text = weightStr;
    }
}

- (void)config:(UIButton *)button avatarUrl:(NSString *)avatarUrl defaultImage:(UIImage *)defaultImage {
    [button sd_setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateNormal placeholderImage:defaultImage];
    [button sd_setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateHighlighted placeholderImage:defaultImage];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.audienceList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUILiveAudienceAvatarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TUILiveAudienceAvatarCell" forIndexPath:indexPath];
    if (cell) {
        if (indexPath.row < 4) {
            cell.weightLabel.backgroundColor = self.audienceWeightLabelColors[indexPath.row];
        } else {
            cell.weightLabel.backgroundColor = self.audienceWeightLabelColors.lastObject;
        }
        if (indexPath.row == 0) {
            cell.weightLabel.textColor = [UIColor grayColor];
        } else {
            cell.weightLabel.textColor = [UIColor whiteColor];
        }
        TUILiveAnchorInfo *audienceInfo = [self.audienceList objectAtIndex:indexPath.row];
        [self config:cell.avatarButton
           avatarUrl:audienceInfo.avatarUrl
        defaultImage:[UIImage imageNamed:@"live_audience_default_avatar"]];
        [self config:cell.weightLabel weight:audienceInfo.weightValue];
        return cell;
    } else {
        NSLog(@"TUILiveTopBarAudienceListView create cell failed !!!");
        return [[UICollectionViewCell alloc] init];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath: %@", indexPath);
    if (self.onSelected) {
        TUILiveAnchorInfo *audienceInfo = [self.audienceList objectAtIndex:indexPath.row];
        self.onSelected(self, audienceInfo);
    }
}

@end

@implementation TUILiveAudienceAvatarCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.avatarButton.layer.cornerRadius = self.avatarButton.frame.size.height/2.0;
    });
}

- (void)layoutUI {
    if (self.avatarButton) {
        return;
    }
    self.avatarButton = [self.class newAvatarButton:nil defaultImage:[UIImage imageNamed:@"live_audience_default_avatar"]];
    self.avatarButton.userInteractionEnabled = NO;
    self.weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 22)];
    [self addSubview:self.avatarButton];
    [self addSubview:self.weightLabel];
    [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(self.avatarButton.mas_width);
    }];
    [self.weightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.height.equalTo(@15);
        make.centerX.equalTo(self.mas_centerX);
        make.width.greaterThanOrEqualTo(@20);
    }];
    self.weightLabel.font = [UIFont systemFontOfSize:11];
    self.weightLabel.layer.cornerRadius = 7.0;
    self.weightLabel.clipsToBounds = YES;
}

+ (UIButton *)newAvatarButton:(NSString *)avatarUrl defaultImage:(UIImage *)image {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    button.clipsToBounds = YES;
    [button sd_setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateNormal placeholderImage: image];
    [button sd_setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateHighlighted placeholderImage: image];
    return button;
}

@end
