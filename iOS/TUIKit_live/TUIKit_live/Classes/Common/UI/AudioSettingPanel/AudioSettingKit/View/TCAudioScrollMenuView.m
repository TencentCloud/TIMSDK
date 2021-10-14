//
//  TCAudioScrollMenuView.m
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import "TCAudioScrollMenuView.h"
#import "TCAudioScrollerMenuCell.h"
#import "TCAudioScrollMenuCellModel.h"
#import "TCASKitTheme.h"
#import "ASMasonry.h"

@interface TCAudioScrollMenuView ()<UICollectionViewDelegate, UICollectionViewDataSource>{
    BOOL _isViewReady;
}

@property (nonatomic, strong) TCASKitTheme *theme;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *menuView;

@end

@implementation TCAudioScrollMenuView
#pragma mark - 属性的set方法
- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setDataSource:(NSArray<TCAudioScrollMenuCellModel *> *)dataSource{
    _dataSource = dataSource;
    [self.menuView reloadData];
    [self bindInteraction];
}

#pragma mark - 视图属性懒加载
- (TCASKitTheme *)theme {
    if (!_theme) {
        _theme = [[TCASKitTheme alloc] init];
    }
    return _theme;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [self.theme themeFontWithSize:16.0];
        label.textColor = [self.theme normalFontColor];
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UICollectionView *)menuView {
    if (!_menuView) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self createCollectionLayout]];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.allowsMultipleSelection = NO;
        [collectionView registerClass:[TCAudioScrollerMenuCell class] forCellWithReuseIdentifier:@"TCAudioScrollerMenuCell"];
        _menuView = collectionView;
    }
    return _menuView;
}

- (UICollectionViewFlowLayout *)createCollectionLayout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(44, 66);
    layout.minimumLineSpacing = 15.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 20.0, 0, 20.0);
    return layout;
}

#pragma mark - 视图生命周期
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self->_isViewReady) {
        return;
    }
    [self constructViewHierachy];
    [self activateConstraints];
    self->_isViewReady = YES;
    [self setupStyle];
}

- (void)constructViewHierachy {
    [self addSubview:self.titleLabel];
    [self addSubview:self.menuView];
}

- (void)activateConstraints {
    [self.titleLabel mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).offset(20.0);
    }];
    [self.titleLabel sizeToFit];
    [self.menuView mas_makeConstraints:^(ASMASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(66);
    }];
}

/// 绑定视图交互
- (void)bindInteraction {
    [self.menuView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}
/// 设置视图样式
- (void)setupStyle {
    
}

#pragma mark - CollectionViewDelegate&&Datasource
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TCAudioScrollMenuCellModel* model = self.dataSource[indexPath.row];
    model.action();
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TCAudioScrollerMenuCell *cell = (TCAudioScrollerMenuCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TCAudioScrollerMenuCell" forIndexPath:indexPath];
    TCAudioScrollMenuCellModel* model = self.dataSource[indexPath.row];
    [cell setupCellWithModel:model];
    return cell;
}

@end
