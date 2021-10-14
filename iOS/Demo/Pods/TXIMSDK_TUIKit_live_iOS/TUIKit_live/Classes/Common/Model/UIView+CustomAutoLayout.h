//
//  UIView+CustomAutoLayout.h
//  CommonLibrary
//
//  Created by Alexi on 13-11-20.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#import <UIKit/UIKit.h>

// 使用装饰模式进行自动布局处理

#ifdef DEBUG

#define IsArgInvalid(curView, brotherView) NSAssert((self.superview == brotherView.superview) && !(CGRectEqualToRect(brotherView.frame, CGRectZero)), @"UIView (CustomAutoLayout)参数出错")
#define IsSuperViewInvalid(curView) NSAssert((self.superview != nil), @"UIView (CustomAutoLayout)父控件没有设置参数出错")

#else

#define IsArgInvalid(curView, brotherView) 
#define IsSuperViewInvalid(curView) 

#endif



@interface UIView (CustomAutoLayout)


- (UIView *)sameWith:(UIView *)brotherView;

// 同一控件内两子之空间之间的相对位置
// margin 之间的空隙
// brotherView.superView与self.superView相同
// brotherView必须要先设置了frame

// 会影响origin的位置，会影响其高度
- (UIView *)layoutAbove:(UIView *)brotherView;
- (UIView *)layoutAbove:(UIView *)brotherView margin:(CGFloat)margin;

- (UIView *)layoutBelow:(UIView *)brotherView;
- (UIView *)layoutBelow:(UIView *)brotherView margin:(CGFloat)margin;

// 会影响origin的位置，会影响其宽度
- (UIView *)layoutToLeftOf:(UIView *)brotherView;
- (UIView *)layoutToLeftOf:(UIView *)brotherView margin:(CGFloat)margin;

- (UIView *)layoutToRightOf:(UIView *)brotherView;
- (UIView *)layoutToRightOf:(UIView *)brotherView margin:(CGFloat)margin;


// 填充式布局
- (UIView *)scaleToAboveOf:(UIView *)brotherView;
- (UIView *)scaleToAboveOf:(UIView *)brotherView margin:(CGFloat)margin;

- (UIView *)scaleToBelowOf:(UIView *)brotherView;
- (UIView *)scaleToBelowOf:(UIView *)brotherView margin:(CGFloat)margin;

- (UIView *)scaleToLeftOf:(UIView *)brotherView;
- (UIView *)scaleToLeftOf:(UIView *)brotherView margin:(CGFloat)margin;

- (UIView *)scaleToRightOf:(UIView *)brotherView;
- (UIView *)scaleToRightOf:(UIView *)brotherView margin:(CGFloat)margin;


// 相对父控件进行填充
- (UIView *)scaleParent;
- (UIView *)scaleToParentTop;
- (UIView *)scaleToParentTopWithMargin:(CGFloat)margin;

- (UIView *)scaleToParentBottom;
- (UIView *)scaleToParentBottomWithMargin:(CGFloat)margin;

- (UIView *)scaleToParentLeft;
- (UIView *)scaleToParentLeftWithMargin:(CGFloat)margin;

- (UIView *)scaleToParentRight;
- (UIView *)scaleToParentRightWithMargin:(CGFloat)margin;


// 同一控件内两子之空间之间的对齐关系
// 会影响origin的位置, 不影响大小
- (UIView *)alignTop:(UIView *)brotherView;
- (UIView *)alignTop:(UIView *)brotherView margin:(CGFloat)margin;

- (UIView *)alignBottom:(UIView *)brotherView;
- (UIView *)alignBottom:(UIView *)brotherView margin:(CGFloat)margin;

- (UIView *)alignLeft:(UIView *)brotherView;
- (UIView *)alignLeft:(UIView *)brotherView margin:(CGFloat)margin;

- (UIView *)alignRight:(UIView *)brotherView;
- (UIView *)alignRight:(UIView *)brotherView margin:(CGFloat)margin;


- (UIView *)alignHorizontalCenterOf:(UIView *)brotherView;
- (UIView *)alignVerticalCenterOf:(UIView *)brotherView;
- (UIView *)alignCenterOf:(UIView *)brotherView;

- (UIView *)moveCenterTo:(CGPoint)center;
- (UIView *)move:(CGPoint)vec;


// 与父控件对齐的关系
// 只影响其坐标位置，不影响其大小
- (UIView *)alignParentTop;
- (UIView *)alignParentBottom;
- (UIView *)alignParentLeft;
- (UIView *)alignParentRight;

- (UIView *)alignParentCenter;
- (UIView *)alignParentCenter:(CGPoint)margin;

- (UIView *)alignParentTopWithMargin:(CGFloat)margin;
- (UIView *)alignParentBottomWithMargin:(CGFloat)margin;
- (UIView *)alignParentLeftWithMargin:(CGFloat)margin;
- (UIView *)alignParentRightWithMargin:(CGFloat)margin;

// 与父控件的边距
// 只影响其坐标位置，影响其大小
- (UIView *)marginParetnTop:(CGFloat)top bottom:(CGFloat)bottom left:(CGFloat)left rigth:(CGFloat)right;
- (UIView *)marginParentWithEdgeInsets:(UIEdgeInsets)inset;
- (UIView *)marginParetn:(CGFloat)margin;
- (UIView *)marginParetnHorizontal:(CGFloat)margin;
- (UIView *)marginParetnVertical:(CGFloat)margin;
- (UIView *)marginParentTop:(CGFloat)margin;
- (UIView *)marginParentBottom:(CGFloat)margin;
- (UIView *)marginParentLeft:(CGFloat)margin;
- (UIView *)marginParentRight:(CGFloat)margin;


// 控件在父控控件中的位置
// 水平居中
// 只影响其坐标位置，不影响其大小
- (UIView *)layoutParentHorizontalCenter;
// 垂直居中
- (UIView *)layoutParentVerticalCenter;
// 居中
- (UIView *)layoutParentCenter;


// 与其他控件的大小关系
// 影响其大小
- (UIView *)widthEqualTo:(UIView *)brotherView;
- (UIView *)heigthEqualTo:(UIView *)brotherView;
- (UIView *)sizeEqualTo:(UIView *)brotherView;
- (UIView *)sizeWith:(CGSize)size;

- (UIView *)shrink:(CGSize)size;
- (UIView *)shrinkHorizontal:(CGFloat)margin;
- (UIView *)shrinkVertical:(CGFloat)margin;



- (UIView *)alignViews:(NSArray *)array isSubView:(BOOL)isSub padding:(CGFloat)padding margin:(CGFloat)margin horizontal:(BOOL)ishorizontal inRect:(CGRect)rect;
// views里面的View都是按UI的指定顺序放好的
- (UIView *)alignSubviews:(NSArray *)views horizontallyWithPadding:(CGFloat)padding margin:(CGFloat)margin inRect:(CGRect)rect;
- (UIView *)alignSubviews:(NSArray *)views verticallyWithPadding:(CGFloat)padding margin:(CGFloat)margin inRect:(CGRect)rect;

- (UIView *)alignSubviewsHorizontallyWithPadding:(CGFloat)padding margin:(CGFloat)margin;
- (UIView *)alignSubviewsVerticallyWithPadding:(CGFloat)padding margin:(CGFloat)margin;



// 使views以Grid方式均匀显示
- (UIView *)gridViews:(NSArray *)views inColumn:(NSInteger)column size:(CGSize)cellSize margin:(CGSize)margin inRect:(CGRect)rect;


@end
