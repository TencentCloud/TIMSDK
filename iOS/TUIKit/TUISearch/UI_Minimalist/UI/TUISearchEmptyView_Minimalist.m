//
//  TUISearchEmptyView_Minimalist.m
//  TUISearch
//
//  Created by wyl on 2022/12/19.
//

#import "TUISearchEmptyView_Minimalist.h"
#import "TUIDefine.h"

@implementation TUISearchEmptyView_Minimalist

- (instancetype)initWithImage:(UIImage *)img Text:(NSString *)text {
    self = [super init];
    if (self) {
        self.tipsLabel.text = text;
        self.midImage = [[UIImageView alloc] initWithImage:img];
        [self addSubview:self.tipsLabel];
        [self addSubview:self.midImage];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.midImage.frame = CGRectMake((self.bounds.size.width - kScale390(105)) *0.5, 0, kScale390(105), kScale390(105));
    [self.tipsLabel sizeToFit];
    self.tipsLabel.frame = CGRectMake((self.bounds.size.width - self.tipsLabel.frame.size.width) *0.5 ,
                                       self.midImage.frame.origin.y + self.midImage.frame.size.height + kScale390(10),
                                       self.tipsLabel.frame.size.width,
                                       self.tipsLabel.frame.size.height);

}

- (UILabel *)tipsLabel {
    if (_tipsLabel == nil) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = [UIColor tui_colorWithHex:@"#999999"];
        _tipsLabel.font = [UIFont systemFontOfSize:14.0];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLabel;
}


@end
