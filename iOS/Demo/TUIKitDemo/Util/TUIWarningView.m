//
//  TUIWarningView.m
//
//  Created by summeryxia on 2022/7/19.
//

#import "TUIWarningView.h"
#import "TUIDefine.h"

@interface TUIWarningView()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *tipsButton;
@property (nonatomic, copy) void(^buttonAction)(void);

@end

@implementation TUIWarningView

- (instancetype)initWithFrame:(CGRect)frame
                         tips:(NSString *)tips
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(void(^)(void))action {
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonAction = action;
        self.backgroundColor = [UIColor tui_colorWithHex:@"fdf4e7" alpha:1];

        if (tips.length > 0) {
            self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [self addSubview:self.tipsLabel];
            self.tipsLabel.font = [UIFont systemFontOfSize:12];
            self.tipsLabel.numberOfLines = 0;
            self.tipsLabel.textColor = [UIColor tui_colorWithHex:@"FF8C39"];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.minimumLineHeight = 18;
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [paragraphStyle setAlignment:NSTextAlignmentLeft];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tips];
            [attributedString addAttribute:NSParagraphStyleAttributeName
                                     value:paragraphStyle
                                     range:NSMakeRange(0, [tips length])];
            self.tipsLabel.attributedText = attributedString;
            CGRect rect = [self.tipsLabel.text boundingRectWithSize:CGSizeMake(self.mm_w - 32, MAXFLOAT)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                         attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                                       NSParagraphStyleAttributeName : paragraphStyle
                                                                    }
                                                            context:nil];
            self.mm_height(rect.size.height + 32);
            self.tipsLabel
                .mm_width(rect.size.width)
                .mm_height(rect.size.height)
                .mm_top(16)
                .mm_left(16);
        }

        if (buttonTitle.length > 0) {
            self.tipsButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [self addSubview:self.tipsButton];
            [self.tipsButton setTitle:buttonTitle forState:UIControlStateNormal];
            [self.tipsButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [self.tipsButton setTitleColor:[UIColor tui_colorWithHex:@"006EFF"] forState:UIControlStateNormal];
            [self.tipsButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.tipsButton.mm_sizeToFit().mm_right(16).mm_bottom(10);
        }

    }
    return self;
}

- (void)onButtonClicked:(UIButton *)sender {
    if (self.buttonAction) {
        self.buttonAction();
    }
}

@end
