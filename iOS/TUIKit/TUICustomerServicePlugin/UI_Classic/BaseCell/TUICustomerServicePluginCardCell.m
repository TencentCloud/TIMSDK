//
//  TUICustomerServicePluginCardCell.m
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import "TUICustomerServicePluginCardCell.h"
#import "TUICustomerServicePluginDataProvider.h"
#import "TUICustomerServicePluginDataProvider+CalculateSize.h"

@interface TUICustomerServicePluginCardCell()

@end

@implementation TUICustomerServicePluginCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.font = [UIFont systemFontOfSize:12];
        _headerLabel.numberOfLines = 3;
        _headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _headerLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_card_header_text_color", @"#000000");
        [self.container addSubview:_headerLabel];
        
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:16];
        _descLabel.numberOfLines = 1;
        _descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _descLabel.textColor = TUICustomerServicePluginDynamicColor(@"customer_service_card_desc_text_color", @"#FF6C2E");
        
        [self.container addSubview:_descLabel];
        
        _picView = [[UIImageView alloc] init];
        _picView.layer.cornerRadius = 8;
        _picView.layer.masksToBounds = YES;
        [self.container addSubview:_picView];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
        [self.container addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)onTapped:(UITapGestureRecognizer *)recognizer {
    NSURL *url = [NSURL URLWithString:self.customData.jumpURL ? : @""];
    [TUITool openLinkWithURL:url];
}

- (void)fillWithData:(TUICustomerServicePluginCardCellData *)data {
    [super fillWithData:data];
    
    self.customData = data;
    self.headerLabel.text = data.header;
    self.descLabel.text = data.desc;
    [self.picView sd_setImageWithURL:[NSURL URLWithString:data.picURL] placeholderImage:TUICustomerServicePluginBundleThemeImage(@"customer_service_card_pic_placeholder_img", @"card_pic_placeholder")];
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

// Override, the size of bubble content.
+ (CGSize)getContentSize:(TUICustomerServicePluginCardCellData *)data {
    return CGSizeMake(TUICustomerServicePluginCardBubbleWidth, 112);
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.picView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(14);
        make.top.mas_equalTo(13);
        make.width.mas_equalTo(86);
        make.height.mas_equalTo(86);
    }];
    
    CGSize headerSize = [TUICustomerServicePluginDataProvider calcCardHeaderSize:self.customData.header];
    [self.headerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.picView.mas_trailing).offset(12);
        make.top.mas_equalTo(13);
        make.width.mas_equalTo(headerSize.width);
        make.height.mas_equalTo(headerSize.height);
    }];
    
    [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.picView.mas_trailing).offset(12);
        make.bottom.mas_equalTo(self.container.mas_bottom).mas_offset(-13);
        make.width.mas_equalTo(headerSize.width);
        make.height.mas_equalTo(22);
    }];
}

@end
