//
//  UIView+CustomAutoLayout.m
//  CommonLibrary
//
//  Created by Alexi on 13-11-20.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#import "UIView+CustomAutoLayout.h"

@implementation UIView (CustomAutoLayout)

- (UIView *)sameWith:(UIView *)brotherView
{
    IsArgInvalid(self, brotherView);
    self.frame = brotherView.frame;
    return self;
}

// 同一控件内两子之空间之间的相对位置
// margin 之间的空隙
// brotherView.superView与self.superView相同
// brotherView必须要先设置了frame

//- (BOOL)isArgValid:(UIView *)brotherView
//{
//    return (self.superview == brotherView.superview) && (CGRectEqualToRect(brotherView.frame, CGRectZero));
//}

// 会影响origin的位置，会影响其高度
- (UIView *)layoutAbove:(UIView *)brotherView
{
    return [self layoutAbove:brotherView margin:0];
}

- (UIView *)layoutAbove:(UIView *)brotherView margin:(CGFloat)margin
{
//    BOOL vailed = (self.superview == brotherView.superview) && !(CGRectEqualToRect(brotherView.frame, CGRectZero));
//    NSAssert(vailed, @"UIView (CustomAutoLayout)参数出错");
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    rect.origin.y = brect.origin.y - margin - rect.size.height;
    self.frame = rect;
    return self;
}

- (UIView *)layoutBelow:(UIView *)brotherView
{
    return [self layoutBelow:brotherView margin:0];
}
- (UIView *)layoutBelow:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    rect.origin.y = brect.origin.y + brect.size.height + margin;
    self.frame = rect;
    return self;

}

// 会影响origin的位置，会影响其宽度
- (UIView *)layoutToLeftOf:(UIView *)brotherView
{
    return [self layoutToLeftOf:brotherView margin:0];
}
- (UIView *)layoutToLeftOf:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    rect.origin.x = brect.origin.x - margin - rect.size.width;
    self.frame = rect;
    return self;
}

- (UIView *)layoutToRightOf:(UIView *)brotherView
{
    return [self layoutToRightOf:brotherView margin:0];
}
- (UIView *)layoutToRightOf:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    rect.origin.x = brect.origin.x + brect.size.width + margin;
    self.frame = rect;
    return self;
}

///填充式布局
- (UIView *)scaleToAboveOf:(UIView *)brotherView
{
    return [self scaleToAboveOf:brotherView margin:0];
}
- (UIView *)scaleToAboveOf:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    
    if (brect.origin.y > rect.origin.y)
    {
        rect.size.height = brect.origin.y - margin - rect.origin.y;
    }
    else
    {
        rect.size.height =  rect.origin.y + rect.size.height - (brect.origin.y + margin);
        rect.origin.y = brect.origin.y + margin;
    }


    self.frame = rect;
    return self;
}

- (UIView *)scaleToBelowOf:(UIView *)brotherView
{
     return [self scaleToBelowOf:brotherView margin:0];
}
- (UIView *)scaleToBelowOf:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    
    if (rect.origin.y < brect.origin.y + brect.size.height) {
        rect.size.height =  brect.origin.y + brect.size.height - margin - rect.origin.y;
    }
    else
    {
        rect.size.height =  rect.origin.y + rect.size.height - (margin + brect.origin.y + brect.size.height);
        rect.origin.y = (margin + brect.origin.y + brect.size.height);
    }
    
    self.frame = rect;
    return self;
}

- (UIView *)scaleToLeftOf:(UIView *)brotherView
{
    return [self scaleToLeftOf:brotherView margin:0];
}
- (UIView *)scaleToLeftOf:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    
    if (rect.origin.x < brect.origin.x)
    {
        rect.size.width = brect.origin.x - margin - rect.origin.x;
    }
    else
    {
        rect.size.width = rect.origin.x + rect.size.width - (margin + brect.origin.x);
        rect.origin.x = brect.origin.x + margin;
    }
    
    self.frame = rect;
    return self;
}

- (UIView *)scaleToRightOf:(UIView *)brotherView
{
    return [self scaleToRightOf:brotherView margin:0];
}
- (UIView *)scaleToRightOf:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    
    if (rect.origin.x < brect.origin.x + brect.size.width)
    {
        rect.size.width = brect.origin.x + brect.size.width - margin - rect.origin.x;
    }
    else
    {
        rect.size.width = rect.origin.x + rect.size.width - (brect.origin.x + brect.size.width - margin);
        rect.origin.x = brect.origin.x + brect.size.width - margin;
    }

    self.frame = rect;
    return self;
}

- (UIView *)scaleParent
{
    self.frame = self.superview.bounds;
    return self;
}

- (UIView *)scaleToParentTop
{
    return [self scaleToParentTopWithMargin:0];
}
- (UIView *)scaleToParentTopWithMargin:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect sRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.size.height = rect.origin.y + rect.size.height - (sRect.origin.y + margin);
    rect.origin.y = sRect.origin.y + margin;
    self.frame = rect;
    return self;
}

- (UIView *)scaleToParentBottom
{
    return [self scaleToParentBottomWithMargin:0];
}

- (UIView *)scaleToParentBottomWithMargin:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect sRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.size.height = sRect.origin.y + sRect.size.height - margin - rect.origin.y;
    self.frame = rect;
    return self;
}

- (UIView *)scaleToParentLeft
{
    return [self scaleToParentLeftWithMargin:0];
}
- (UIView *)scaleToParentLeftWithMargin:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect sRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.size.width = rect.origin.x + rect.size.width - (sRect.origin.x + margin);
    rect.origin.x = sRect.origin.x + margin;
    self.frame = rect;
    return self;
}

- (UIView *)scaleToParentRight
{
    return [self scaleToParentRightWithMargin:0];
}

- (UIView *)scaleToParentRightWithMargin:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect sRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.size.width = sRect.origin.x + sRect.size.width - margin - rect.origin.x;
    self.frame = rect;
    return self;
}


// 同一控件内两子之空间之间的对齐关系
// 会影响origin的位置, 不影响大小
- (UIView *)alignTop:(UIView *)brotherView
{
    return [self alignTop:brotherView margin:0];
}

- (UIView *)alignTop:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    rect.origin.y = brect.origin.y - margin;
    self.frame = rect;
    return self;
}

- (UIView *)alignBottom:(UIView *)brotherView
{
    return [self alignBottom:brotherView margin:0];
}

- (UIView *)alignBottom:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    rect.origin.y = brect.origin.y + brect.size.height - rect.size.height - margin;
    self.frame = rect;
    return self;
}

- (UIView *)alignLeft:(UIView *)brotherView
{
    return [self alignLeft:brotherView margin:0];
}

- (UIView *)alignLeft:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    rect.origin.x = brotherView.frame.origin.x + margin;
    self.frame = rect;
    return self;
}

- (UIView *)alignRight:(UIView *)brotherView
{
    return [self alignRight:brotherView margin:0];
}

- (UIView *)alignRight:(UIView *)brotherView margin:(CGFloat)margin
{
    IsArgInvalid(self, brotherView);
    CGRect rect = self.frame;
    CGRect brect = brotherView.frame;
    rect.origin.x = brect.origin.x + brect.size.width - rect.size.width - margin;
    self.frame = rect;
    return self;
}

- (UIView *)alignHorizontalCenterOf:(UIView *)brotherView
{
    IsArgInvalid(self, brotherView);
    CGPoint bCenter = brotherView.center;
    CGPoint center = self.center;
    center.x = bCenter.x;
    self.center = center;
    return self;

}
- (UIView *)alignVerticalCenterOf:(UIView *)brotherView
{
    IsArgInvalid(self, brotherView);
    CGPoint bCenter = brotherView.center;
    CGPoint center = self.center;
    center.y = bCenter.y;
    self.center = center;
    return self;
}
- (UIView *)alignCenterOf:(UIView *)brotherView
{
    IsArgInvalid(self, brotherView);
    self.center = brotherView.center;
    return self;
}

- (UIView *)moveCenterTo:(CGPoint)center
{
    self.center = center;
    return self;
}

- (UIView *)move:(CGPoint)vec
{
    CGPoint c = self.center;
    c.x += vec.x;
    c.y += vec.y;
    self.center = c;
    return self;
}


// 与父控件对齐的关系
// 只影响其坐标位置，不影响其大小
- (UIView *)alignParentTop
{
    return [self alignParentLeftWithMargin:0];
}
- (UIView *)alignParentBottom
{
    return [self alignParentBottomWithMargin:0];
}
- (UIView *)alignParentLeft
{
    return [self alignParentLeftWithMargin:0];
}
- (UIView *)alignParentRight
{
    return [self alignParentRightWithMargin:0];
}

- (UIView *)alignParentCenter
{
    return [self alignParentCenter:CGPointMake(0, 0)];
}

- (UIView *)alignParentCenter:(CGPoint)margin
{
    IsSuperViewInvalid(self);
    CGRect sbounds = self.superview.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(sbounds), CGRectGetMidY(sbounds));
    center.x += margin.x;
    center.y += margin.y;
    self.center = center;
    return self;
}


- (UIView *)alignParentTopWithMargin:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect rect = self.frame;
    rect.origin.y = self.superview.bounds.origin.y + margin;
    self.frame = rect;
    return self;
}
- (UIView *)alignParentBottomWithMargin:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect superBounds = self.superview.bounds;
    CGRect rect = self.frame;
    rect.origin.y = superBounds.origin.y + superBounds.size.height - margin - rect.size.height;
    self.frame = rect;
    return self;
}
- (UIView *)alignParentLeftWithMargin:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect rect = self.frame;
    rect.origin.x = self.superview.bounds.origin.x + margin;;
    self.frame = rect;
    return self;
}
- (UIView *)alignParentRightWithMargin:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect superBounds = self.superview.bounds;
    CGRect rect = self.frame;
    rect.origin.x = superBounds.origin.x + superBounds.size.width - margin - rect.size.width;
    self.frame = rect;
    return self;
}



// 与父控件的边距
// 只影响其坐标位置，不影响其大小
- (UIView *)marginParetnTop:(CGFloat)top bottom:(CGFloat)bottom left:(CGFloat)left rigth:(CGFloat)right
{
    IsSuperViewInvalid(self);
    CGRect superBounds = self.superview.bounds;
    CGRect rect = CGRectZero;
    rect.origin.y = top;
    rect.size.height = superBounds.origin.y + superBounds.size.height - rect.origin.y - bottom;

    rect.origin.x = left;
    rect.size.width = superBounds.origin.x + superBounds.size.width - rect.origin.x - right;
    
    self.frame = rect;
    return self;
}

- (UIView *)marginParentWithEdgeInsets:(UIEdgeInsets)inset
{
    return [self marginParetnTop:inset.top bottom:inset.bottom left:inset.left rigth:inset.right];
}

- (UIView *)marginParetn:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    self.frame = CGRectInset(self.superview.bounds, margin, margin);
    return self;
}
- (UIView *)marginParetnHorizontal:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect supRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.origin.x = supRect.origin.x + margin;
    rect.size.width = supRect.size.width - 2 * margin;
    self.frame = rect;
    return self;
}
- (UIView *)marginParetnVertical:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect supRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.origin.y = supRect.origin.y + margin;
    rect.size.height = supRect.size.height - 2 * margin;
    self.frame = rect;
    return self;
}

- (UIView *)marginParentTop:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect supRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.origin.y = supRect.origin.y + margin;
    self.frame = rect;
    return self;
}
- (UIView *)marginParentBottom:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect supRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.size.height = supRect.origin.y + supRect.size.height - margin - rect.origin.y;
    self.frame = rect;
    return self;
}
- (UIView *)marginParentLeft:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect supRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.origin.x = supRect.origin.x + margin;
    self.frame = rect;
    return self;
}
- (UIView *)marginParentRight:(CGFloat)margin
{
    IsSuperViewInvalid(self);
    CGRect supRect = self.superview.bounds;
    CGRect rect = self.frame;
    rect.size.width = supRect.origin.x + supRect.size.width - margin - rect.origin.x;
    self.frame = rect;
    return self;
}


// 控件在父控控件中的位置
// 水平居中
// 只影响其坐标位置，不影响其大小
- (UIView *)layoutParentHorizontalCenter
{
    IsSuperViewInvalid(self);
    CGPoint center = CGPointZero;
    CGRect srect = self.superview.bounds;
    center.x = CGRectGetMidX(srect);;
    center.y = self.center.y;
    self.center = center;
    return self;
}
// 垂直居中
- (UIView *)layoutParentVerticalCenter
{
    IsSuperViewInvalid(self);
    CGPoint center = CGPointZero;
    center.x = self.center.x;

    CGRect srect = self.superview.bounds;
    
    center.y = CGRectGetMidY(srect);
    self.center = center;
    return self;
}
// 居中
- (UIView *)layoutParentCenter
{
    IsSuperViewInvalid(self);
    CGRect rect = self.superview.bounds;
    
    self.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    return self;
}


// 与其他控件的大小关系
// 影响其大小
- (UIView *)widthEqualTo:(UIView *)brotherView
{
    IsArgInvalid(self, brotherView);
    CGRect brect = brotherView.frame;
    CGRect srect = self.frame;
    srect.size.width = brect.size.width;
    self.frame = srect;
    return self;
}
- (UIView *)heigthEqualTo:(UIView *)brotherView
{
    IsArgInvalid(self, brotherView);
    CGRect brect = brotherView.frame;
    CGRect srect = self.frame;
    srect.size.height = brect.size.height;
    self.frame = srect;
    return self;
}
- (UIView *)sizeEqualTo:(UIView *)brotherView
{
    IsArgInvalid(self, brotherView);
    CGRect brect = brotherView.frame;
    CGRect srect = self.frame;
    srect.size = brect.size;
    self.frame = srect;
    return self;
}

- (UIView *)sizeWith:(CGSize)size
{
    CGRect rect = CGRectZero;
    rect.size = size;
    self.frame = rect;
    return self;
}

- (UIView *)shrink:(CGSize)size
{
    CGRect rect = self.frame;
    self.frame = CGRectInset(rect, size.width, size.height);
    return self;
}
- (UIView *)shrinkHorizontal:(CGFloat)margin
{
    CGRect rect = self.frame;
    self.frame = CGRectInset(rect, margin, 0);
    return self;
}
- (UIView *)shrinkVertical:(CGFloat)margin
{
    CGRect rect = self.frame;
    self.frame = CGRectInset(rect, 0, margin);
    return self;
}

// views里面的View都是按UI的指定顺序放好的
- (UIView *)alignViews:(NSArray *)array isSubView:(BOOL)isSub padding:(CGFloat)padding margin:(CGFloat)margin horizontal:(BOOL)ishorizontal inRect:(CGRect)rect
{
    BOOL isSameParent = YES;
    if (!isSub)
    {
        for (UIView *view in array)
        {
            isSameParent = isSameParent && (view.superview == self);
            if (!isSameParent)
            {
                //DebugLog(@"所排列的View的父控件不同");
                return self;
                break;
            }
        }
    }
    
    if (ishorizontal)
    {
        CGRect marginRect = CGRectInset(rect, margin, 0);
        
        NSInteger count = array.count;
        
        const CGFloat kWidth = (marginRect.size.width - (count - 1)*padding)/count;
        CGFloat startX = marginRect.origin.x;
        for (UIView *view in array)
        {
            CGRect rect = view.frame;
            rect.origin.y = marginRect.origin.y;
            rect.size.height = marginRect.size.height;
            rect.origin.x = startX;
            rect.size.width = kWidth;
            view.frame = rect;
            startX += padding + kWidth;
        }
    }
    else
    {
        CGRect marginRect = CGRectInset(rect, 0, margin);
        
        NSInteger count = array.count;
        
        const CGFloat kHeight = (marginRect.size.width - (count - 1)*padding)/count;
        CGFloat startY = marginRect.origin.y;
        for (UIView *view in array)
        {
            CGRect viewrect = view.frame;
            rect.origin.x = marginRect.origin.x;
            rect.size.width = marginRect.size.width;
            viewrect.origin.y = startY;
            viewrect.size.height = kHeight;
            view.frame = viewrect;
            startY += padding + kHeight;
        }
    }
    
    
    return self;
}
- (UIView *)alignSubviewsHorizontallyWithPadding:(CGFloat)padding margin:(CGFloat)margin
{
    return [self alignViews:self.subviews isSubView:YES padding:padding margin:margin horizontal:YES inRect:self.bounds];
}

- (UIView *)alignSubviewsVerticallyWithPadding:(CGFloat)padding margin:(CGFloat)margin;
{
    return[self alignViews:self.subviews isSubView:YES padding:padding margin:margin horizontal:NO inRect:self.bounds];
}

- (UIView *)alignSubviews:(NSArray *)views horizontallyWithPadding:(CGFloat)padding margin:(CGFloat)margin inRect:(CGRect)rect
{
    return [self alignViews:views isSubView:NO padding:padding margin:margin horizontal:YES inRect:rect];
}

- (UIView *)alignSubviews:(NSArray *)views verticallyWithPadding:(CGFloat)padding margin:(CGFloat)margin inRect:(CGRect)rect
{
    return [self alignViews:views isSubView:NO padding:padding margin:margin horizontal:NO inRect:rect];
}



- (UIView *)gridViews:(NSArray *)views inColumn:(NSInteger)column size:(CGSize)cellSize margin:(CGSize)margin inRect:(CGRect)rect
{
    CGSize menuSize = cellSize;
    
    const NSInteger kColumn = column;
    const NSInteger kCount = views.count;
    const NSInteger kRow = kCount % kColumn == 0 ? kCount / kColumn : kCount / kColumn + 1;
    
    const CGSize kSpaceSize = margin;
    
    CGRect menuCellRect = rect;
    menuCellRect.size = menuSize;
    
    for (NSInteger i = 0; i < kRow; i++)
    {
        for (NSInteger j = 0; j < kColumn; j++)
        {
            NSInteger index = i * kColumn + j;
            if (index >= kCount)
            {
                return self;
            }
            
            UIView *view = [views objectAtIndex:index];
            view.frame = menuCellRect;
            menuCellRect.origin.x += menuCellRect.size.width + kSpaceSize.width;
        }
        
        menuCellRect.origin.x = rect.origin.x;
        menuCellRect.origin.y += menuCellRect.size.height + kSpaceSize.height;
    }
    
    return self;
}



@end
