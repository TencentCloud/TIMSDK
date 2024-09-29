//
//  TUIChatShortcutMenuView.m
//  TUIChat
//
//  Created by Tencent on 2023/6/29.
//  Copyright © 2024 Tencent. All rights reserved.

#import "TUIChatShortcutMenuView.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import <TIMCommon/TIMDefine.h>

@implementation TUIChatShortcutMenuCellData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.textColor = [UIColor tui_colorWithHex:@"#8F959E"];
        self.textFont = [UIFont systemFontOfSize:14];
        self.backgroundColor = [UIColor tui_colorWithHex:@"#F6F7F9"];
        self.cornerRadius = 16;
        self.borderColor = [UIColor tui_colorWithHex:@"#C5CBD4"];
        self.borderWidth = 1.0;
    }
    return self;
}

- (CGSize)calcSize {
    return [self calcMenuCellButtonSize:self.text];
}

- (CGSize)calcMenuCellButtonSize:(NSString *)title {
    CGFloat margin = 28;
    CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 32)
                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   attributes:@{ NSFontAttributeName : self.textFont}
                                      context:nil];
    return CGSizeMake(rect.size.width + margin, 32);
}

@end


@interface TUIChatShortcutMenuCell()

@end

@implementation TUIChatShortcutMenuCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.button = [UIButton new];
        [self addSubview:self.button];
    }
    return self;
}

- (void)fillWithData:(TUIChatShortcutMenuCellData *)cellData {
    self.cellData = cellData;
    [self.button setTitle:cellData.text forState:UIControlStateNormal];
    [self.button addTarget:cellData.target action:cellData.cselector forControlEvents:UIControlEventTouchUpInside];
    
    self.button.layer.cornerRadius = self.cellData.cornerRadius;
    self.button.titleLabel.font = self.cellData.textFont;
    self.button.backgroundColor = self.cellData.backgroundColor;
    [self.button setTitleColor:self.cellData.textColor forState:UIControlStateNormal];
    self.button.layer.borderWidth = self.cellData.borderWidth;
    self.button.layer.borderColor = self.cellData.borderColor.CGColor;
    
    [self updateConstraints];
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    CGSize size = [self.cellData calcSize];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(size.width);
        make.height.mas_equalTo(size.height);
    }];
}

@end

@interface TUIChatShortcutMenuView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation TUIChatShortcutMenuView

- (instancetype)initWithDataSource:(NSArray *)source {
    self = [super init];
    if (self) {
        self.dataSource = [source mutableCopy];
        self.backgroundColor = [UIColor tui_colorWithHex:@"#EBF0F6"];
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark - Public
- (void)updateFrame {
    self.mm_left(0).mm_top(0).mm_width(Screen_Width).mm_height(self.viewHeight > 0 ? self.viewHeight : 46);
    self.collectionView.mm_fill();
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TUIChatShortcutMenuCell class] forCellWithReuseIdentifier:@"menuCell"];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource & Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView 
     numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView 
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIChatShortcutMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"menuCell" forIndexPath:indexPath];
    TUIChatShortcutMenuCellData *cellData = self.dataSource[indexPath.row];
    [cell fillWithData:cellData];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView 
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIChatShortcutMenuCellData *cellData = self.dataSource[indexPath.row];
    return CGSizeMake([cellData calcSize].width + 12, [cellData calcSize].height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView 
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView 
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView 
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (BOOL)collectionView:(UICollectionView *)collectionView 
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
