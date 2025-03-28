//
//  TUIReactMembersSegementScrollView.m
//  TUIChat
//
//  Created by wyl on 2022/10/31.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReactMembersSegementScrollView.h"
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIFitButton.h>
#import <TUICore/TUIThemeManager.h>

#define SEGEMENT_BTN_WIDTH kScale390(43)
#define SEGEMENT_BTN_HEIGHT kScale390(20)

@implementation TUIReactMembersSegementItem

@end

@implementation TUIReactMembersSegementButtonView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.img];
    [self.contentView addSubview:self.title];
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}
- (UIImageView *)img {
    if (!_img) {
        _img = [[UIImageView alloc] init];
    }
    return _img;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:kScale390(12)];
        _title.tintColor = [UIColor tui_colorWithHex:@"#141516"];
    }
    return _title;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.img);
        make.center.mas_equalTo(self);
        make.trailing.mas_equalTo(self.title);
        make.height.mas_equalTo(self);
    }];
    [self.img mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).mas_offset(kScale390(3));
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(kScale390(12));
    }];
    [self.title sizeToFit];
    [self.title mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.img.mas_trailing).mas_offset(kScale390(5));
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(self.title.frame.size.width);
        make.height.mas_equalTo(self.title.font.lineHeight);
    }];
}

@end
@implementation TUIReactMembersSegementView

- (instancetype)initWithFrame:(CGRect)frame SegementItems:(NSArray<TUIReactMembersSegementItem *> *)items block:(btnClickedBlock)clickedBlock {
    self = [super initWithFrame:frame];

    if (self) {
        [self addSubview:self.segementScrollView];
        self.block = clickedBlock;
        nPageIndex = 1;
        titleCount = items.count;
        btnArray = [NSMutableArray array];
        CGFloat padding = kScale390(8);
        TUIReactMembersSegementButtonView *preBtn = nil;
        for (int i = 0; i < titleCount; i++) {
            TUIReactMembersSegementButtonView *btn = nil;
            if (preBtn == nil) {
                btn = [[TUIReactMembersSegementButtonView alloc] initWithFrame:CGRectMake(0,
                                                                 (self.frame.size.height - SEGEMENT_BTN_HEIGHT) * 0.5, SEGEMENT_BTN_WIDTH, SEGEMENT_BTN_HEIGHT)];
                currentBtn = btn;
            }
            else {
                btn = [[TUIReactMembersSegementButtonView alloc] initWithFrame:CGRectMake(preBtn.frame.origin.x + preBtn.frame.size.width + padding,
                                                                 (self.frame.size.height - SEGEMENT_BTN_HEIGHT) * 0.5, SEGEMENT_BTN_WIDTH, SEGEMENT_BTN_HEIGHT)];
            }
            preBtn = btn;
            btn.title.text = items[i].title;
            btn.img.image = [[TUIImageCache sharedInstance] getFaceFromCache:items[i].facePath];
            btn.tag = i + 1;
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClick:)];
            [btn addGestureRecognizer:tapGesture];
            [self.segementScrollView addSubview:btn];
            [btnArray addObject:btn];
        }

        self.selectedLine.frame =
            CGRectMake(currentBtn.frame.origin.x, (self.frame.size.height - SEGEMENT_BTN_HEIGHT) * 0.5, MAX(currentBtn.frame.size.width, SEGEMENT_BTN_WIDTH), SEGEMENT_BTN_HEIGHT);
        self.selectedLine.layer.cornerRadius = kScale390(10);

        [self.segementScrollView addSubview:self.selectedLine];
        self.segementScrollView.contentSize = CGSizeMake(titleCount * SEGEMENT_BTN_WIDTH + (padding * titleCount - 1), 0);
        if (isRTL()) {
            self.segementScrollView.transform = CGAffineTransformMakeRotation(M_PI);
            NSArray *subViews = self.segementScrollView.subviews;
            for (UIView *subView in subViews) {
                    subView.transform = CGAffineTransformMakeRotation(M_PI);
            }
        }
    }
    return self;
}

- (UIScrollView *)segementScrollView {
    if (_segementScrollView == nil) {
        CGRect rect = self.bounds;
        _segementScrollView = [[UIScrollView alloc] initWithFrame:rect];
        _segementScrollView.showsHorizontalScrollIndicator = NO;
        _segementScrollView.showsVerticalScrollIndicator = NO;
        _segementScrollView.bounces = NO;
        _segementScrollView.pagingEnabled = NO;
        _segementScrollView.delegate = self;
        _segementScrollView.scrollsToTop = NO;
    }
    return _segementScrollView;
}

- (UIView *)selectedLine {
    if (_selectedLine == nil) {
        _selectedLine = [[UIView alloc] init];
        _selectedLine.backgroundColor = [[UIColor tui_colorWithHex:@"#F9F9F9"] colorWithAlphaComponent:0.54];
    }
    return _selectedLine;
}

- (void)setPageIndex:(int)nIndex {
    if (nIndex != nPageIndex) {
        nPageIndex = nIndex;
        [self refreshSegement];
    }
}

- (void)refreshSegement {
    for (TUIReactMembersSegementButtonView *btn in btnArray) {
        if (btn.tag == nPageIndex) {
            currentBtn = btn;
        }
    }

    if (currentBtn.frame.origin.x + SEGEMENT_BTN_WIDTH > self.frame.size.width + self.segementScrollView.contentOffset.x) {
        [self.segementScrollView setContentOffset:CGPointMake(self.segementScrollView.contentOffset.x + SEGEMENT_BTN_WIDTH, 0) animated:YES];
    }

    else if (currentBtn.frame.origin.x < self.segementScrollView.contentOffset.x) {
        [self.segementScrollView setContentOffset:CGPointMake(currentBtn.frame.origin.x, 0) animated:YES];
    }

    [UIView animateWithDuration:0.2
                     animations:^{
                       self.selectedLine.frame =
                           CGRectMake(currentBtn.frame.origin.x, (self.frame.size.height - SEGEMENT_BTN_HEIGHT) * 0.5, currentBtn.frame.size.width, SEGEMENT_BTN_HEIGHT);
                       self.selectedLine.layer.cornerRadius = kScale390(10);
                     }
                     completion:^(BOOL finished){

                     }];
}

- (void)btnClick:(UIGestureRecognizer *)recognizer {
    TUIReactMembersSegementButtonView *btn =  (id)recognizer.view;
    currentBtn = btn;
    if (nPageIndex != btn.tag) {
        [self showHapticFeedback];
        nPageIndex = btn.tag;
        [self refreshSegement];
        self.block(nPageIndex);
    }
}

- (void)showHapticFeedback {
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
          UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
          [generator prepare];
          [generator impactOccurred];
        });

    } else {
        // Fallback on earlier versions
    }
}

@end

#define SCROLLVIEW_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCROLLVIEW_HEIGTH self.bounds.size.height
#define SEGEMENT_HEIGTHT 22

@interface TUIReactMembersSegementScrollView () <UIScrollViewDelegate>

@property(nonatomic, strong) NSArray<TUIReactMembersSegementItem *> *items;

@property(nonatomic, strong) NSArray *viewArray;

@end

@implementation TUIReactMembersSegementScrollView

- (instancetype)initWithFrame:(CGRect)frame SegementItems:(NSArray<TUIReactMembersSegementItem *> *)items viewArray:(NSArray *)viewArray {
    self = [super initWithFrame:frame];
    self.items = items;
    self.viewArray = viewArray;
    [self addSubview:self.mySegementView];
    [self addSubview:self.pageScrollView];

    if (self) {
        for (int i = 0; i < viewArray.count; i++) {
            UIViewController *viewController = viewArray[i];
            viewController.view.frame = CGRectMake(i * SCROLLVIEW_WIDTH, 0, SCROLLVIEW_WIDTH, self.pageScrollView.frame.size.height);
            [self.pageScrollView addSubview:viewController.view];
        }
        self.pageScrollView.contentSize = CGSizeMake(viewArray.count * SCROLLVIEW_WIDTH, self.pageScrollView.frame.size.height);
        if (isRTL()) {
            _pageScrollView.transform = CGAffineTransformMakeRotation(M_PI);
            NSArray *subViews = _pageScrollView.subviews;
            for (UIView *subView in subViews) {
                    subView.transform = CGAffineTransformMakeRotation(M_PI);
            }
        }
    }

    return self;
}

- (void)updateContainerView {
    self.pageScrollView.frame = CGRectMake(0, _mySegementView.frame.size.height, SCROLLVIEW_WIDTH, self.bounds.size.height - _mySegementView.frame.size.height);

    for (int i = 0; i < self.viewArray.count; i++) {
        UIViewController *viewController = self.viewArray[i];
        viewController.view.frame = CGRectMake(i * SCROLLVIEW_WIDTH, 0, SCROLLVIEW_WIDTH, self.pageScrollView.frame.size.height);
    }

    self.pageScrollView.contentSize = CGSizeMake(self.viewArray.count * SCROLLVIEW_WIDTH, self.pageScrollView.frame.size.height);
}

- (TUIReactMembersSegementView *)mySegementView {
    if (_mySegementView == nil) {
        _mySegementView = [[TUIReactMembersSegementView alloc] initWithFrame:CGRectMake(kScale390(27), 0, SCROLLVIEW_WIDTH - kScale390(54), SEGEMENT_HEIGTHT)
                                                              SegementItems:_items
                                                                      block:^(int index) {
                                                                        [_pageScrollView setContentOffset:CGPointMake((index - 1) * SCROLLVIEW_WIDTH, 0)];
                                                                      }];
    }
    return _mySegementView;
}

- (UIScrollView *)pageScrollView {
    if (_pageScrollView == nil) {
        _pageScrollView = [[UIScrollView alloc]
            initWithFrame:CGRectMake(0, _mySegementView.frame.size.height, SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGTH - _mySegementView.frame.size.height)];
        _pageScrollView.backgroundColor = [UIColor clearColor];
        _pageScrollView.delegate = self;
        _pageScrollView.showsVerticalScrollIndicator = NO;
        _pageScrollView.showsHorizontalScrollIndicator = NO;
        _pageScrollView.bounces = NO;
        _pageScrollView.scrollsToTop = NO;
        _pageScrollView.pagingEnabled = YES;
    }
    return _pageScrollView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _pageScrollView) {
        int p = _pageScrollView.contentOffset.x / SCROLLVIEW_WIDTH;
        [_mySegementView setPageIndex:p + 1];
    }
}

@end
