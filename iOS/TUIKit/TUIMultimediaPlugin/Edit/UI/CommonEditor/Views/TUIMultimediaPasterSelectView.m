// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaPasterSelectView.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaImageCell.h"
#import "TUIMultimediaPlugin/TUIMultimediaTabPanel.h"

static const CGFloat ItemInsect = 10;
static const CGFloat ItemCountPerLine = 5;
static const CGFloat ItemCountPerColumn = 3;

@interface TUIMultimediaPasterSelectView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TUIMultimediaTabPanelDelegate> {
    TUIMultimediaTabPanel *_tabPanel;
    UILongPressGestureRecognizer *_longPressRec;
}

@end

@implementation TUIMultimediaPasterSelectView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _config = [[TUIMultimediaPasterConfig alloc] init];
        [self initUI];
    }
    return self;
}

- (void)reloadTabPanel {
    for (TUIMultimediaTabPanelTab *tab in _tabPanel.tabs) {
        if (![tab.view isKindOfClass:UICollectionView.class]) continue;
        UICollectionView *v = (UICollectionView *)tab.view;
        [v reloadData];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (TUIMultimediaTabPanelTab *tab in _tabPanel.tabs) {
        if (![tab.view isKindOfClass:UICollectionView.class]) continue;
        UICollectionView *v = (UICollectionView *)tab.view;
        CGFloat len = (self.bounds.size.width - ItemInsect * (ItemCountPerLine - 1)) / ItemCountPerLine;
        [v mas_updateConstraints:^(MASConstraintMaker *make) {
          make.width.equalTo(self);
          make.height.mas_equalTo(len * ItemCountPerColumn + ItemInsect * (ItemCountPerColumn - 1));
        }];
        [v reloadData];
    }
}

#pragma mark -  UI init

- (void)initUI {
    _tabPanel = [[TUIMultimediaTabPanel alloc] init];
    _tabPanel.backgroundColor = TUIMultimediaPluginDynamicColor(@"editor_popup_view_bg_color", @"#000000BF");
    _tabPanel.delegate = self;
    [self addSubview:_tabPanel];

    [_tabPanel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];

    _longPressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onCollectionViewLongPress:)];
}

#pragma mark - UICollectionViewDataSource protocol
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIMultimediaImageCell *cell = (TUIMultimediaImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TUIMultimediaImageCell.reuseIdentifier forIndexPath:indexPath];
    TUIMultimediaPasterGroupConfig *config = _config.groups[collectionView.tag];
    cell.image = [config.itemList[indexPath.item] loadIcon];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    TUIMultimediaPasterGroupConfig *config = _config.groups[collectionView.tag];
    return config.itemList.count;
}

#pragma mark - UICollectionViewDelegate protocol
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIMultimediaPasterGroupConfig *config = _config.groups[collectionView.tag];
    TUIMultimediaPasterItemConfig *item = config.itemList[indexPath.item];
    if (item.isAddButton) {
        [_delegate pasterSelectView:self
                needAddCustomPaster:config
                   completeCallback:^{
                     [self reloadTabPanel];
                   }];
        return;
    }
    [_delegate onPasterSelected:[item loadImage]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat len = (self.bounds.size.width - ItemInsect * (ItemCountPerLine + 1)) / ItemCountPerLine;
    return CGSizeMake(len, len);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                                 layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return ItemInsect;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView
                                      layout:(UICollectionViewLayout *)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return ItemInsect;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(ItemInsect, ItemInsect, 0, ItemInsect);
}

#pragma mark - Actions
- (void)onCollectionViewLongPress:(UILongPressGestureRecognizer *)rec {
    UICollectionView *collectionView = (UICollectionView *)rec.view;
    CGPoint p = [rec locationInView:collectionView];
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil) {
        return;
    }
    TUIMultimediaPasterGroupConfig *config = _config.groups[_tabPanel.selectedIndex];
    TUIMultimediaPasterItemConfig *item = config.itemList[indexPath.item];
    if (!item.isUserAdded) {
        return;
    }
    [_delegate pasterSelectView:self
        needDeleteCustomPasterInGroup:_config.groups[_tabPanel.selectedIndex]
                                index:indexPath.item
                     completeCallback:^(BOOL deleted) {
                       if (deleted) {
                           [collectionView reloadData];
                       }
                     }];
}

#pragma mark - TUIMultimediaTabPanelDelegate
- (void)tabPanel:(TUIMultimediaTabPanel *)panel selectedIndexChanged:(NSInteger)selectedIndex {
    [panel.tabs[selectedIndex].view addGestureRecognizer:_longPressRec];
}

#pragma mark - Properties
- (void)setConfig:(TUIMultimediaPasterConfig *)config {
    _config = config;
    _tabPanel.tabs = [_config.groups tui_multimedia_mapWithIndex:^id(TUIMultimediaPasterGroupConfig *config, NSUInteger idx) {
      UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
      layout.scrollDirection = UICollectionViewScrollDirectionVertical;
      UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
      cv.backgroundColor = UIColor.clearColor;
      cv.showsVerticalScrollIndicator = NO;
      cv.delegate = self;
      cv.dataSource = self;
      cv.tag = idx;
      [cv registerClass:TUIMultimediaImageCell.class forCellWithReuseIdentifier:TUIMultimediaImageCell.reuseIdentifier];
      NSString *localizedName = [TUIMultimediaCommon localizedStringForKey:config.name];
      UIImage *icon = [config loadIcon];
      return [[TUIMultimediaTabPanelTab alloc] initWithName:localizedName icon:icon view:cv];
    }];
    [_tabPanel.tabs.firstObject.view addGestureRecognizer:_longPressRec];
}
@end
