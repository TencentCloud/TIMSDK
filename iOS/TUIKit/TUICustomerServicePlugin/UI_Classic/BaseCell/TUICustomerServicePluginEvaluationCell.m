//
//  TUICustomerServicePluginEvaluationCell.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import "TUICustomerServicePluginEvaluationCell.h"
#import "TUICustomerServicePluginDataProvider.h"
#import "TUICustomerServicePluginDataProvider+CalculateSize.h"
#import <TUICore/TUICore.h>

@interface TUICustomerServicePluginEvaluationCell()

@property (nonatomic, strong) UIButton *selectedButton;

@end

@implementation TUICustomerServicePluginEvaluationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _backView = [UIView new];
        _backView.backgroundColor = TUICustomerServicePluginDynamicColor(@"customer_service_evaluation_bg_color", @"#FBFBFB");
        _backView.layer.cornerRadius = 10;
        _backView.layer.masksToBounds = YES;
        [self.container addSubview:_backView];
        
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = [UIFont systemFontOfSize:12];
        _topLabel.numberOfLines = 1;
        _topLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _topLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_evaluation_top_text_color", @"#9A9A9A");
        _topLabel.text = @"感谢您使用我们的服务，请对此次服务进行评价！";
        _topLabel.textAlignment = NSTextAlignmentCenter;
        [self.container addSubview:_topLabel];
        
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.font = [UIFont systemFontOfSize:12];
        _headerLabel.numberOfLines = 0;
        _headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _headerLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_evaluation_header_text_color", @"#1C1C1C");
        [self.backView addSubview:_headerLabel];

        _submitButton = [UIButton new];
        [_submitButton setTitle:TIMCommonLocalizableString(TUICustomerServiceSubmitEvaluation) forState:UIControlStateNormal];
        _submitButton.layer.cornerRadius = 4;
        _submitButton.layer.masksToBounds = YES;
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_submitButton setTitleColor:TUICustomerServicePluginDynamicColor(@"customer_service_evaluation_button_text_color", @"#FFFFFF")
                        forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(onSubmitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _submitButton.backgroundColor = TUICustomerServicePluginDynamicColor(@"customer_service_evaluation_button_bg_color", @"#2F80ED");
        [self.backView addSubview:_submitButton];
        
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.numberOfLines = 0;
        _bottomLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _bottomLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_evaluation_bottom_text_color", @"#9A9A9A");
        _bottomLabel.hidden = YES;
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        [self.container addSubview:_bottomLabel];
    }
    return self;
}

- (void)onSubmitButtonClicked:(UIButton *)sender {
    NSString *itemID = [NSString stringWithFormat:@"%ld", (long)self.selectedButton.tag];
    NSDictionary *dict = @{@"menuSelected": @{@"id": itemID,
                                              @"content": self.customData.itemDict[itemID] ? : @"",
                                              @"sessionId": self.customData.sessionID ? : @""},
                           @"src": BussinessID_Src_CustomerService_EvaluationSelected};
    NSData *data = [TUITool dictionary2JsonData:dict];
    [TUICustomerServicePluginDataProvider sendCustomMessageWithoutUpdateUI:data];
}

- (void)onScoreButtonClicked:(UIButton *)sender {
    if (self.customData.isExpired) {
        return;
    }
    self.selectedButton = sender;
    for (int i = 0; i < self.scoreButtonArray.count; i++) {
        UIButton *button = self.scoreButtonArray[i];
        if (button.tag <= sender.tag) {
            [self updateScoreButton:button index:i selected:YES];
        } else {
            [self updateScoreButton:button index:i selected:NO];
        }
    }
    // The submit button can only be clicked after selecting ⭐️
    self.submitButton.enabled = YES;
    self.submitButton.alpha = 1.0;
}

- (void)notifyCellSizeChanged {
    NSDictionary *param = @{TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey_Message : self.customData.innerMessage};
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey
                  object:nil
                   param:param];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIButton *button in self.scoreButtonArray) {
        [button removeFromSuperview];
    }
    [self.scoreButtonArray removeAllObjects];
}

- (void)fillWithData:(TUICustomerServicePluginEvaluationCellData *)data {
    [super fillWithData:data];
    BOOL isCellDataChanged = [self isCellDataChanged:self.customData newData:data];
    
    self.customData = data;
    self.headerLabel.text = data.header;
    self.bottomLabel.text = data.tail;

    if (data.isSelected) {
        for (int i = 0; i < data.totalScore; i++) {
            NSDictionary *item = data.items[i];
            UIButton *scoreButton = [[UIButton alloc] init];
            scoreButton.tag = [item[@"id"] integerValue];
            scoreButton.enabled = NO;
            scoreButton.alpha = 0.8;
            scoreButton.titleLabel.font = [UIFont systemFontOfSize:12];
            
            if (i <= data.score) {
                [self updateScoreButton:scoreButton index:i selected:YES];
            } else {
                [self updateScoreButton:scoreButton index:i selected:NO];
            }
            [self.backView addSubview:scoreButton];
            [self.scoreButtonArray addObject:scoreButton];
        }
        self.submitButton.enabled = NO;
        self.submitButton.alpha = 0.8;
        self.bottomLabel.hidden = NO;
        
        if (isCellDataChanged) {
            [self notifyCellSizeChanged];
        }
    } else {
        for (int i = 0; i < data.totalScore; i++) {
            NSDictionary *item = data.items[i];
            
            UIButton *scoreButton = [[UIButton alloc] init];
            [scoreButton addTarget:self
                            action:@selector(onScoreButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
            scoreButton.tag = [item[@"id"] integerValue];
            scoreButton.enabled = !self.customData.isExpired;
            scoreButton.alpha = 1.0;
            scoreButton.titleLabel.font = [UIFont systemFontOfSize:12];
            
            [self updateScoreButton:scoreButton index:i selected:NO];
            [self.backView addSubview:scoreButton];
            [self.scoreButtonArray addObject:scoreButton];
        }
        
        self.submitButton.enabled = NO;
        self.submitButton.alpha = 0.8;
        self.bottomLabel.hidden = YES;
    }
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)updateScoreButton:(UIButton *)button index:(int)i selected:(BOOL)selected {
    if (self.customData.type == 1) {
        // star
        if (selected) {
            [button setBackgroundImage:TUICustomerServicePluginBundleThemeImage(@"customer_service_evaluation_star_selected_img", @"star_selected") forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:TUICustomerServicePluginBundleThemeImage(@"customer_service_evaluation_star_unselected_img", @"star_unselected") forState:UIControlStateNormal];
        }
    } else if (self.customData.type == 2) {
        // number
        if (selected) {
            [button setBackgroundImage:TUICustomerServicePluginBundleThemeImage(@"customer_service_evaluation_number_selected_img", @"number_selected") forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
            [button setTitleColor:TUICustomerServicePluginDynamicColor(@"customer_service_evaluation_button_selected_bg_color", @"#FFFFFF") forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:TUICustomerServicePluginBundleThemeImage(@"customer_service_evaluation_number_unselected_img", @"number_unselected") forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
            [button setTitleColor:TUICustomerServicePluginDynamicColor(@"customer_service_evaluation_button_unselected_bg_color", @"#006EFF") forState:UIControlStateNormal];
        }
    }
}

// Override, the height of the cell
+ (CGFloat)getHeight:(TUICustomerServicePluginEvaluationCellData *)data withWidth:(CGFloat)width {
    return [self getContentSize:data].height;
}

// Override, the size of bubble content.
+ (CGSize)getContentSize:(TUICustomerServicePluginEvaluationCellData *)data {
    return [TUICustomerServicePluginDataProvider calcEvaluationCellSize:data.header
                                                                   tail:data.tail
                                                                  score:data.totalScore
                                                               selected:data.isSelected];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    self.container.mm_fill();
    
    [self.topLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(270);
        make.height.mas_equalTo(20);
    }];
    
    [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.topLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(TUICustomerServicePluginEvaluationBubbleWidth);
        make.height.mas_equalTo([TUICustomerServicePluginDataProvider calcEvaluationBubbleSize:self.customData.header
                                                                                         score:self.customData.totalScore].height);
    }];
    
    [self.headerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.backView);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo([TUICustomerServicePluginDataProvider calcEvaluationBubbleHeaderSize:self.customData.header].width);
        make.height.mas_equalTo([TUICustomerServicePluginDataProvider calcEvaluationBubbleHeaderSize:self.customData.header].height);
    }];

    UIImageView *leftView = nil;
    UIImageView *upView = nil;
    float leftMargin = (self.backView.mm_w - 24 * 5 - 15 * 4) / 2.0;
    for (int i = 0; i < self.scoreButtonArray.count; i++) {
        UIImageView *scoreView = self.scoreButtonArray[i];
        if (i < 5) {
            // First row.
            [scoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (leftView == nil) {
                    make.leading.mas_equalTo(leftMargin);
                } else {
                    make.leading.mas_equalTo(leftView.mas_trailing).offset(15);
                }
                make.top.mas_equalTo(self.headerLabel.mas_bottom).offset(12);
                make.width.mas_equalTo(24);
                make.height.mas_equalTo(24);
            }];
            leftView = scoreView;
            upView = scoreView;
        } else {
            // Second row if exist.
            if (i == 5) {
                leftView = nil;
            }
            [scoreView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (leftView == nil) {
                    make.leading.mas_equalTo(leftMargin);
                } else {
                    make.leading.mas_equalTo(leftView.mas_trailing).offset(15);
                }
                make.top.mas_equalTo(upView.mas_bottom).offset(12);
                make.width.mas_equalTo(24);
                make.height.mas_equalTo(24);
            }];
            leftView = scoreView;
        }
    }
    
    UIImageView *scoreView = self.scoreButtonArray.count <= 5 ? self.scoreButtonArray.firstObject : self.scoreButtonArray.lastObject;
    
    if (scoreView) {
        [self.submitButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.backView);
            make.top.mas_equalTo(scoreView.mas_bottom).offset(12);
            make.width.mas_equalTo(140);
            make.height.mas_equalTo(30);
        }];
    }

    if (self.customData.isSelected) {
        CGSize tailSize = [TUICustomerServicePluginDataProvider calcEvaluationBubbleTailSize:self.customData.tail];
        [self.bottomLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(self.backView.mas_bottom).offset(20);
            make.width.mas_equalTo(tailSize.width);
            make.height.mas_equalTo(tailSize.height);
        }];
    }
}

- (NSMutableArray *)scoreButtonArray {
    if (!_scoreButtonArray) {
        _scoreButtonArray = [[NSMutableArray alloc] init];
    }
    return _scoreButtonArray;
}

- (BOOL)isCellDataChanged:(TUICustomerServicePluginEvaluationCellData *)oldData 
                  newData:(TUICustomerServicePluginEvaluationCellData *)newData {
    if (oldData && newData && oldData.score == newData.score && oldData.isSelected == newData.isSelected) {
        return NO;
    }
    return YES;
}

@end
