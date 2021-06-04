//
//  TUIVideoRenderView.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/8.
//

#import "TUIVideoRenderView.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"

@implementation TUIVideoRenderView
{
    UIImageView *_cellImgView;
    UILabel *_cellUserLabel;
    UIProgressView *_volumeProgress;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cellImgView = [[UIImageView alloc] init];
        [self addSubview:_cellImgView];
        _cellUserLabel = [[UILabel alloc] init];
        _cellUserLabel.textColor = [UIColor whiteColor];
        _cellUserLabel.backgroundColor = [UIColor clearColor];
        _cellUserLabel.textAlignment = NSTextAlignmentCenter;
        _cellUserLabel.font = [UIFont systemFontOfSize:11];
        _cellUserLabel.numberOfLines = 2;
        [self addSubview:_cellUserLabel];
        _volumeProgress = [[UIProgressView alloc] initWithFrame:CGRectZero];
        [self addSubview:_volumeProgress];
    }
    return self;
}

- (void)fillWithData:(CallUserModel *)model {
    self.backgroundColor = [UIColor darkGrayColor];
    BOOL noModel = model.userId.length == 0;
    if (!noModel) {
        _cellImgView.mm_width(40).mm_height(40).mm__centerX(self.mm_centerX).mm__centerY(self.mm_centerY - 20);
        [_cellImgView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_c2c_head")] options:SDWebImageHighPriority];
        _cellUserLabel.mm_left(self.mm_x).mm_right(self.mm_r).mm_height(22).mm_top(_cellImgView.mm_b + 2);
        _volumeProgress.mm_left(_cellImgView.mm_x).mm_flexToRight(_cellImgView.mm_r).mm_bottom(_cellImgView.mm_b).mm_height(4);
        _cellUserLabel.text = model.name;
        _volumeProgress.progress = model.volume;
        _cellImgView.hidden = model.isVideoAvaliable;
        _cellUserLabel.hidden = model.isVideoAvaliable;
    }
}

@end
