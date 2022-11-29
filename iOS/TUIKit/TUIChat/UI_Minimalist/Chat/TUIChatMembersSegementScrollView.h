//
//  TUIChatMembersSegementScrollView.h
//  TUIChat
//
//  Created by wyl on 2022/10/31.
//

#import <UIKit/UIKit.h>

@class TUIChatMembersSegementItem;

NS_ASSUME_NONNULL_BEGIN
typedef void (^btnClickedBlock)(int index);

@interface TUIChatMembersSegementItem : NSObject

@property (nonatomic, copy) NSString * title;

@property (nonatomic, copy) NSString * facePath;

@end

@interface TUIChatMembersSegementView : UIView<UIScrollViewDelegate>
{
    NSInteger nPageIndex;
    NSInteger titleCount;
    UIButton *currentBtn;
    NSMutableArray *btnArray;
}

- (void)setPageIndex:(int)nIndex;

- (instancetype) initWithFrame:(CGRect)frame SegementItems:(NSArray <TUIChatMembersSegementItem *>*)items block : (btnClickedBlock) clickedBlock;

@property (nonatomic, copy) btnClickedBlock block;

@property (strong, nonatomic) UIScrollView *segementScrollView;

@property (strong, nonatomic) UIView *selectedLine;

@end

@interface TUIChatMembersSegementScrollView : UIView

- (instancetype) initWithFrame:(CGRect)frame SegementItems:(NSArray <TUIChatMembersSegementItem *> *)items viewArray:(NSArray *)viewArray;

//Top Tab Button Scroll View (segementView)
@property (strong, nonatomic) TUIChatMembersSegementView *mySegementView;

@property (strong, nonatomic) UIScrollView *pageScrollView;

- (void)updateContainerView;

@end
NS_ASSUME_NONNULL_END
