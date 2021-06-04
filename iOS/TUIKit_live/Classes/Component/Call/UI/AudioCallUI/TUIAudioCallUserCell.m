//
//  TUIAudioCallUserCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/7.
//

#import "TUIAudioCallUserCell.h"

@implementation TUIAudioCallUserCell
{
    UIImageView *_cellImgView;
    UILabel *_cellUserLabel;
    UIProgressView *_volumeProgress;
    UIActivityIndicatorView *_actvity;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews {
    _cellImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_cellImgView];
    
    _cellUserLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _cellUserLabel.backgroundColor = [UIColor blackColor];
    _cellUserLabel.textColor = [UIColor whiteColor];
    _cellUserLabel.alpha = 0.7;
    _cellUserLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_cellUserLabel];
    
    _volumeProgress = [[UIProgressView alloc] initWithFrame:CGRectZero];
    [self addSubview:_volumeProgress];
}

- (void)defaultLayout
{
    _cellImgView.mm_width(self.mm_h).mm_height(self.mm_h).mm_left(0);
    _cellUserLabel.mm_width(self.mm_h).mm_height(24).mm_left(_cellImgView.mm_x).mm_flexToRight(_cellImgView.mm_r).mm_bottom(_cellImgView.mm_b);
    _volumeProgress.mm_width(self.mm_h).mm_height(4).mm_left(_cellImgView.mm_x).mm_flexToRight(_cellImgView.mm_r).mm_bottom(_cellImgView.mm_b);
}

- (void)fillWithData:(CallUserModel *)model {
    [self defaultLayout];
    [_cellImgView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_c2c_head")] options:SDWebImageHighPriority];
    _cellUserLabel.text = model.name.length > 0 ? model.name : model.userId;
    _volumeProgress.progress = model.volume;
    BOOL noModel = (model.userId.length == 0);
    [_cellImgView setHidden:noModel];
    [_cellUserLabel setHidden:noModel];
    [_volumeProgress setHidden:(noModel || !model.isEnter)];
}
@end
