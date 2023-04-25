//
//  TUITagsCell.m
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//
#import "TUITagsCell.h"
#import "TUITagsModel.h"
#import <TIMCommon/TIMCommonModel.h>
#import "TUIAttributedLabel.h"

#define margin 8
#define rightMargin 8
#define maxItemWidth 107
@interface TUITagsCell()<TUIAttributedLabelDelegate>

@property (nonatomic, strong) UIButton *tagBtn;

@end

@implementation TUITagsCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self prepareUI];
    }
    return self;
}


#pragma mark - UI
- (void)prepareUI {
    self.layer.cornerRadius = 12.0f;
    self.layer.masksToBounds = YES;
}


#pragma mark - Data
- (void)setModel:(TUITagsModel *)model {
    _model = model;
    self.backgroundColor = model.defaultColor;
    
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    NSString *text = [model descriptionFollowUserStr];
    
    CGFloat allWidth = 0;
    
    UIButton *emojiBtn = [[UIButton alloc] init];
    [emojiBtn addTarget:self action:@selector(emojiBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:emojiBtn];
    [emojiBtn setImage:[[TUIImageCache sharedInstance] getFaceFromCache:model.emojiPath] forState:UIControlStateNormal];
    emojiBtn.frame = CGRectMake(margin, 4, 18, 18);
    allWidth+= (emojiBtn.frame.size.width );
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(emojiBtn.frame.origin.x + emojiBtn.frame.size.width +4 , (30 -14)*0.5, 1, 14)];
    line.backgroundColor =  [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:0.2];
    [self addSubview:line];
    allWidth+= line.frame.size.width;

    
    TUIAttributedLabel *label = [[TUIAttributedLabel alloc] initWithFrame:CGRectMake(line.frame.origin.x + 4,8, self.frame.size.width, 30)];
    [self addSubview:label];
    
    NSString * contentString = text;
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:11];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
    [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[contentString rangeOfString:contentString]];
    [mutableAttributedString addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:11]
                     range:[contentString rangeOfString:contentString]];
    [mutableAttributedString addAttribute:NSStrokeWidthAttributeName value:@0 range:[contentString rangeOfString:contentString]];
    [label setText:mutableAttributedString];
    
    [label sizeToFit];
    label.textColor = model.textColor;

    CGFloat fitWidth = label.frame.size.width;
    
    if (fitWidth > (MaxTagSize - allWidth - 12 - 12  - 100)) {
        fitWidth = MaxTagSize - allWidth - 12 - 12  - 100;
    }
//    label.textInsets =  UIEdgeInsetsMake(0, 0, 0, 0);
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, fitWidth, label.frame.size.height);
    label.preferredMaxLayoutWidth = 10;
    //self.contentView.frame.size.width - 28 -16 -1
    label.font = [UIFont systemFontOfSize:11];
    label.numberOfLines = 1;
    label.delegate = (id)self;
    
    
    allWidth+= label.frame.size.width;
    allWidth+= margin;
    allWidth+= rightMargin;
    allWidth+= 8;
    self.ItemWidth = allWidth;
}

- (void)emojiBtnClick {
    if (self.emojiClickCallback) {
        self.emojiClickCallback(self.model);
    }
}

- (void)tagBtnclick:(UIButton *)btn {
    if (self.userClickCallback) {
        self.userClickCallback(self.model,btn.tag);
    }
}

@end
