//
//  TUISystemMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUISystemMessageCell.h"
#import <TIMCommon/TIMDefine.h>

@interface TUISystemMessageCell ()
@property (nonatomic, strong) UILabel *messageLabel;
@property TUISystemMessageCellData *systemData;
@end

@implementation TUISystemMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:13];
        _messageLabel.textColor = [UIColor d_systemGrayColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.layer.cornerRadius = 3;
        [_messageLabel.layer setMasksToBounds:YES];
        [self.container addSubview:_messageLabel];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)fillWithData:(TUISystemMessageCellData *)data;
{
    [super fillWithData:data];
    self.systemData = data;
    self.messageLabel.attributedText = data.attributedString;
    self.nameLabel.hidden = YES;
    self.avatarView.hidden = YES;
    self.retryView.hidden = YES;
    [self.indicator stopAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.container.center = self.contentView.center;
    self.messageLabel.frame = self.container.bounds;
}

@end
