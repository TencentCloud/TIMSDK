/**
 * Module: TCMsgBarrageView
 *
 * Function: 弹幕
 */

#import "TUILiveMsgBarrageView.h"
#import "UIView+Additions.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TUILiveUtil.h"
#import "TUILiveColor.h"

#define MSG_ANIMATE_VIEW_SPACE    30
#define MSG_IMAGEVIEW_WIDTH       27
#define MSG_LABEL_FONT            18
#define MSG_ANIMATE_DURANTION     8  //默认一个弹幕View的运行速度为： 2*SCREEN_WIDTH/MSG_ANIMATE_DURANTION

@implementation TUILiveMsgBarrageView
{
    NSMutableArray        *_unUsedAnimateViewArray;
    NSMutableArray        *_msgModelArray;
    CGFloat               _nextAnimateViewStartTime;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _unUsedAnimateViewArray = [NSMutableArray array];
        _msgModelArray   = [NSMutableArray array];
        _nextAnimateViewStartTime = 1;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    UIView *view = [self creatAnimateView];
    [_unUsedAnimateViewArray addObject:view];
    
    [self startAnimation];
}

- (UIView *)creatAnimateView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH + MSG_ANIMATE_VIEW_SPACE, 0, 0, self.height)];
    
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, self.height-4, self.height-4)];
    headImageView.layer.cornerRadius = headImageView.width/2;
    headImageView.layer.masksToBounds = YES;
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right + 2, 0, 0,14)];
    userNameLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *userMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(userNameLabel.left, userNameLabel.bottom, 0, self.height - userNameLabel.height)];
    userMsgLabel.backgroundColor = [UIColor clearColor];
    
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, self.height)];
    UIImage *image = [UIImage imageNamed:@"live_room_dam_message_arrage"];
    UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(24, 35, 5, 10) resizingMode:UIImageResizingModeStretch];
    backImageView.image = newImage;
    
    [view insertSubview:backImageView atIndex:0];
    [view insertSubview:headImageView atIndex:1];
    [view insertSubview:userNameLabel atIndex:2];
    [view insertSubview:userMsgLabel atIndex:3];
    [self addSubview:view];
    return view;
}

- (void)startAnimation {
    if (_msgModelArray.count != 0) {
        TUILiveMsgModel *msgModel = [_msgModelArray lastObject];
        if (_unUsedAnimateViewArray.count != 0) {
            UIView *view = [_unUsedAnimateViewArray lastObject];
            [_unUsedAnimateViewArray removeObject:view];

            [self animateView:view msg:msgModel];
            
        } else {
            UIView *view = [self creatAnimateView];
            [self animateView:view msg:msgModel];
        }
        [_msgModelArray removeObject:msgModel];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_nextAnimateViewStartTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startAnimation];
    });
}

- (void)stopAnimation {
    [self removeAllSubViews];
}

- (void)bulletNewMsg:(TUILiveMsgModel *)msgModel {
    [_msgModelArray insertObject:msgModel atIndex:0];
}

- (void)animateView:(UIView *)aView msg:(TUILiveMsgModel *)msgModel {
    UIView *newView = [self resetViewFrame:aView msg:msgModel];
    CGFloat duration =  MSG_ANIMATE_DURANTION *(SCREEN_WIDTH + newView.width + MSG_ANIMATE_VIEW_SPACE)/(2*SCREEN_WIDTH);
    _nextAnimateViewStartTime = duration*((newView.width + MSG_ANIMATE_VIEW_SPACE)/(SCREEN_WIDTH + newView.width + MSG_ANIMATE_VIEW_SPACE));
    _lastAnimateView = newView;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect frame =  newView.frame;
        newView.frame = CGRectMake(-frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
    } completion:^(BOOL finished) {
        newView.frame = CGRectMake(SCREEN_WIDTH + MSG_ANIMATE_VIEW_SPACE, 0, 0, self.height);
        [self->_unUsedAnimateViewArray insertObject:newView atIndex:0];
    }];

}

- (UIView *)resetViewFrame:(UIView *)aView msg:(TUILiveMsgModel *)msgModel {
    NSAttributedString *userName = [self getAttributedUserNameFromModel:msgModel];
    CGRect nameRect = [userName boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 14) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    NSAttributedString *userMsg = [self getAttributedUserMsgFromModel:msgModel];
    CGRect msgRect = [userMsg boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.height - 14) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    NSArray *viewArray = aView.subviews;
    if (viewArray.count >= 3) {
        UIImageView *headImageView = viewArray[1];
        UIImage *defaulImage = self.defaultAvatarImage ?: [UIImage imageNamed:@"live_audience_default_avatar"];
        [headImageView sd_setImageWithURL:[NSURL URLWithString:[TUILiveUtil transImageURL2HttpsURL:msgModel.userHeadImageUrl]] placeholderImage:defaulImage];
        
        UILabel *userNamelabel = viewArray[2];
        userNamelabel.attributedText = userName;
        userNamelabel.width = nameRect.size.width;
        
        UILabel *userMsgLabel = viewArray[3];
        userMsgLabel.attributedText = userMsg;
        userMsgLabel.width = msgRect.size.width;
        
        aView.width = headImageView.width + 4 + 10 + (userNamelabel.width > userMsgLabel.width ? userNamelabel.width : userMsgLabel.width);
        
        UIImageView *backImageView = viewArray[0];
        backImageView.width = aView.width;
    }
    return aView;
}

- (NSAttributedString *)getAttributedUserNameFromModel:(TUILiveMsgModel *)msgModel {
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] init];
    NSString *name = msgModel.userName.length > 0 ? msgModel.userName : msgModel.userId;
    NSMutableAttributedString *userName = [[NSMutableAttributedString alloc] initWithString:name];
    [attribute appendAttributedString:userName];
    
    [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0,attribute.length)];
    [attribute addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,userName.length)];
    return attribute;
}

- (NSAttributedString *)getAttributedUserMsgFromModel:(TUILiveMsgModel *)msgModel {
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *userMsg = [[NSMutableAttributedString alloc] initWithString:msgModel.userMsg];
    [attribute appendAttributedString:userMsg];
    
    [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0,attribute.length)];
    [attribute addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x89eede) range:NSMakeRange(0,userMsg.length)];;
    return attribute;
}
@end
