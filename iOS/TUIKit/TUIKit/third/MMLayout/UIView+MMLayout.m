

#import "UIView+MMLayout.h"
#import <objc/runtime.h>

#pragma mark - MMLayout
@interface MMLayout : NSObject
/*
 @LayoutView   传入进去  View
 */
-(instancetype)initWithLayoutView:(UIView *)LayoutView;
@property (assign , nonatomic) CGFloat top;    ///<<  frame y
@property (assign , nonatomic) CGFloat bottom; ///<<  y = super.h - LayoutView.h - bottom
@property (assign , nonatomic) CGFloat left;   ///<<  frame x
@property (assign , nonatomic) CGFloat right;  ///<<  x = super.w - LayoutView.h - right
@property (assign , nonatomic) CGFloat width;  ///<<  frame w
@property (assign , nonatomic) CGFloat height; ///<<  frame height
@property (assign , nonatomic) CGSize  size;   ///<<  frame bounds size  width height
@property (assign , nonatomic) CGPoint point;  ///<<  frame point
- (void)center; ///<<调用此方法前必须先设置自己的宽高   (默认是居中父控件)
- (void)centerX; ///<<调用此方法前必须先设置自己的宽   (默认是居中父控件)
- (void)centerY; ///<<调用此方法前必须先设置自己的高   (默认是居中父控件)
@property (weak   , nonatomic) UIView *layoutView;
@end
@implementation MMLayout
-(instancetype)initWithLayoutView:(UIView *)LayoutView{
    if (self=[super init]) {
        self.layoutView = LayoutView;
    }
    return self;
}
-(void)setLeft:(CGFloat)left{
    CGRect frame = self.layoutView.frame;
    frame.origin.x = left;
    self.layoutView.frame = frame;
}
- (CGFloat)left {
    return self.layoutView.frame.origin.x;
}
-(void)setTop:(CGFloat)top{
    _top = top;
    CGRect frame = self.layoutView.frame;
    frame.origin.y = top;
    self.layoutView.frame = frame;
}
-(void)setRight:(CGFloat)right{
    UIView *superview = self.layoutView.superview;
    self.layoutView.mm_x = superview.mm_w - self.layoutView.mm_w - right;
}
- (CGFloat)right {
    UIView *superview = self.layoutView.superview;
    return superview.mm_w - self.layoutView.mm_x - self.layoutView.mm_w;
}

-(void)setBottom:(CGFloat)bottom{
    UIView *superview = self.layoutView.superview;
    self.layoutView.mm_y =  superview.mm_h - self.layoutView.mm_h - bottom;
}

- (CGFloat)bottom {
    UIView *superview = self.layoutView.superview;
    return superview.mm_h - self.layoutView.mm_maxY;
}

-(void)setHeight:(CGFloat)height{
    _height = height;
    CGRect frame = self.layoutView.frame;
    frame.size.height = height;
    self.layoutView.frame = frame;
}
-(void)setWidth:(CGFloat)width{
    _width = width;
    CGRect frame = self.layoutView.frame;
    frame.size.width = width;
    self.layoutView.frame = frame;
}
-(void)setPoint:(CGPoint)point{
    CGRect frame = self.layoutView.frame;
    frame.origin = point;
    self.layoutView.frame = frame;
}
-(CGPoint)point{
    return CGPointMake(self.layoutView.mm_x, self.layoutView.mm_w);
}
-(void)setSize:(CGSize )size{
    CGRect frame = self.layoutView.frame;
    frame.size = size;
    self.layoutView.frame = frame;
}
-(CGSize)size{
    return self.layoutView.mm_size;
}

-(void)center{
    UIView *superview = self.layoutView.superview;
    self.layoutView.mm_x = superview.mm_halfW - self.layoutView.mm_halfW;
    self.layoutView.mm_y = superview.mm_halfH - self.layoutView.mm_halfH;
}
-(void)centerY{
    UIView *superview = self.layoutView.superview;
    self.layoutView.mm_y = superview.mm_halfH - self.layoutView.mm_halfH;
}
-(void)centerX{
    UIView *superview = self.layoutView.superview;
    self.layoutView.mm_x = superview.mm_halfW - self.layoutView.mm_halfW;
}
@end
const void *_layoutKey;
@implementation UIView (Layout)
#pragma mark - frame
- (void)setMm_x:(CGFloat)mm_x{
   [self mm_selfLayout].left = mm_x;
}
- (CGFloat)mm_x{
    return self.frame.origin.x;
}
- (void)setMm_y:(CGFloat)mm_y{
    [self mm_selfLayout].top = mm_y;
}
- (CGFloat)mm_y{
    return self.frame.origin.y;
}
- (void)setMm_w:(CGFloat)mm_w{
    [self mm_selfLayout].width = mm_w;
}
- (CGFloat)mm_w{
    return self.frame.size.width;
}
- (void)setMm_h:(CGFloat)mm_h{
    [self mm_selfLayout].height = mm_h;
}
- (CGFloat)mm_h{
    return self.frame.size.height;
}
-(void)setMm_center:(CGPoint)mm_center{
    [self mm_selfLayout].point = mm_center;
    
}
-(CGPoint)mm_center{
    return self.frame.origin;
}
-(CGFloat)mm_centerX{
    return self.center.x;
}
-(CGFloat)mm_centerY{
    return self.center.y;
}
- (CGFloat)mm_maxY{
    return CGRectGetMaxY(self.frame);
}
- (CGFloat)mm_minY{
    return CGRectGetMinY(self.frame);
}
- (CGFloat)mm_maxX{
    return CGRectGetMaxX(self.frame);
}
- (CGFloat)mm_minX{
    return CGRectGetMinX(self.frame);
}
- (CGFloat)mm_halfW{
    return self.mm_w / 2;
}
- (CGFloat)mm_halfH{
    return self.mm_h / 2;
}
- (CGFloat)mm_halfX{
    return self.mm_x / 2;
}
- (CGFloat)mm_halfY{
    return self.mm_y / 2;
}
-(CGFloat)mm_halfCenterX{
    return self.mm_centerX / 2;
}
-(CGFloat)mm_halfCenterY{
    return self.mm_centerY / 2;
}
-(void)setMm_size:(CGSize)mm_size{
    [self mm_selfLayout].size = mm_size;
}
-(CGSize)mm_size{
    return self.bounds.size;
}
#pragma mark - set_ frame
- (MMLayout *)mm_selfLayout{
    MMLayout *layout = objc_getAssociatedObject(self, &_layoutKey);
    if (layout == nil) {
        layout = [[MMLayout alloc] initWithLayoutView:self];
        objc_setAssociatedObject(self, &_layoutKey, layout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return layout;
}
-(UIView *(^)(CGFloat))m_top{
    @m_weakify(self);
    return ^(CGFloat m_top){
        @m_strongify(self);
        [self mm_selfLayout].top = m_top;
        return self;
    };
}
-(UIView *(^)(CGFloat))m_flexToTop{
    @m_weakify(self);
    return ^(CGFloat m_flexToTop){
        @m_strongify(self);
        CGFloat top = [self mm_selfLayout].top;
        [self mm_selfLayout].top = m_flexToTop;
        [self mm_selfLayout].height += top-m_flexToTop;
        return self;
    };
}
-(UIView *(^)(CGFloat))m_bottom{
    @m_weakify(self);
    return ^(CGFloat m_bottom){
        @m_strongify(self);
        [self mm_selfLayout].bottom = m_bottom;
        return self;
    };
}
-(UIView *(^)(CGFloat))m_flexToBottom{
    @m_weakify(self);
    return ^(CGFloat m_flexToBottom){
        @m_strongify(self);
        CGFloat bottom = [self mm_selfLayout].bottom;
        [self mm_selfLayout].height += bottom-m_flexToBottom;
        return self;
    };
}
-(UIView *(^)(CGFloat))m_left{
    @m_weakify(self);
    return ^(CGFloat m_left){
        @m_strongify(self);
        [self mm_selfLayout].left = m_left;
        return self;
    };
}
-(UIView *(^)(CGFloat))m_flexToLeft{
    @m_weakify(self);
    return ^(CGFloat m_flexToLeft){
        @m_strongify(self);
        CGFloat left = [self mm_selfLayout].left;
        [self mm_selfLayout].left = m_flexToLeft;
        [self mm_selfLayout].width += left-m_flexToLeft;
        return self;
    };
}
-(UIView *(^)(CGFloat))m_right{
    @m_weakify(self);
    return ^(CGFloat m_right){
        @m_strongify(self);
        [self mm_selfLayout].right = m_right;
        return self;
    };
}
-(UIView *(^)(CGFloat))m_flexToRight{
    @m_weakify(self);
    return ^(CGFloat m_flexToRight){
        @m_strongify(self);
        CGFloat right = [self mm_selfLayout].right;
        [self mm_selfLayout].width += right-m_flexToRight;
        return self;
    };
}
-(UIView *(^)(CGFloat))m_width{
    @m_weakify(self);
    return ^(CGFloat m_width){
        @m_strongify(self);
        [self mm_selfLayout].width = m_width;
        return self;
    };
}
-(UIView *(^)(CGFloat))m_height{
    @m_weakify(self);
    return ^(CGFloat m_height){
        @m_strongify(self);
        [self mm_selfLayout].height = m_height;
        return self;
    };
}
-(UIView *(^)(CGSize))m_size{
    @m_weakify(self);
    return ^(CGSize m_size){
        @m_strongify(self);
        [self mm_selfLayout].size = m_size;
        return self;
    };
}
- (UIView *(^)(CGPoint))m__center{
    @m_weakify(self);
    return ^(CGPoint m__center){
        @m_strongify(self);
        [self mm_selfLayout].point = m__center;
        return self;
    };

}
-(UIView *(^)())m_center{
    @m_weakify(self);
    return ^{
        @m_strongify(self);
        [[self mm_selfLayout] center];
        return self;
    };
}

-(UIView *(^)())m_centerY{
    @m_weakify(self);
    return ^{
        @m_strongify(self);
        [[self mm_selfLayout] centerY];
        return self;
    };
}

-(UIView *(^)())m_centerX{
    @m_weakify(self);
    return ^{
        @m_strongify(self);
        [[self mm_selfLayout] centerX];
        return self;
    };
}

#pragma mark -  m_equalTo
-(UIView *(^)(UIView *))m_equalToFrame{
    @m_weakify(self);
    return ^(UIView *obj){
        @m_strongify(self);
        self.frame = obj.frame;
        return self;
    };
}
-(UIView *(^)(UIView *))m_equalToTop{
    @m_weakify(self);
    return ^(UIView *obj){
        @m_strongify(self);
        self.mm_selfLayout.top = obj.mm_selfLayout.top;
        return self;
    };
    
}
-(UIView *(^)(UIView *))m_equalToBottom{
    @m_weakify(self);
    return ^(UIView *obj){
        @m_strongify(self);
        self.mm_selfLayout.bottom = obj.mm_selfLayout.bottom;
        return self;
    };
}
-(UIView *(^)(UIView *))m_equalToLeft{
    @m_weakify(self);
    return ^(UIView *obj){
        @m_strongify(self);
        self.mm_selfLayout.left = obj.mm_selfLayout.left;
        return self;
    };
    
}
-(UIView *(^)(UIView *))m_equalToRight{
    @m_weakify(self);
    return ^(UIView *obj){
        @m_strongify(self);
        self.mm_selfLayout.right = obj.mm_selfLayout.right;
        return self;
    };
    
}
-(UIView *(^)(UIView *))m_equalToWidth{
    @m_weakify(self);
    return ^(UIView *obj){
        @m_strongify(self);
        self.mm_selfLayout.width = obj.mm_selfLayout.width;
        return self;
    };
}
-(UIView *(^)(UIView *))m_equalToHeight{
    @m_weakify(self);
    return ^(UIView *obj){
        @m_strongify(self);
        self.mm_selfLayout.height = obj.mm_selfLayout.height;
        return self;
    };
}
-(UIView *(^)(UIView *))m_equalToSize{
    @m_weakify(self);
    return ^(UIView *obj){
        @m_strongify(self);
        [self mm_selfLayout].size = obj.mm_selfLayout.size;
        return self;
    };
}
- (UIView *(^)(UIView *))m_equalToCenter{
    @m_weakify(self);
    return ^(UIView *obj){
        @m_strongify(self);
        [self mm_selfLayout].point = obj.mm_selfLayout.point;
        return self;
    };
}


- (NSData *)mm_createPDF{
    CGRect bounds = self.bounds;
    NSMutableData *data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

- (UIViewController *)viewController {
    UIView *view = self;
    while (view) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
        view = view.superview;
      }
    return nil;
}



@end



