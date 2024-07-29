//
//  TUIMergeMessageCell.m
//  Pods
//
//  Created by harvy on 2020/12/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMergeMessageCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/TUICore.h>

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@interface TUIMergeMessageDetailRow : UIView
@property(nonatomic, strong) UILabel *abstractName;
@property(nonatomic, strong) UILabel *abstractBreak;
@property(nonatomic, strong) UILabel *abstractDetail;
@property(nonatomic, assign) CGFloat abstractNameLimitedWidth;
- (void)fillWithData:(NSAttributedString *)name detailContent:(NSAttributedString *)detailContent;
@end
@implementation TUIMergeMessageDetailRow

- (instancetype)init {
    self = [super init];
    if(self){
        [self setupview];
    }
    return self;
}
- (void)setupview {
    [self addSubview:self.abstractName];
    [self addSubview:self.abstractBreak];
    [self addSubview:self.abstractDetail];
}

- (UILabel *)abstractName {
    if(!_abstractName) {
        _abstractName = [[UILabel alloc] init];
        _abstractName.numberOfLines = 1;
        _abstractName.font = [UIFont systemFontOfSize:12.0];
        _abstractName.textColor = [UIColor colorWithRed:187 / 255.0 green:187 / 255.0 blue:187 / 255.0 alpha:1 / 1.0];
        _abstractName.textAlignment = isRTL()? NSTextAlignmentRight:NSTextAlignmentLeft;
    }
    return _abstractName;
}
- (UILabel *)abstractBreak {
    if(!_abstractBreak) {
        _abstractBreak = [[UILabel alloc] init];
        _abstractBreak.text = @":";
        _abstractBreak.font = [UIFont systemFontOfSize:12.0];
        _abstractBreak.textColor = TUIChatDynamicColor(@"chat_merge_message_content_color", @"#d5d5d5");
    }
    return _abstractBreak;
}
- (UILabel *)abstractDetail {
    if(!_abstractDetail) {
        _abstractDetail = [[UILabel alloc] init];
        _abstractDetail.numberOfLines = 0;
        _abstractDetail.font = [UIFont systemFontOfSize:12.0];
        _abstractDetail.textColor = TUIChatDynamicColor(@"chat_merge_message_content_color", @"#d5d5d5");
        _abstractDetail.textAlignment = isRTL()? NSTextAlignmentRight:NSTextAlignmentLeft;

    }
    return _abstractDetail;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    
    [super updateConstraints];

    [self.abstractName sizeToFit];
    [self.abstractName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.trailing.mas_lessThanOrEqualTo(self.abstractBreak.mas_leading);
        make.width.mas_equalTo(self.abstractNameLimitedWidth);
    }];
    
    [self.abstractBreak sizeToFit];
    [self.abstractBreak mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.abstractName.mas_trailing);
        make.top.mas_equalTo(self.abstractName);
        make.width.mas_offset(self.abstractBreak.frame.size.width);
        make.height.mas_offset(self.abstractBreak.frame.size.height);
    }];
    
    [self.abstractDetail sizeToFit];
    [self.abstractDetail mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.abstractBreak.mas_trailing);
        make.top.mas_equalTo(0);
        make.trailing.mas_lessThanOrEqualTo(self.mas_trailing).mas_offset(-15);
        make.bottom.mas_equalTo(self);
    }];
}
- (void)fillWithData:(NSAttributedString *)name detailContent:(NSAttributedString *)detailContent {

    self.abstractName.attributedText = name;
    self.abstractDetail.attributedText = detailContent;
    
    NSAttributedString * senderStr = [[NSAttributedString alloc] initWithString:self.abstractName.text];
    CGRect senderRect = [senderStr boundingRectWithSize:CGSizeMake(70, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                context:nil];
    self.abstractNameLimitedWidth = MIN(ceil(senderRect.size.width) + 2, 70);
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

    
}
- (void)layoutSubviews {
  

    [super layoutSubviews];
}


@end
@interface TUIMergeMessageCell ()

@property(nonatomic, strong) CAShapeLayer *maskLayer;
@property(nonatomic, strong) CAShapeLayer *borderLayer;
@property(nonatomic, strong) TUIMergeMessageDetailRow *contentRowView1;
@property(nonatomic, strong) TUIMergeMessageDetailRow *contentRowView2;
@property(nonatomic, strong) TUIMergeMessageDetailRow *contentRowView3;
@end

@implementation TUIMergeMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];
    }
    return self;
}

- (void)setupViews {
    self.container.backgroundColor = TUIChatDynamicColor(@"chat_merge_message_bg_color", @"#FFFFFF");

    _relayTitleLabel = [[UILabel alloc] init];
    _relayTitleLabel.text = @"Chat history";
    _relayTitleLabel.font = [UIFont systemFontOfSize:16];
    _relayTitleLabel.textColor = TUIChatDynamicColor(@"chat_merge_message_title_color", @"#000000");
    [self.container addSubview:_relayTitleLabel];

    _contentRowView1 = [[TUIMergeMessageDetailRow alloc] init];
    [self.container addSubview:_contentRowView1];
    _contentRowView2 = [[TUIMergeMessageDetailRow alloc] init];
    [self.container addSubview:_contentRowView2];
    _contentRowView3 = [[TUIMergeMessageDetailRow alloc] init];
    [self.container addSubview:_contentRowView3];
    
    _separtorView = [[UIView alloc] init];
    _separtorView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
    [self.container addSubview:_separtorView];

    _bottomTipsLabel = [[UILabel alloc] init];
    _bottomTipsLabel.text = TIMCommonLocalizableString(TUIKitRelayChatHistory);
    _bottomTipsLabel.textColor = TUIChatDynamicColor(@"chat_merge_message_content_color", @"#d5d5d5");
    _bottomTipsLabel.font = [UIFont systemFontOfSize:9];
    [self.container addSubview:_bottomTipsLabel];

    [self.container.layer insertSublayer:self.borderLayer atIndex:0];
    [self.container.layer setMask:self.maskLayer];

}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {

    [super updateConstraints];
    [self.relayTitleLabel sizeToFit];
    [self.relayTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container).mas_offset(10);
        make.top.mas_equalTo(self.container).mas_offset(10);
        make.trailing.mas_equalTo(self.container).mas_offset(-10);
        make.height.mas_equalTo(self.relayTitleLabel.font.lineHeight);
    }];
    
    [self.contentRowView1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.relayTitleLabel);
        make.top.mas_equalTo(self.relayTitleLabel.mas_bottom).mas_offset(3);
        make.trailing.mas_equalTo(self.container);
        make.height.mas_equalTo(self.mergeData.abstractRow1Size.height);
    }];
    [self.contentRowView2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.relayTitleLabel);
        make.top.mas_equalTo(self.contentRowView1.mas_bottom).mas_offset(3);
        make.trailing.mas_equalTo(self.container);
        make.height.mas_equalTo(self.mergeData.abstractRow2Size.height);
    }];
    [self.contentRowView3 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.relayTitleLabel);
        make.top.mas_equalTo(self.contentRowView2.mas_bottom).mas_offset(3);
        make.trailing.mas_equalTo(self.container);
        make.height.mas_equalTo(self.mergeData.abstractRow3Size.height);
    }];
    
    
    UIView *lastView =  self.contentRowView1;
    int count = self.mergeData.abstractSendDetailList.count;
    if (count >= 3) {
        lastView = self.contentRowView3;
    }
    else if (count == 2){
        lastView = self.contentRowView2;
    }
    
    [self.separtorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container).mas_offset(10);
        make.trailing.mas_equalTo(self.container).mas_offset(-10);
        make.top.mas_equalTo(lastView.mas_bottom).mas_offset(3);
        make.height.mas_equalTo(1);
    }];
    
    [self.bottomTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentRowView1);
        make.top.mas_equalTo(self.separtorView.mas_bottom).mas_offset(5);
        make.width.mas_lessThanOrEqualTo(self.container);
        make.height.mas_equalTo(self.bottomTipsLabel.font.lineHeight);
    }];
    
    self.maskLayer.frame = self.container.bounds;
    self.borderLayer.frame = self.container.bounds;

    UIRectCorner corner = UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft;
    if (self.mergeData.direction == MsgDirectionIncoming) {
        corner = UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight;
    }
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.container.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(10, 10)];
    self.maskLayer.path = bezierPath.CGPath;
    self.borderLayer.path = bezierPath.CGPath;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)fillWithData:(TUIMergeMessageCellData *)data {
    [super fillWithData:data];
    self.mergeData = data;
    self.relayTitleLabel.text = data.title;
    int count = self.mergeData.abstractSendDetailList.count;
    switch (count) {
        case 1:
            [self.contentRowView1 fillWithData:self.mergeData.abstractSendDetailList[0][@"sender"] detailContent:self.mergeData.abstractSendDetailList[0][@"detail"]];
            self.contentRowView1.hidden = NO;
            self.contentRowView2.hidden = YES;
            self.contentRowView3.hidden = YES;
            break;
        case 2:
            [self.contentRowView1 fillWithData:self.mergeData.abstractSendDetailList[0][@"sender"] detailContent:self.mergeData.abstractSendDetailList[0][@"detail"]];
            [self.contentRowView2 fillWithData:self.mergeData.abstractSendDetailList[1][@"sender"] detailContent:self.mergeData.abstractSendDetailList[1][@"detail"]];

            self.contentRowView1.hidden = NO;
            self.contentRowView2.hidden = NO;
            self.contentRowView3.hidden = YES;
            break;
        default:
            [self.contentRowView1 fillWithData:self.mergeData.abstractSendDetailList[0][@"sender"] detailContent:self.mergeData.abstractSendDetailList[0][@"detail"]];
            [self.contentRowView2 fillWithData:self.mergeData.abstractSendDetailList[1][@"sender"] detailContent:self.mergeData.abstractSendDetailList[1][@"detail"]];
            [self.contentRowView3 fillWithData:self.mergeData.abstractSendDetailList[2][@"sender"] detailContent:self.mergeData.abstractSendDetailList[2][@"detail"]];
            self.contentRowView1.hidden = NO;
            self.contentRowView2.hidden = NO;
            self.contentRowView3.hidden = NO;
            break;
    }
    
    [self prepareReactTagUI:self.container];

    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

- (CAShapeLayer *)maskLayer {
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer layer];
    }
    return _maskLayer;
}

- (CAShapeLayer *)borderLayer {
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.lineWidth = 1.0;
        _borderLayer.strokeColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB").CGColor;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _borderLayer;
}

// MARK: ThemeChanged
- (void)applyBorderTheme {
    if (_borderLayer) {
        _borderLayer.strokeColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB").CGColor;
    }
}

- (void)onThemeChanged {
    [self applyBorderTheme];
}

- (void)prepareReactTagUI:(UIView *)containerView {
    NSDictionary *param = @{TUICore_TUIChatExtension_ChatMessageReactPreview_Delegate: self};
    [TUICore raiseExtension:TUICore_TUIChatExtension_ChatMessageReactPreview_ClassicExtensionID parentView:containerView param:param];
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIMergeMessageCellData.class], @"data must be kind of TUIMergeMessageCellData");
    TUIMergeMessageCellData *mergeCellData = (TUIMergeMessageCellData *)data;
    
    mergeCellData.abstractRow1Size = [self.class caculate:mergeCellData index:0];
    mergeCellData.abstractRow2Size = [self.class caculate:mergeCellData index:1];
    mergeCellData.abstractRow3Size = [self.class caculate:mergeCellData index:2];

    NSAttributedString *abstractAttributedString = [mergeCellData abstractAttributedString];
    CGRect rect = [abstractAttributedString boundingRectWithSize:CGSizeMake(TMergeMessageCell_Width_Max - 20, MAXFLOAT)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                         context:nil];
    CGSize size = CGSizeMake(CGFLOAT_CEIL(rect.size.width), CGFLOAT_CEIL(rect.size.height) - 10);
    mergeCellData.abstractSize = size;
    CGFloat height = mergeCellData.abstractRow1Size.height + mergeCellData.abstractRow2Size.height + mergeCellData.abstractRow3Size.height;

    UIFont *titleFont = [UIFont systemFontOfSize:16];
    height = (10 + titleFont.lineHeight + 3) + height + 1 + 5 + 20 + 5 +3;
    return CGSizeMake(TMergeMessageCell_Width_Max, height);
}

+ (CGSize)caculate:(TUIMergeMessageCellData *)data index:(NSInteger)index {
    
    NSArray<NSDictionary *> *abstractSendDetailList = data.abstractSendDetailList;
    if (abstractSendDetailList.count <= index){
        return CGSizeZero;
    }
    NSAttributedString * senderStr = abstractSendDetailList[index][@"sender"];
    CGRect senderRect = [senderStr boundingRectWithSize:CGSizeMake(70, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                context:nil];
    
    NSMutableAttributedString *abstr = [[NSMutableAttributedString alloc] initWithString:@""];
    [abstr appendAttributedString:[[NSAttributedString alloc] initWithString:@":"]];
    [abstr appendAttributedString:abstractSendDetailList[index][@"detail"]];

    CGFloat senderWidth = MIN(CGFLOAT_CEIL(senderRect.size.width), 70);
    CGRect rect = [abstr boundingRectWithSize:CGSizeMake(200 - 20 - senderWidth, MAXFLOAT)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                context:nil];
    CGSize size = CGSizeMake(TMergeMessageCell_Width_Max,
                             MIN(TMergeMessageCell_Height_Max / 3.0, CGFLOAT_CEIL(rect.size.height)));

    return size;
}
@end
