//
//  UIView+MM.h
/*
 杜蒙 iOS开发
 annidy
*/

#define m_weakify(object) autoreleasepool   {} __weak  typeof(object) weak##object = object;
#define m_strongify(object) autoreleasepool {} __strong  typeof(weak##object) object = weak##object;

#import <UIKit/UIKit.h>
@class MMLayout;
@interface UIView (Layout)
@property (strong , nonatomic ,  readonly) MMLayout *mm_selfLayout;
- (void)setMm_x:(CGFloat)mm_x; ///<< set frame.x
- (CGFloat)mm_x;            ///<< get frame.x
- (void)setMm_y:(CGFloat)mm_y; ///<< set frame.y
- (CGFloat)mm_y;            ///<< get frame.y
- (void)setMm_w:(CGFloat)mm_w; ///<< set frame.bounds.size.width
- (CGFloat)mm_w;            ///<< get frame.bounds.size.width
- (void)setMm_h:(CGFloat)mm_h; ///<< set frame.bounds.size.height
- (CGFloat)mm_h;            ///<< get frame.bounds.size.height
- (void)setMm_center:(CGPoint )mm_center; ///<< set frame.origin
- (CGPoint)mm_center;        ///<< get frame origin
- (CGFloat)mm_centerX;      ///<< get self.center.x
- (CGFloat)mm_centerY;      ///<< get self.center.y
- (CGFloat)mm_maxY;         ///<< get CGRectGetMaxY
- (CGFloat)mm_minY;         ///<< get CGRectGetMinY
- (CGFloat)mm_maxX;         ///<< get CGRectGetMaxX
- (CGFloat)mm_minX;         ///<< get CGRectGetMinX
- (CGFloat)mm_halfW;        ///<< get self.width / 2
- (CGFloat)mm_halfH;        ///<< get self.height / 2
- (CGFloat)mm_halfX;        ///<< get self.x / 2
- (CGFloat)mm_halfY;        ///<< get self.y / 2
- (CGFloat)mm_halfCenterX;  ///<< get self.centerX / 2
- (CGFloat)mm_halfCenterY;  ///<< get self.centerY / 2
- (void)setMm_size:(CGSize)mm_size;
- (CGSize)mm_size;       ///<< get self.bounds.size

/*
   示例链接编程
   self.width(100).height(100).left(10).top(10)
*/
- (UIView * (^)(CGFloat top))m_top;            ///< set frame y
- (UIView * (^)(CGFloat right))m_flexToTop; ///< set frame y by change height
- (UIView * (^)(CGFloat bottom))m_bottom;      ///< set frame y
- (UIView * (^)(CGFloat right))m_flexToBottom; ///< set frame y by change height
- (UIView * (^)(CGFloat left))m_left;          ///< set frame x
- (UIView * (^)(CGFloat right))m_flexToLeft;   ///< set frame right by chang width
- (UIView * (^)(CGFloat right))m_right;        ///< set frame x
- (UIView * (^)(CGFloat right))m_flexToRight;  ///< set frame right by chang width
- (UIView * (^)(CGFloat width))m_width;        ///< set frame width
- (UIView * (^)(CGFloat height))m_height;      ///< set frame height
- (UIView * (^)(CGSize  size))m_size;           ///< set frame size
- (UIView * (^)(CGPoint center))m__center;      ///< set frame point
- (UIView * (^)())m_center;                    ///< set frame center  前提是有w h 调用次方法居中父类
- (UIView * (^)())m_centerY;                    ///< set frame Ycenter  前提是有h调用次方法居中父类
- (UIView * (^)())m_centerX;                    ///< set frame Xcenter  前提是有w调用次方法居中父类


- (UIView * (^)(UIView *obj))m_equalToFrame;   ///  equalTo frame
- (UIView * (^)(UIView *obj))m_equalToTop;     ///  equalTo top
- (UIView * (^)(UIView *obj))m_equalToBottom;  ///  equalTo Bottom
- (UIView * (^)(UIView *obj))m_equalToLeft;    ///  equalTo left
- (UIView * (^)(UIView *obj))m_equalToRight;   ///  equalTo right
- (UIView * (^)(UIView *obj))m_equalToWidth;   ///  equalTo width
- (UIView * (^)(UIView *obj))m_equalToHeight;  ///  equalTo height
- (UIView * (^)(UIView *obj))m_equalToSize;    ///  equalTo size
- (UIView * (^)(UIView *obj))m_equalToCenter;  ///  equalTo center


- (NSData *)mm_createPDF;/// create self PDF

- (UIViewController *)viewController;  //self Responder UIViewControler  

@end




