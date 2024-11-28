// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaLabelCell.h"
#import <Masonry/Masonry.h>

@interface TUIMultimediaLabelCell () {
    UILabel *_label;
}
@end

@implementation TUIMultimediaLabelCell
@dynamic attributedText;

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _label = [[UILabel alloc] init];
        [self.contentView addSubview:_label];
        _label.textAlignment = NSTextAlignmentCenter;
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
          make.edges.equalTo(self);
        }];
    }
    return self;
}

- (NSAttributedString *)attrText {
    return _label.attributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _label.attributedText = attributedText;
}
@end
