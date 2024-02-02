//
//  TUIEvaluationCell_Minimalist.m
//  TUIChat
//
//  Created by xia on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIEvaluationCell_Minimalist.h"
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIEvaluationCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColor = TUIChatDynamicColor(@"chat_text_message_receive_text_color", @"#000000");
        [self.container addSubview:_titleLabel];

        for (int i = 0; i < 5; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImage:TUIChatBundleThemeImage(@"chat_custom_evaluation_message_img", @"message_custom_evaluation")];
            [self.container addSubview:imageView];
            [self.starImageArray addObject:imageView];
        }

        _commentLabel = [[UILabel alloc] init];
        _commentLabel.font = [UIFont systemFontOfSize:15];
        _commentLabel.numberOfLines = 0;
        _commentLabel.textColor = TUIChatDynamicColor(@"chat_custom_evaluation_message_desc_color", @"#000000");
        [self.container addSubview:_commentLabel];
    }
    return self;
}

- (void)fillWithData:(TUIEvaluationCellData *)data {
    [super fillWithData:data];

    self.titleLabel.text = data.desc;
    self.commentLabel.text = data.comment;

    // Configure all StarViews to avoid UI cache clutter
    for (int i = 0; i < self.starImageArray.count; i++) {
        UIImageView *starView = [self.starImageArray objectAtIndex:i];
        starView.hidden = (i >= data.score);
    }
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.leading.mas_equalTo(10);
        make.width.mas_equalTo(225);
        make.height.mas_equalTo(18);
    }];
    
    UIImageView *leftView = nil;
    for (UIImageView *starView in self.starImageArray) {
        if (leftView == nil) {
            [starView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(10);
                make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(6);
                make.width.mas_equalTo(30);
                make.height.mas_equalTo(30);
            }];
        } else {
            [starView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(leftView.mas_trailing);
                make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(6);
                make.width.mas_equalTo(30);
                make.height.mas_equalTo(30);
            }];
        }
        leftView = starView;
    }
    
    UIImageView *starView = self.starImageArray.firstObject;

    self.commentLabel.hidden = self.commentLabel.text.length == 0;
    if (self.commentLabel.text.length > 0) {
        CGRect rect = [self.commentLabel.text boundingRectWithSize:CGSizeMake(225, MAXFLOAT)
                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                        attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}
                                                           context:nil];
        CGSize size = CGSizeMake(225, ceilf(rect.size.height));
        [self.commentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(starView.mas_bottom).mas_offset(6);
            make.leading.mas_equalTo(10);
            make.width.mas_equalTo(size.width);
            make.height.mas_equalTo(size.height);
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (NSMutableArray *)starImageArray {
    if (!_starImageArray) {
        _starImageArray = [[NSMutableArray alloc] init];
    }
    return _starImageArray;
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIEvaluationCellData.class], @"data must be kind of TUIEvaluationCellData");
    TUIEvaluationCellData *evaluationCellData = (TUIEvaluationCellData *)data;
    
    CGRect rect = [evaluationCellData.comment boundingRectWithSize:CGSizeMake(215, MAXFLOAT)
                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                        attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}
                                                           context:nil];
    CGSize size = CGSizeMake(245, ceilf(rect.size.height));
    size.height += evaluationCellData.comment.length > 0 ? 88 : 50;
    return size;
}

@end
