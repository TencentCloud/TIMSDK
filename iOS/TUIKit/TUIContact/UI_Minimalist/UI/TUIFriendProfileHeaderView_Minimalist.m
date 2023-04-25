//
//  TUIFriendProfileHeaderView_Minimalist.m
//  TUIContact
//
//  Created by wyl on 2022/12/14.
//

#import "TUIFriendProfileHeaderView_Minimalist.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMConfig.h>

@implementation TUIFriendProfileHeaderItemView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}
- (void)setupView {
    self.iconView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self addSubview:self.iconView];
    self.iconView.userInteractionEnabled = YES;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:kScale390(16)];
    self.textLabel.textColor = [UIColor tui_colorWithHex:@"#000000"];
    [self addSubview:self.textLabel];
    self.textLabel.text = @"Message";
    
    self.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
    self.layer.cornerRadius = kScale390(12);
    self.layer.masksToBounds = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [self addGestureRecognizer:tap];

}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconView.frame = CGRectMake((self.bounds.size.width - kScale390(30)) *0.5,
                                     kScale390(19),
                                     kScale390(30),
                                     kScale390(30));
    [self.textLabel sizeToFit];
    self.textLabel.frame = CGRectMake((self.bounds.size.width - self.textLabel.frame.size.width) *0.5 , self.iconView.frame.origin.y + self.iconView.frame.size.height + kScale390(11), self.bounds.size.width, kScale390(19));
    
}
- (void)click {
    if (self.messageBtnClickBlock) {
        self.messageBtnClickBlock();
    }
}
@end

@interface TUIFriendProfileHeaderView_Minimalist ()
@end

@implementation TUIFriendProfileHeaderView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.headImg = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self addSubview:self.headImg];
    self.headImg.userInteractionEnabled = YES;
    self.headImg.contentMode = UIViewContentModeScaleAspectFit;
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.font = [UIFont boldSystemFontOfSize:kScale390(24)];
    [self addSubview:self.descriptionLabel];
    
    self.functionListView = [[UIView alloc] init];
    [self addSubview:self.functionListView];
}

- (void)setItemViewList:(NSArray<TUIFriendProfileHeaderItemView *> *)itemList {
    for (UIView *subView in self.functionListView.subviews) {
        [subView removeFromSuperview];
    }
    
    if (itemList.count > 0) {
        for (TUIFriendProfileHeaderItemView *itemView in itemList) {
            [self.functionListView addSubview:itemView];
        }
        CGFloat width = kScale390(92);
        CGFloat height = kScale390(95);
        CGFloat space = kScale390(24);
        CGFloat contentWidth = itemList.count * width + (itemList.count - 1) * space;
        CGFloat x = 0.5 * (self.bounds.size.width - contentWidth);
        for (TUIFriendProfileHeaderItemView *itemView in itemList) {
            itemView.frame = CGRectMake(x, 0, width, height);
            x = CGRectGetMaxX(itemView.frame) + space;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.headImg.frame = CGRectMake((self.bounds.size.width - kScale390(94)) *0.5 , kScale390(42), kScale390(94), kScale390(94));
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = self.headImg.frame.size.height / 2.0;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.frame = CGRectMake((self.bounds.size.width - self.descriptionLabel.frame.size.width) *0.5 ,
                                             self.headImg.frame.origin.y + self.headImg.frame.size.height + kScale390(10),
                                             self.descriptionLabel.frame.size.width,
                                             self.descriptionLabel.frame.size.height);
    
    if (self.functionListView.subviews.count > 0) {
        self.functionListView.frame = CGRectMake(0, CGRectGetMaxY(self.descriptionLabel.frame) + kScale390(42), self.bounds.size.width, kScale390(95));
    }
}

@end
