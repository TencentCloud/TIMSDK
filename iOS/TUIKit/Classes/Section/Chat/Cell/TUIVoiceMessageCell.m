#import "TUIVoiceMessageCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"


@implementation TUIVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _voice = [[UIImageView alloc] init];
        _voice.animationDuration = 1;
        [self.bubbleView addSubview:_voice];
        
        _duration = [[UILabel alloc] init];
        _duration.font = [UIFont systemFontOfSize:12];
        _duration.textColor = [UIColor grayColor];
        [self.bubbleView addSubview:_duration];
        
    }
    return self;
}

- (void)fillWithData:(TUIVoiceMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.voiceData = data;
    if (data.duration > 0) {
        _duration.text = [NSString stringWithFormat:@"%ld\"", (long)data.duration];
    } else {
        _duration.text = @"1\"";    // 显示0秒容易产生误解
    }
    _voice.image = data.voiceImage;
    _voice.animationImages = data.voiceAnimationImages;    
    //animate
    @weakify(self)
    [[RACObserve(data, isPlaying) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
                 @strongify(self)
                 if ([x boolValue]) {
                     [self.voice startAnimating];
                 } else {
                     [self.voice stopAnimating];
                 }
             }];
    if (data.direction == MsgDirectionIncoming) {
        _duration.textAlignment = NSTextAlignmentLeft;
    } else {
        _duration.textAlignment = NSTextAlignmentRight;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.duration.mm_width(TVoiceMessageCell_Duration_Size.width).mm_height(TVoiceMessageCell_Duration_Size.height).mm__centerY(self.bubbleView.mm_h/2);
    
    self.voice.mm_sizeToFit().mm_top(self.voiceData.voiceTop);
    
    if (self.voiceData.direction == MsgDirectionOutgoing) {
        self.bubbleView.mm_left(self.duration.mm_w).mm_flexToRight(0);
        self.duration.mm_left(-self.duration.mm_w);
        self.voice.mm_right(self.voiceData.cellLayout.bubbleInsets.right);
    } else {
        self.bubbleView.mm_left(0).mm_flexToRight(self.duration.mm_w);
        self.duration.mm_right(-self.duration.mm_w);
        self.voice.mm_left(self.voiceData.cellLayout.bubbleInsets.left);
    }
    
}


@end
