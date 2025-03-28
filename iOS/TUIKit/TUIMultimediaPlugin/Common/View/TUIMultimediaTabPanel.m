// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaTabPanel.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaImageUtil.h"
#import "TUIMultimediaPlugin/TUIMultimediaSplitter.h"

@interface TUIMultimediaTabPanel () <TUIMultimediaTabBarDelegate> {
    TUIMultimediaTabBar *_bar;
    TUIMultimediaSplitter *_splitter;
    NSArray<TUIMultimediaTabPanelTab *> *_tabs;
}

@end

@implementation TUIMultimediaTabPanel

@dynamic tabs;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initUI];
    return self;
}

- (void)initUI {
    _bar = [[TUIMultimediaTabBar alloc] init];
    [self addSubview:_bar];
    _bar.delegate = self;

    _splitter = [[TUIMultimediaSplitter alloc] init];
    [self addSubview:_splitter];
    _splitter.lineWidth = 1;
    _splitter.color = TUIMultimediaPluginDynamicColor(@"tabpanel_splitter_color", @"#FFFFFF1A");

    [_bar mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.top.equalTo(self).inset(5);
      make.height.mas_equalTo(42);
    }];
    [_splitter mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.equalTo(self);
      make.top.equalTo(_bar.mas_bottom);
      make.height.mas_equalTo(5);
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Properties
- (NSInteger)selectedIndex {
    return _bar.selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _bar.selectedIndex = selectedIndex;
    for (int i = 0; i < _tabs.count; i++) {
        TUIMultimediaTabPanelTab *t = _tabs[i];
        t.view.hidden = i != selectedIndex;
    }
}

- (NSArray<TUIMultimediaTabPanelTab *> *)tabs {
    return _tabs;
}

- (void)setTabs:(NSArray<TUIMultimediaTabPanelTab *> *)value {
    if (_tabs != nil) {
        for (TUIMultimediaTabPanelTab *t in _tabs) {
            [t.view removeFromSuperview];
        }
    }
    _tabs = value;
    _bar.selectedIndex = -1;
    _bar.tabs = [value tui_multimedia_map:^id(TUIMultimediaTabPanelTab *t) {
      return t.icon == nil ? t.name : t.icon;
    }];
    for (int i = 0; i < _tabs.count; i++) {
        TUIMultimediaTabPanelTab *t = _tabs[i];
        t.view.hidden = YES;
        [self addSubview:t.view];
        [t.view mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.right.bottom.equalTo(self);
          make.top.equalTo(_splitter.mas_bottom);
        }];
    }
    if (_tabs.count > 0) {
        TUIMultimediaTabPanelTab *t = _tabs[0];
        _bar.selectedIndex = 0;
        t.view.hidden = NO;
    }
}
#pragma mark - TUIMultimediaTabBarDelegate protocol
- (void)tabBar:(TUIMultimediaTabBar *)bar selectedIndexChanged:(NSInteger)index {
    for (int i = 0; i < _tabs.count; i++) {
        TUIMultimediaTabPanelTab *t = _tabs[i];
        t.view.hidden = i != index;
    }
    [_delegate tabPanel:self selectedIndexChanged:index];
}

@end

#pragma mark - TUIMultimediaTabPanelTab
@implementation TUIMultimediaTabPanelTab {
}
- (instancetype)initWithName:(NSString *)name icon:(UIImage *)icon view:(UIView *)view {
    self = [super init];
    if (self != nil) {
        _name = name;
        _icon = icon;
        _view = view;
    }
    return self;
}
@end

#pragma mark - TUIMultimediaTabBar

@interface TUIMultimediaTabBar () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    UICollectionView *_collectionView;
}
@end

@implementation TUIMultimediaTabBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initUI];
    return self;
}

- (void)initUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 10;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:TUIMultimediaTabBarCell.class forCellWithReuseIdentifier:TUIMultimediaTabBarCell.reuseIdentifier];
    [self addSubview:_collectionView];

    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout protocol
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    _selectedIndex = indexPath.item;
    [collectionView reloadData];

    [_delegate tabBar:self selectedIndexChanged:_selectedIndex];
}

#pragma mark - UICollectionViewDataSource protocol
- (NSAttributedString *)getAttributedString:(NSString *)str selected:(BOOL)selected {
    UIColor *color;
    UIFont *font;
    if (selected) {
        color = UIColor.whiteColor;
        font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    } else {
        color = [UIColor colorWithWhite:1 alpha:0.6];
        font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    }
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:str
                                                               attributes:@{
                                                                   NSForegroundColorAttributeName : color,
                                                                   NSFontAttributeName : font,
                                                               }];
    return text;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TUIMultimediaTabBarCell *cell = (TUIMultimediaTabBarCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TUIMultimediaTabBarCell.reuseIdentifier
                                                                                           forIndexPath:indexPath];
    cell.barCellSelected = indexPath.item == _selectedIndex;
    BOOL cellSelected = indexPath.item == _selectedIndex;
    id item = _tabs[indexPath.item];
    if ([item isKindOfClass:NSString.class]) {
        cell.attributedText = [self getAttributedString:item selected:cellSelected];
    } else if ([item isKindOfClass:UIImage.class]) {
        cell.contentView.backgroundColor = cellSelected ? [UIColor colorWithWhite:1 alpha:0.1] : UIColor.clearColor;
        cell.icon = item;
        cell.padding = 8;
    }

    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = _collectionView.bounds.size.height;
    CGSize size = CGSizeMake(h, h);
    id item = _tabs[indexPath.item];
    if ([item isKindOfClass:NSString.class]) {
        NSAttributedString *text = [self getAttributedString:_tabs[indexPath.item] selected:YES];
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, _collectionView.bounds.size.height)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                             context:nil]
                              .size;
        size.width = MAX(size.width, textSize.width + 10);
        size.height = MAX(size.height, textSize.height + 8);
        return size;
    }
    return size;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tabs.count;
}

@end

#pragma mark - TUIMultimediaTabBarCell
@interface TUIMultimediaTabBarCell () {
    UILabel *_label;
    UIImageView *_imgView;
}
@end
@implementation TUIMultimediaTabBarCell
+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.contentView.layer.cornerRadius = 5;
        self.contentView.clipsToBounds = YES;

        _label = [[UILabel alloc] init];
        [self.contentView addSubview:_label];
        _label.textAlignment = NSTextAlignmentCenter;
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self);
        }];

        _imgView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imgView];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self);
        }];
    }
    return self;
}
- (void)prepareForReuse {
    [super prepareForReuse];
    self.attributedText = nil;
    self.icon = nil;
    self.barCellSelected = NO;
    self.padding = 0;
}
- (NSAttributedString *)attributedText {
    return _label.attributedText;
}
- (UIImage *)icon {
    return _imgView.image;
}
- (void)setAttributedText:(NSAttributedString *)attributedText {
    _label.attributedText = attributedText;
}
- (void)setIcon:(UIImage *)icon {
    _imgView.image = icon;
}
- (void)setPadding:(CGFloat)padding {
    _padding = padding;
    [_label mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self).inset(_padding);
    }];
    [_imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self).inset(_padding);
    }];
}
@end
