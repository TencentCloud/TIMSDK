//
//  TUIFitButton.m
//  TUICore
//
//  Created by wyl on 2022/5/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFitButton.h"

@implementation TUIFitButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    if (!CGRectEqualToRect(self.titleRect, CGRectZero)) {
        return self.titleRect;
    } else if (!CGSizeEqualToSize(self.titleSize, CGSizeZero)) {
        CGRect oldrect = [super titleRectForContentRect:contentRect];
        CGRect newrect = CGRectZero;
        newrect.origin.x = oldrect.origin.x + (oldrect.size.width - self.titleSize.width) / 2;
        newrect.origin.y = oldrect.origin.y + (oldrect.size.height - self.titleSize.height) / 2;
        newrect.size.width = self.titleSize.width;
        newrect.size.height = self.titleSize.height;

        return newrect;
    }
    return [super titleRectForContentRect:contentRect];
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    if (!CGRectEqualToRect(self.imageRect, CGRectZero)) {
        return self.imageRect;
    } else if (!CGSizeEqualToSize(self.imageSize, CGSizeZero)) {
        CGRect oldrect = [super imageRectForContentRect:contentRect];
        CGRect newrect = CGRectZero;
        newrect.origin.x = oldrect.origin.x + (oldrect.size.width - self.imageSize.width) / 2;
        newrect.origin.y = oldrect.origin.y + (oldrect.size.height - self.imageSize.height) / 2;
        newrect.size.width = self.imageSize.width;
        newrect.size.height = self.imageSize.height;

        return newrect;
    }
    return [super imageRectForContentRect:contentRect];
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    [self setImage:normalImage forState:UIControlStateNormal];
}
@end

@implementation TUIBlockButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonTap:(id)button {
    if (self.clickCallBack) {
        self.clickCallBack(self);
    }
}
- (void)dealloc {
}
@end
