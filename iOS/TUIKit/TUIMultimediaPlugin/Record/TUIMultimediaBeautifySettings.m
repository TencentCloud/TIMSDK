// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaBeautifySettings.h"
#import <TXLiteAVSDK_Professional/TXUGCRecord.h>
#include "TUIMultimediaPlugin/TUIMultimediaCommon.h"

@implementation TUIMultimediaBeautifySettings

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _activeBeautifyTag = TUIMultimediaEffectItemTagNone;
        _beautifyItems = [TUIMultimediaEffectItem defaultBeautifyEffects];
        _filterItems = [TUIMultimediaEffectItem defaultFilterEffects];
    }
    return self;
}

@end
