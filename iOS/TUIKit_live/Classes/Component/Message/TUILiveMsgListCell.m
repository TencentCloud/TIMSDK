/**
 * Module: TUILiveMsgListCell
 *
 * Function: 消息Cell
 */

#import "TUILiveMsgListCell.h"
#import "TUILiveColor.h"
#import "TUILiveUtil.h"
#import "TRTCLiveRoom.h"
#import "UIView+Additions.h"

static NSMutableArray      *_arryColor;
static NSInteger           _index = 0;

@implementation TUILiveMsgListCell
{
    UIView  *_msgView;
    UILabel *_msgLabel;
    UIImageView *_msgBkView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _msgView  = [[UIView alloc] initWithFrame:CGRectZero];
        [_msgView setBackgroundColor:[UIColor.blackColor colorWithAlphaComponent:0.3]];
        
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.numberOfLines = 0;
        _msgLabel.font = [UIFont systemFontOfSize:MSG_TABLEVIEW_LABEL_FONT];
        //_msgLabel.backgroundColor = [UIColor whiteColor];

        [_msgView addSubview:_msgLabel];
        [self.contentView addSubview:_msgView];
        [_msgView.layer setCornerRadius:8];
    }
    return self;
}
 
- (void)layoutSubviews {
    _msgLabel.frame = CGRectMake(10, 2, _msgLabel.width, _msgLabel.height);
    _msgView.frame  = CGRectMake(0, 0, _msgLabel.width + 20, _msgLabel.height + 4);
    _msgBkView.frame = _msgView.frame;
}

- (void)refreshWithModel:(TUILiveMsgModel *)msgModel {
    _msgLabel.attributedText = msgModel.msgAttribText;
    _msgLabel.width = MSG_TABLEVIEW_WIDTH - 20;
    [_msgLabel sizeToFit];
}

+ (NSAttributedString *)getAttributedStringFromModel:(TUILiveMsgModel *)msgModel {
     _arryColor = [[NSMutableArray alloc] initWithObjects:UIColorFromRGB(0x1fbcb6),UIColorFromRGB(0x2b7de2),UIColorFromRGB(0xff7906),nil];

    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] init];
    NSString *msgUserName = msgModel.userName.length > 0 ? msgModel.userName : msgModel.userId;
    if (msgModel.msgType == TUILiveMsgModelType_NormalMsg || msgModel.msgType == TUILiveMsgModelType_DanmaMsg) {
        NSMutableAttributedString *userName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  ", msgUserName]];
        [attribute appendAttributedString:userName];
        
        NSMutableAttributedString *userMsg = [[NSMutableAttributedString alloc] initWithString:msgModel.userMsg];
        [attribute appendAttributedString:userMsg];
        
        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:MSG_TABLEVIEW_LABEL_FONT] range:NSMakeRange(0,attribute.length)];
        
        _index = _index % [_arryColor count];
        [attribute addAttribute:NSForegroundColorAttributeName value:[_arryColor objectAtIndex:_index] range:NSMakeRange(0,userName.length)];
        [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(userName.length, userMsg.length)];
        _index++;
    }
    else {
        NSMutableAttributedString *msgShow = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"通知 %@%@", msgUserName, msgModel.userMsg]];
        [attribute appendAttributedString:msgShow];
        [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:MSG_TABLEVIEW_LABEL_FONT] range:NSMakeRange(0, attribute.length)];
        [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:241/255.0 green:43/255.0 blue:91/255.0 alpha:1] range:NSMakeRange(0, msgShow.length)];
    }
    
    
    return attribute;
}
@end


#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Additions.h"
#import "UIView+CustomAutoLayout.h"


#pragma mark 观众列表

@implementation TCAudienceListCell
{
    UIImageView *_imageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews {
    _imageView.frame = CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE);
    _imageView.layer.cornerRadius = _imageView.size.width/2;
    _imageView.clipsToBounds = YES;
}

- (void)refreshWithModel:(TRTCLiveUserInfo *)msgModel {
    [_imageView sd_setImageWithURL:[NSURL URLWithString:[TUILiveUtil transImageURL2HttpsURL:msgModel.avatarURL]] placeholderImage:[UIImage imageNamed:@"face"]];
}
@end
