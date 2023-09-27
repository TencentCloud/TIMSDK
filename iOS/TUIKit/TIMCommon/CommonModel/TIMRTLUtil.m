//
//  TIMRTLUtil.m
//  TIMCommon
//
//  Created by cologne on 2023/7/21.
//  Copyright © 2023 Tencent. All rights reserved
//

#import "TIMRTLUtil.h"
#import <objc/runtime.h>
#import <TUICore/TUIGlobalization.h>

@implementation TIMRTLUtil

@end


@interface UIView (TUIRTL)

@end
@implementation UIView (TUIRTL)
- (void)setRTLFrame:(CGRect)frame width:(CGFloat)width {
    if (isRTL()) {
        if (self.superview == nil) {
            NSAssert(0, @"must invoke after have superView");
        }
        CGFloat x = width - frame.origin.x - frame.size.width;
        frame.origin.x = x;
    }
    self.frame = frame;
}

- (void)setRTLFrame:(CGRect)frame {
    [self setRTLFrame:frame width:self.superview.frame.size.width];
}

- (void)resetFrameToFitRTL {
    [self setRTLFrame:self.frame];
}

@end

@interface UIImage (TUIRTL)

@end
@implementation UIImage (TUIRTL)
- (UIImage *_Nonnull)checkOverturn{
    if (isRTL()) {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(bitmap, self.size.width / 2, self.size.height / 2);
        CGContextScaleCTM(bitmap, -1.0, -1.0);
        CGContextTranslateCTM(bitmap, -self.size.width / 2, -self.size.height / 2);
        CGContextDrawImage(bitmap, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        return image;
    }
    return self;
}
- (UIImage *)_imageFlippedForRightToLeftLayoutDirection {
    if (isRTL()) {
        return [UIImage imageWithCGImage:self.CGImage
                                   scale:self.scale
                             orientation:UIImageOrientationUpMirrored];
    }

    return self;
}

- (UIImage *)rtl_imageFlippedForRightToLeftLayoutDirection {
    if (isRTL()) {
        if (@available(iOS 13.0, *)) {
            UITraitCollection *const scaleTraitCollection = [UITraitCollection currentTraitCollection];
            UITraitCollection *const darkUnscaledTraitCollection = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];
            UITraitCollection *const darkScaledTraitCollection =
                [UITraitCollection traitCollectionWithTraitsFromCollections:@[ scaleTraitCollection, darkUnscaledTraitCollection ]];

            UIImage *lightImg = [[self.imageAsset imageWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]]
                _imageFlippedForRightToLeftLayoutDirection];

            UIImage *darkImage = [[self.imageAsset imageWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]]
                _imageFlippedForRightToLeftLayoutDirection];

            UIImage *image =
                [lightImg imageWithConfiguration:[self.configuration
                                                     configurationWithTraitCollection:[UITraitCollection
                                                                                          traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]]];
            [image.imageAsset registerImage:darkImage withTraitCollection:darkScaledTraitCollection];
            return image;
        } else {
            return [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:UIImageOrientationUpMirrored];
        }
    }
    return self;
}

@end
@interface UINavigationController (TUIRTL)
@end
@implementation UINavigationController (TUIRTL)
+ (void)load {
    Method oldMethod = class_getInstanceMethod(self, @selector(initWithRootViewController:));
    Method newMethod = class_getInstanceMethod(self, @selector(rtl_initWithRootViewController:));
    method_exchangeImplementations(oldMethod, newMethod);
}

- (instancetype)rtl_initWithRootViewController:(UIViewController *)rootViewController {
    if ([self rtl_initWithRootViewController:rootViewController]) {
        if (@available(iOS 9.0, *)) {
            if (isRTL()) {
                self.navigationBar.semanticContentAttribute = [UIView appearance].semanticContentAttribute;
                self.view.semanticContentAttribute = [UIView appearance].semanticContentAttribute;
            }
        }
    }
    return self;
}
@end


UIEdgeInsets rtlEdgeInsetsWithInsets(UIEdgeInsets insets) {
    if (insets.left != insets.right && isRTL()) {
        CGFloat temp = insets.left;
        insets.left = insets.right;
        insets.right = temp;
    }
    return insets;
    
}

@implementation UIButton (TUIRTL)

void swizzleInstanceMethod(Class cls, SEL originSelector, SEL swizzleSelector){
    if (!cls) {
        return;
    }
    /* if current class not exist selector, then get super*/
    Method originalMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzleSelector);
    
    /* add selector if not exist, implement append with method */
    if (class_addMethod(cls,
                        originSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* replace class instance method, added if selector not exist */
        /* for class cluster , it always add new selector here */
        class_replaceMethod(cls,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(cls,
                            swizzleSelector,
                            class_replaceMethod(cls,
                                                originSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}
+ (void)load
{
    swizzleInstanceMethod(self, @selector(setContentEdgeInsets:), @selector(rtl_setContentEdgeInsets:));
    swizzleInstanceMethod(self, @selector(setImageEdgeInsets:), @selector(rtl_setImageEdgeInsets:));
    swizzleInstanceMethod(self, @selector(setTitleEdgeInsets:), @selector(rtl_setTitleEdgeInsets:));
}

- (void)rtl_setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    [self rtl_setContentEdgeInsets:rtlEdgeInsetsWithInsets(contentEdgeInsets)];
}

- (void)rtl_setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    [self rtl_setImageEdgeInsets:rtlEdgeInsetsWithInsets(imageEdgeInsets)];
}

- (void)rtl_setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    [self rtl_setTitleEdgeInsets:rtlEdgeInsetsWithInsets(titleEdgeInsets)];
}


@end


@implementation UILabel (TUIRTL)

- (void)setRtlAlignment:(TUITextRTLAlignment)rtlAlignment {
    objc_setAssociatedObject(self, @selector(rtlAlignment), @(rtlAlignment), OBJC_ASSOCIATION_ASSIGN);
    switch (rtlAlignment) {
        case TUITextRTLAlignmentLeading:
            self.textAlignment = (isRTL() ? NSTextAlignmentRight : NSTextAlignmentLeft);
            break;
        case TUITextRTLAlignmentTrailing:
            self.textAlignment = (isRTL() ? NSTextAlignmentLeft : NSTextAlignmentRight);
            break;
        case TUITextRTLAlignmentCenter:
            self.textAlignment = NSTextAlignmentCenter;
        case TUITextRTLAlignmentUndefine:
            break;
        default:
            break;
    }
}

- (TUITextRTLAlignment)rtlAlignment {
    NSNumber *identifier = objc_getAssociatedObject(self, @selector(rtlAlignment));
    if (identifier) {
        return identifier.integerValue;
    }
    return TUITextRTLAlignmentUndefine;
}
@end

@implementation NSMutableAttributedString (TUIRTL)
- (void)setRtlAlignment:(TUITextRTLAlignment)rtlAlignment {
    switch (rtlAlignment) {
        case TUITextRTLAlignmentLeading:
            self.rtlAlignment = (isRTL() ? NSTextAlignmentRight : NSTextAlignmentLeft);
            break;
        case TUITextRTLAlignmentTrailing:
            self.rtlAlignment = (isRTL() ? NSTextAlignmentLeft : NSTextAlignmentRight);
            break;
        case TUITextRTLAlignmentCenter:
            self.rtlAlignment = NSTextAlignmentCenter;
        case TUITextRTLAlignmentUndefine:
            break;
        default:
            break;
    }
}
@end

BOOL isRTLString(NSString *string) {
    if ([string hasPrefix:@"\u202B"] || [string hasPrefix:@"\u202A"]) {
        return YES;
    }
    return NO;
}

NSString * rtlString(NSString *string) {
    if (string.length == 0 || isRTLString(string)) {
        return string;
    }
    if (isRTL()) {
        string = [@"\u202B" stringByAppendingString:string];
    } else {
        string = [@"\u202A" stringByAppendingString:string];
    }
    return string;
}

NSAttributedString *rtlAttributeString(NSAttributedString *attributeString ,NSTextAlignment textAlignment ){
    if (attributeString.length == 0) {
        return attributeString;
    }
    NSRange range;
    NSDictionary *originAttributes = [attributeString attributesAtIndex:0 effectiveRange:&range];
    NSParagraphStyle *style = [originAttributes objectForKey:NSParagraphStyleAttributeName];

    if (style && isRTLString(attributeString.string)) {
        return attributeString;
    }

    NSMutableDictionary *attributes = originAttributes ? [originAttributes mutableCopy] : [NSMutableDictionary new];
    if (!style) {
        NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        UILabel *test = [UILabel new];
        test.textAlignment = textAlignment;
        mutableParagraphStyle.alignment = test.textAlignment;
        style = mutableParagraphStyle;
        [attributes setValue:mutableParagraphStyle forKey:NSParagraphStyleAttributeName];
    }
    NSString *string = rtlString(attributeString.string);
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

@implementation TUICollectionRTLFitFlowLayout
- (UIUserInterfaceLayoutDirection)effectiveUserInterfaceLayoutDirection {
    if (isRTL()) {
        return UIUserInterfaceLayoutDirectionRightToLeft;
    }
    return UIUserInterfaceLayoutDirectionLeftToRight;
}

- (BOOL)flipsHorizontallyInOppositeLayoutDirection{
    
    return isRTL()? YES:NO;
}
@end
