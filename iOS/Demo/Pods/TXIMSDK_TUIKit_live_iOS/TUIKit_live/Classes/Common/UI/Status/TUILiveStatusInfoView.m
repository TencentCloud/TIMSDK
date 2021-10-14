/**
 * Module: TCPlayerItem
 *
 * Function: 播放器画面显示正在加载，日志等
 */

#import <Foundation/Foundation.h>
#import "TUILiveStatusInfoView.h"
#import "TRTCCloud.h"
#import <Masonry/Masonry.h>

@interface TUILiveStatusInfoView()
{
    UIView*                 _loadingBackground;
    UIImageView *           _loadingImageView;
    NSString*       		_eventMsg;
}
@end


@implementation TUILiveStatusInfoView
 
- (void)setVideoView:(UIView *)videoView {
    _videoView = videoView;
    [self initLoadingView:videoView];
}

- (void)initLoadingView:(UIView *)view {
    CGRect rect = view.frame;
    
    if (_loadingBackground == nil) {
        _loadingBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
        _loadingBackground.hidden = YES;
        _loadingBackground.backgroundColor = [UIColor blackColor];
        _loadingBackground.alpha  = 0.5;
        [view addSubview:_loadingBackground];
        [_loadingBackground mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
    }
    
    if (_loadingImageView == nil) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:
                                 [UIImage imageNamed:@"live_loading_image0.png"],
                                 [UIImage imageNamed:@"live_loading_image1.png"],
                                 [UIImage imageNamed:@"live_loading_image2.png"],
                                 [UIImage imageNamed:@"live_loading_image3.png"],
                                 [UIImage imageNamed:@"live_loading_image4.png"],
                                 [UIImage imageNamed:@"live_loading_image5.png"],
                                 [UIImage imageNamed:@"live_loading_image6.png"],
                                 [UIImage imageNamed:@"live_loading_image7.png"],
                                 [UIImage imageNamed:@"live_loading_image8.png"],
                                 [UIImage imageNamed:@"live_loading_image9.png"],
                                 [UIImage imageNamed:@"live_loading_image10.png"],
                                 [UIImage imageNamed:@"live_loading_image11.png"],
                                 [UIImage imageNamed:@"live_loading_image12.png"],
                                 [UIImage imageNamed:@"live_loading_image13.png"],
                                 [UIImage imageNamed:@"live_loading_image14.png"],
                                 nil];
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.animationImages = array;
        _loadingImageView.animationDuration = 1;
        _loadingImageView.hidden = YES;
        [view addSubview:_loadingImageView];
        [_loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(50));
            make.center.equalTo(view);
        }];
    }
}

- (void)emptyPlayInfo {
    _pending = NO;
    _userID  = @"";
    _playUrl = @"";
    _eventMsg = nil;
}

- (void)startLoading {
    if (_loadingBackground) {
        _loadingBackground.hidden = NO;
    }
    
    if (_loadingImageView) {
        _loadingImageView.hidden = NO;
        [_loadingImageView startAnimating];
    }
}

- (void)stopLoading {
    if (_loadingBackground) {
        _loadingBackground.hidden = YES;
    }
    
    if (_loadingImageView) {
        _loadingImageView.hidden = YES;
        [_loadingImageView stopAnimating];
    }
}

- (void)startPlay:(NSString*)playUrl {
    if (_btnKickout) {
        _btnKickout.hidden = YES;
    }
}

- (void)stopPlay {
    [self stopLoading];
    if (_btnKickout) {
        _btnKickout.hidden = YES;
    }
}

@end
