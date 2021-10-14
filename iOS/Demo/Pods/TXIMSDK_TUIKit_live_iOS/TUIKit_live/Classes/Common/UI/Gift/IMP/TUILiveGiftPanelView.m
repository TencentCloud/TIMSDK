//
//  TUILiveGiftPannelView.m
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import "Masonry.h"
#import "TUIDefine.h"

#import "TUILiveGiftPanelView.h"
#import "TUILiveGiftDataSource.h"
#import "TUILiveGiftPanelDelegate.h"
#import "TUILiveGiftPanelCell.h"
#import "TUILiveGiftPanelBottomView.h"
#import "TUILiveGiftDataSource.h"
#import "TUILiveGiftInfo.h"
#import "TUILiveGiftPanelCollectionViewLayout.h"
#import "TUILiveGiftInfoDataHandler.h"

#define kGiftPannelViewBottomViewHeight     40          // 礼物面板底部视图高度
#define kGiftPannelViewCollectionViewHeight 260         // 礼物面板collectinView的高度
#define kMaxGiftColumns                     4           // 每行最大礼物个数
#define kGiftRows                           2           // 礼物面板行数
#define kScreenWidth UIScreen.mainScreen.bounds.size.width
#define kScreenHeight UIScreen.mainScreen.bounds.size.height

@interface TUILiveGiftPanelView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) id<TUILiveGiftPanelDelegate> delegate;

@property (nonatomic, strong) UIView *backgroundView;               // 背景视图
@property (nonatomic, strong) UICollectionView *collectionView;     // 礼物视图
@property (nonatomic, strong) UIPageControl *pageControl;           // 分页控件
@property (nonatomic, strong) TUILiveGiftPanelBottomView *bottomView;    // 底部视图,包括了充值按钮等

@property (nonatomic, strong) TUILiveGiftInfoDataHandler *dataProvider;
@property (nonatomic, strong) NSArray *gifts;
@property (nonatomic, weak) TUILiveGiftInfo *selectedGift;

@end

@implementation TUILiveGiftPanelView

static NSString *const reuseId = @"gift";

- (instancetype)initWithProvider:(TUILiveGiftInfoDataHandler *)dataProvider;
{
    if (self = [super init]) {
        _dataProvider = dataProvider;
        [self loadList];
    }
    return self;
}

#pragma mark - TUILiveGiftPannelViewProtocol
- (void)showInView:(UIView *)view
{
    [self showInView:view animate:YES];
}

- (void)hide
{
    [self hide:YES];
}

- (void)setGiftPannelDelegate:(id<TUILiveGiftPanelDelegate>)delegate
{
    self.delegate = delegate;
}

- (void)layoutAnimateView
{
    self.backgroundColor = [UIColor clearColor];
    [self.animateView addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.collectionView];
    self.animateView.layer.cornerRadius = 8.0;
    self.backgroundView.layer.cornerRadius = 8.0;
    [self.backgroundView addSubview:self.pageControl];
    [self.backgroundView addSubview:self.bottomView];

    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.mas_equalTo(self.animateView);
    }];

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.backgroundView);
        make.height.mas_equalTo(kGiftPannelViewBottomViewHeight);
    }];

    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.backgroundView);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
        make.height.mas_equalTo(10);
    }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backgroundView).offset(108);
        make.leading.trailing.mas_equalTo(self.backgroundView);
        make.bottom.mas_equalTo(self.pageControl.mas_top);
    }];
    
    //send gift button
    UIButton *sendGift = [UIButton new];
    [sendGift setBackgroundColor:[UIColor colorWithRed:255/255.0 green:83/255.0 blue:83/255.0 alpha:1/1.0]];
    [[sendGift titleLabel] setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:14]];
    [sendGift setTitle:@"确认打赏" forState:UIControlStateNormal];
    [sendGift setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backgroundView addSubview:sendGift];
    [sendGift mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(76);
        make.height.mas_equalTo(32);
        make.trailing.mas_equalTo(-12);
        make.centerY.mas_equalTo(self.backgroundView.mas_top).offset(44);
    }];
    sendGift.layer.cornerRadius = 16;
    [sendGift addTarget:self action:@selector(sendSelectedGift) forControlEvents:UIControlEventTouchUpInside];
    
    //tip
    UILabel *giftTip = [UILabel new];
    giftTip.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    giftTip.textColor = UIColor.blackColor;
    giftTip.text = @"直播不易，打赏主播一个小礼物吧";
    [self.backgroundView addSubview:giftTip];
    [giftTip setAdjustsFontSizeToFitWidth:YES];
    [giftTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.centerY.mas_equalTo(sendGift);
        make.height.mas_equalTo(22);
        make.trailing.mas_equalTo(sendGift.mas_leading).offset(12);
    }];
    
    //line
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.backgroundView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(giftTip.mas_bottom).offset(28);
        make.leading.trailing.mas_equalTo(self.backgroundView);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)sendSelectedGift {
    if (self.selectedGift != nil) {
        if ([self.delegate respondsToSelector:@selector(onGiftItemClick:)]) {
            [self.delegate onGiftItemClick:self.selectedGift];
        }
    } else {
        [TUITool makeToast:@"请选择一个礼物"];
    }
}

- (CGFloat)animateViewHeight
{
    return 368;
}

- (void)tapCover
{
    [self hide:YES];
}

- (void)loadList
{
    if (self.dataProvider) {
        __weak typeof(self) weakSelf = self;
        [self.dataProvider queryGiftInfoList:^(NSArray<TUILiveGiftInfo *> * _Nullable list, NSString * _Nullable errMsg) {
            if (errMsg.length) {
                [TUITool makeToast:errMsg];
                return;
            }
            weakSelf.gifts = [NSArray arrayWithArray:list?:@[]];
            
            if ([NSThread isMainThread]) {
                [weakSelf updatePageControl];
                [weakSelf.collectionView reloadData];
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf updatePageControl];
                    [weakSelf.collectionView reloadData];
                });
            }
        }];
    }
}

- (void)updatePageControl
{
    // 计算页数
    NSInteger columns = kMaxGiftColumns;
    if ([self.dataProvider respondsToSelector:@selector(getColumnNum)]) {
        columns = [self.dataProvider getColumnNum];
    }
    NSInteger rows   = kGiftRows;
    NSInteger totals = self.gifts.count;
    NSInteger pageCount = columns * rows;
    NSInteger pages = totals / pageCount;
    NSInteger remain = totals % pageCount;
    if (totals <= pageCount) {
        pages = 1;
    }else {
        if (remain != 0) {
            pages = pages + 1;
        }
    }
    
    self.pageControl.numberOfPages = pages;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.gifts.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TUILiveGiftPanelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.item < 0 || indexPath.item >= self.gifts.count) {
        return cell;
    }
    
    TUILiveGiftInfo *gift = self.gifts[indexPath.item];
    cell.giftInfo = gift;
    __weak typeof(self) weakSelf = self;
    cell.onSendGift = ^(TUILiveGiftInfo * _Nonnull gift) {
        if ([weakSelf.delegate respondsToSelector:@selector(onGiftItemClick:)]) {
            [weakSelf.delegate onGiftItemClick:gift];
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < 0 || indexPath.item >= self.gifts.count) {
        return;
    }
    
    TUILiveGiftInfo *gift = self.gifts[indexPath.item];
    gift.selected = YES;
    
    self.selectedGift.selected = NO;
    self.selectedGift = gift;
    
    [collectionView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSLog(@"当前页码: %zd", page);
    self.pageControl.currentPage = page;
}


#pragma mark - Lazy
- (UIView *)backgroundView
{
    if (_backgroundView == nil) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
    }
    return _backgroundView;
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        int num = kMaxGiftColumns;
        if ([self.dataProvider respondsToSelector:@selector(getColumnNum)]) {
            num = [self.dataProvider getColumnNum];
        }
        TUILiveGiftPanelCollectionViewLayout *layout = [[TUILiveGiftPanelCollectionViewLayout alloc] init];
        layout.rows = kGiftRows;
        layout.columns = num;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kScreenWidth / num, 100);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:TUILiveGiftPanelCell.class forCellWithReuseIdentifier:reuseId];
    }
    return _collectionView;
}


- (UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.numberOfPages = 1;
        _pageControl.currentPage = 0;
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

- (TUILiveGiftPanelBottomView *)bottomView
{
    if (_bottomView == nil) {
        _bottomView = [[TUILiveGiftPanelBottomView alloc] init];
        __weak typeof(self) weakSelf = self;
        _bottomView.onClick = ^(TUILiveGiftBottomBussinessType type, id  _Nullable info) {
            if (type == TUILiveGiftBottomBussinessTypeCharge) {
                if ([weakSelf.delegate respondsToSelector:@selector(onChargeClick)]) {
                    [weakSelf.delegate onChargeClick];
                }
            }
        };
    }
    return _bottomView;
}



@end
