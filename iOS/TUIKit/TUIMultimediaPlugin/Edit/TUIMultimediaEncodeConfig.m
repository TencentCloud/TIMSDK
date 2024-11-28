// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaEncodeConfig.h"
#import <TUICore/TUIDefine.h>

#define TUICore_TUIMultimediaService_VideoQuality_Low 1
#define TUICore_TUIMultimediaService_VideoQuality_Medium 2
#define TUICore_TUIMultimediaService_VideoQuality_High 3

@interface TUIMultimediaEncodeConfig () {
    int _videoQuality;
}
@end

@implementation TUIMultimediaEncodeConfig
- (instancetype)init {
    return [self initWithVideoQuality:TUICore_TUIMultimediaService_VideoQuality_Medium];
}

- (instancetype)initWithVideoQuality:(int)videoQuality {
    switch (videoQuality) {
        case TUICore_TUIMultimediaService_VideoQuality_Low:
            _bitrate = 1000;
            _fps = 25;
            break;
        case TUICore_TUIMultimediaService_VideoQuality_High:
            _bitrate = 5000;
            _fps = 30;
            break;
        case TUICore_TUIMultimediaService_VideoQuality_Medium:
        default:
            _bitrate = 3000;
            _fps = 25;
            break;
    }
    _videoQuality = videoQuality;
    return self;
}

- (TXVideoCompressed)getVideoEditCompressed {
    switch (_videoQuality) {
        case TUICore_TUIMultimediaService_VideoQuality_High:
            return VIDEO_COMPRESSED_1080P;
        case TUICore_TUIMultimediaService_VideoQuality_Low:
        case TUICore_TUIMultimediaService_VideoQuality_Medium:
        default:
            return VIDEO_COMPRESSED_720P;
    }
}

- (TXVideoResolution)getVideoRecordResolution {
    switch (_videoQuality) {
        case TUICore_TUIMultimediaService_VideoQuality_High:
            return VIDEO_RESOLUTION_1080_1920;
        case TUICore_TUIMultimediaService_VideoQuality_Low:
        case TUICore_TUIMultimediaService_VideoQuality_Medium:
        default:
            return VIDEO_RESOLUTION_720_1280;
    }
}
@end
