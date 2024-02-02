//
//  TUIFaceSegementScrollView.m
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/11/15.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFaceSegementScrollView.h"

#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIFitButton.h>
#import <TUICore/TUIThemeManager.h>
#import <TIMCommon/TIMCommonMediator.h>
#import <TIMCommon/TUIEmojiMeditorProtocol.h>

@interface TUIFaceSegementScrollView () <UIScrollViewDelegate>

@property(nonatomic, strong) NSArray<TUIFaceGroup *> *items;

@property(nonatomic, strong) NSMutableArray<TUIFaceVerticalView*> * viewArray;

@end

@implementation TUIFaceSegementScrollView


- (void)setItems:(NSArray<TUIFaceGroup *> *)items delegate:(id <TUIFaceViewDelegate>) delegate {
    _items = items;
    for (UIView *view in self.pageScrollView.subviews) {
        if (view) {
            [view removeFromSuperview];
        }
    }
    [self.viewArray removeAllObjects];
    
    for (int i = 0; i < items.count; i++) {
        TUIFaceVerticalView* faceView = [[TUIFaceVerticalView alloc] initWithFrame:CGRectMake(0, 
                                                                                              0, self.frame.size.width, self.pageScrollView.frame.size.height)];
        TUIFaceGroup *indexGroup = items[i];
        if (indexGroup.recentGroup) {
            [faceView setData:[NSMutableArray arrayWithArray:@[indexGroup.recentGroup,indexGroup]]];
        }
        else {
            [faceView setData:[NSMutableArray arrayWithArray:@[indexGroup]]];
        }

        faceView.frame = CGRectMake(i * self.frame.size.width, 0, self.frame.size.width, self.pageScrollView.frame.size.height);
        faceView.delegate = delegate;
        [self.pageScrollView addSubview:faceView];
        [self.viewArray addObject:faceView];
    }
    self.pageScrollView.contentSize = CGSizeMake(self.viewArray.count * self.frame.size.width, self.pageScrollView.frame.size.height);
    if (isRTL()) {
        _pageScrollView.transform = CGAffineTransformMakeRotation(M_PI);
        NSArray *subViews = _pageScrollView.subviews;
        for (UIView *subView in subViews) {
                subView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }
}
- (void)updateContainerView {
    self.pageScrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    for (int i = 0; i < self.viewArray.count; i++) {
        TUIFaceVerticalView* view = self.viewArray[i];
        view.frame = CGRectMake(i * self.pageScrollView.frame.size.width, 0, self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height);
    }

    self.pageScrollView.contentSize = CGSizeMake(self.viewArray.count * self.frame.size.width, self.pageScrollView.frame.size.height);
}


- (UIScrollView *)pageScrollView {
    if (_pageScrollView == nil) {
        _pageScrollView = [[UIScrollView alloc]
                           initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _pageScrollView.backgroundColor = [UIColor clearColor];
        _pageScrollView.delegate = self;
        _pageScrollView.showsVerticalScrollIndicator = NO;
        _pageScrollView.showsHorizontalScrollIndicator = NO;
        _pageScrollView.bounces = NO;
        _pageScrollView.scrollsToTop = NO;
        _pageScrollView.pagingEnabled = YES;
        [self addSubview:_pageScrollView];
    }
    return _pageScrollView;
}
- (NSMutableArray<TUIFaceVerticalView *> *)viewArray {
    if(!_viewArray) {
        _viewArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _viewArray;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _pageScrollView) {
        int p = _pageScrollView.contentOffset.x / self.frame.size.width;
        if (self.onScrollCallback){
            self.onScrollCallback(p);
        }
    }
}

- (void)setPageIndex:(NSInteger)index {
    CGPoint p =  CGPointMake(_pageScrollView.frame.size.width * index,0);
    [_pageScrollView setContentOffset:p animated:NO];
}

- (void)setAllFloatCtrlViewAllowSendSwitch:(BOOL)isAllow {
    for (TUIFaceVerticalView *view in self.viewArray) {
        [view setFloatCtrlViewAllowSendSwitch:isAllow];
    }
}
- (void)updateRecentView {
    id<TUIEmojiMeditorProtocol> service = [[TIMCommonMediator share] getObject:@protocol(TUIEmojiMeditorProtocol)];
    TUIFaceVerticalView* faceView = self.viewArray[0];
    TUIFaceGroup *indexGroup = self.items[0];
    indexGroup.recentGroup = [service getChatPopMenuRecentQueue];
    indexGroup.recentGroup.rowCount = 1;
    indexGroup.recentGroup.itemCountPerRow = 8;
    indexGroup.recentGroup.groupName = TIMCommonLocalizableString(TUIChatFaceGroupRecentEmojiName);
    if (indexGroup.isNeedAddInInputBar && indexGroup.recentGroup) {
        [faceView setData:[NSMutableArray arrayWithArray:@[indexGroup.recentGroup,indexGroup]]];
    }
    else {
        [faceView setData:[NSMutableArray arrayWithArray:@[indexGroup]]];
    }
}
@end
