//
//  TUIContactUserPanelHeaderView_Minimalist.m
//  TUIContact
//
//  Created by wyl on 2023/1/18.
//

#import "TUIContactUserPanelHeaderView_Minimalist.h"

@implementation TUIContactPanelCell_Minimalist
{
    UIImageView *_imageView;
    UILabel * _nameLabel;
    UIImageView *_imageIcon;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_imageView];
        
        _imageIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageIcon.image = [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_del_icon")];
        [self addSubview:_imageIcon];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:kScale390(12)];
        [self addSubview:_nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.masksToBounds = YES;
    
    [_nameLabel sizeToFit];
    
    _imageView.frame = CGRectMake((self.bounds.size.width - kScale390(40) )*0.5, 0, kScale390(40), kScale390(40));
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = _imageView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    _imageIcon.frame = CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width - kScale390(12), _imageView.frame.origin.y, kScale390(12), kScale390(12));
    
    _nameLabel.frame = CGRectMake(0, _imageView.frame.size.height + kScale390(2), _nameLabel.frame.size.width, kScale390(17));
    _nameLabel.mm__centerX(_imageView.center.x);
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
}
- (void)fillWithData:(TUICommonContactSelectCellData *)model
{
    [_imageView sd_setImageWithURL:model.avatarUrl placeholderImage:[UIImage imageNamed:TUICoreImagePath(@"default_c2c_head")] options:SDWebImageHighPriority];
    _nameLabel.text = model.title;

}

@end


@implementation TUIContactUserPanelHeaderView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        CGFloat topPadding = 44.f;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            topPadding = window.safeAreaInsets.top;
        }
        topPadding = MAX(26, topPadding);
        self.topStartPosition = 0;
        self.selectedUsers = [NSMutableArray array];
        self.userPanel.userInteractionEnabled = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.userPanel.frame = self.bounds;
}

- (UICollectionView *)userPanel {
    if (!_userPanel) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _userPanel = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _userPanel.backgroundColor = [UIColor clearColor];
        [_userPanel registerClass:[TUIContactPanelCell_Minimalist class] forCellWithReuseIdentifier:@"TUIContactPanelCell_Minimalist"];
        if (@available(iOS 10.0, *)) {
            _userPanel.prefetchingEnabled = YES;
        } else {
            // Fallback on earlier versions
        }
        _userPanel.showsVerticalScrollIndicator = NO;
        _userPanel.showsHorizontalScrollIndicator = NO;
        _userPanel.contentMode = UIViewContentModeScaleAspectFit;
        _userPanel.scrollEnabled = YES;
        _userPanel.delegate = self;
        _userPanel.dataSource = self;
        [self addSubview:_userPanel];
    }
    return _userPanel;
}

#pragma mark UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedUsers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"TUIContactPanelCell_Minimalist";
    TUIContactPanelCell_Minimalist *cell = (TUIContactPanelCell_Minimalist *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.selectedUsers.count) {
        [cell fillWithData:self.selectedUsers[indexPath.row]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TUICommonContactSelectCellData *model = self.selectedUsers[indexPath.row];
   
    CGSize size = [model.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kScale390(12)]} context:nil].size;
    return CGSizeMake(MAX(kScale390(60), size.width), kScale390(60));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, kScale390(16), 0, kScale390(16));
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.row < self.selectedUsers.count) {
        // to do
        if (self.selectedUsers[indexPath.row]) {
            TUICommonContactSelectCellData *model = self.selectedUsers[indexPath.row];
            model.selected = !model.selected;
            [self.selectedUsers removeObjectAtIndex:indexPath.row];
            if (self.clickCallback) {
                self.clickCallback();
            }
        }

    }
}

@end
