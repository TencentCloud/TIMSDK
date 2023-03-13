//
//  TUIGroupProfileCardViewCell.m
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//

#import "TUIGroupProfileCardViewCell_Minimalist.h"
#import "TUICore.h"
#import "TUIThemeManager.h"
#import "TUICommonModel.h"

@implementation TUIGroupProfileHeaderItemView_Minimalist
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

@interface TUIGroupProfileHeaderView_Minimalist ()
@end

@implementation TUIGroupProfileHeaderView_Minimalist

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
    
    self.idLabel = [[UILabel alloc] init];
    self.idLabel.font = [UIFont systemFontOfSize:kScale390(12)];
    self.idLabel.textColor = [UIColor tui_colorWithHex:@"666666"];
    [self addSubview:self.idLabel];
    
    self.itemMessage = [[TUIGroupProfileHeaderItemView_Minimalist alloc] init];
    [self addSubview:self.itemMessage];
    
    self.itemAudio = [[TUIGroupProfileHeaderItemView_Minimalist alloc] init];
    [self addSubview:self.itemAudio];
    
    self.itemVideo = [[TUIGroupProfileHeaderItemView_Minimalist alloc] init];
    [self addSubview:self.itemVideo];

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

    [self.idLabel sizeToFit];
    self.idLabel.frame = CGRectMake((self.bounds.size.width - self.idLabel.frame.size.width) *0.5 ,
                                             self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + kScale390(8),
                                       self.idLabel.frame.size.width,
                                       self.idLabel.frame.size.height);

    
    CGFloat width = self.bounds.size.width;
    CGFloat padding = kScale390(24);
    if(!self.itemVideo.isHidden && !self.itemAudio.isHidden) {
        self.itemMessage.frame = CGRectMake(kScale390(33), self.idLabel.frame.origin.y + self.idLabel.frame.size.height + kScale390(18), kScale390(92), kScale390(95));
        self.itemAudio.frame = CGRectMake(self.itemMessage.frame.origin.x +self.itemMessage.frame.size.width + kScale390(24), self.idLabel.frame.origin.y + self.idLabel.frame.size.height + kScale390(18), kScale390(92), kScale390(95));
        self.itemVideo.frame = CGRectMake(self.itemAudio.frame.origin.x +self.itemMessage.frame.size.width + kScale390(24), self.idLabel.frame.origin.y + self.idLabel.frame.size.height + kScale390(18), kScale390(92), kScale390(95));
    }
    else {
        self.itemMessage.frame = CGRectMake((self.bounds.size.width - kScale390(92)) *0.5, self.idLabel.frame.origin.y + self.idLabel.frame.size.height + kScale390(18), kScale390(92), kScale390(95));
    }
}

@end

@implementation TUIGroupProfileCardViewCell_Minimalist

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.headerView = [[TUIGroupProfileHeaderView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, kScale390(355))];

    [self.contentView addSubview:self.headerView];
}

- (void)fillWithData:(TUIGroupProfileCardCellData_Minimalist *)data {
    [super fillWithData:data];
    self.cardData = data;

    [self.headerView.headImg sd_setImageWithURL:data.avatarUrl placeholderImage:data.avatarImage];
    self.headerView.descriptionLabel.text = data.name;
    self.headerView.idLabel.text = [NSString stringWithFormat:@"ID: %@",data.identifier];
    [self setupHeaderViewData];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, kScale390(355));
    [self.headerView.descriptionLabel sizeToFit];
}
- (void)setupHeaderViewData {
    
    [self.headerView.itemMessage.iconView setImage:
         TUIDynamicImage(@"", TUIThemeModuleContact_Minimalist, [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_message")])
    ];
    self.headerView.itemMessage.textLabel.text = TUIKitLocalizableString(TUIKitMessage);
    
    [self.headerView.itemAudio.iconView setImage:
         TUIDynamicImage(@"", TUIThemeModuleContact_Minimalist, [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_audio")])
    ];
    self.headerView.itemAudio.textLabel.text = TUIKitLocalizableString(TUIKitAudio);
    
    [self.headerView.itemVideo.iconView setImage:
         TUIDynamicImage(@"", TUIThemeModuleContact_Minimalist, [UIImage imageNamed:TUIContactImagePath_Minimalist(@"contact_info_video")])
    ];
    self.headerView.itemVideo.textLabel.text = TUIKitLocalizableString(TUIKitVideo);
    
    NSString *groupID = self.cardData.identifier;
    NSString *userID = nil;
    NSDictionary *param = @{TUICore_TUIChatExtension_GetMoreCellInfo_GroupID : groupID ? groupID : @"",TUICore_TUIChatExtension_GetMoreCellInfo_UserID : userID ? userID : @""};
    NSDictionary *videoExtentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_VideoCall param:param];
    NSDictionary *audioExtentionInfo = [TUICore getExtensionInfo:TUICore_TUIChatExtension_GetMoreCellInfo_AudioCall param:param];
    
    self.headerView.itemVideo.hidden = YES;
    self.headerView.itemAudio.hidden = YES;
    if (audioExtentionInfo) {
        self.headerView.itemAudio.hidden = NO;
    }
    if (videoExtentionInfo) {
        self.headerView.itemVideo.hidden = NO;
    }
    
}
@end
