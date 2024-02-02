//
//  TUIReactMembersSegementScrollView.h
//  TUIChat
//
//  Created by wyl on 2022/10/31.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUIReactMembersSegementItem;

NS_ASSUME_NONNULL_BEGIN
typedef void (^btnClickedBlock)(int index);

@interface TUIReactMembersSegementItem : NSObject

@property(nonatomic, copy) NSString *title;

@property(nonatomic, copy) NSString *facePath;

@end

@interface TUIReactMembersSegementButtonView : UIView

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIImageView * img;
@property (nonatomic,strong) UILabel * title;

@end

@interface TUIReactMembersSegementView : UIView <UIScrollViewDelegate> {
    NSInteger nPageIndex;
    NSInteger titleCount;
    TUIReactMembersSegementButtonView *currentBtn;
    NSMutableArray *btnArray;
}

- (void)setPageIndex:(int)nIndex;

- (instancetype)initWithFrame:(CGRect)frame SegementItems:(NSArray<TUIReactMembersSegementItem *> *)items block:(btnClickedBlock)clickedBlock;

@property(nonatomic, copy) btnClickedBlock block;

@property(strong, nonatomic) UIScrollView *segementScrollView;

@property(strong, nonatomic) UIView *selectedLine;

@end

@interface TUIReactMembersSegementScrollView : UIView

- (instancetype)initWithFrame:(CGRect)frame SegementItems:(NSArray<TUIReactMembersSegementItem *> *)items viewArray:(NSArray *)viewArray;

// Top Tab Button Scroll View (segementView)
@property(strong, nonatomic) TUIReactMembersSegementView *mySegementView;

@property(strong, nonatomic) UIScrollView *pageScrollView;

- (void)updateContainerView;

@end
NS_ASSUME_NONNULL_END
