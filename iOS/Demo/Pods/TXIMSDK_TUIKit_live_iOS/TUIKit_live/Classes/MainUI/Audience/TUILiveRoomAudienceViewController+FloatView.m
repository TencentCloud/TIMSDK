//
//  TUILiveRoomAudienceViewController+FloatView.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/10/26.
//

#import "TUILiveRoomAudienceViewController+FloatView.h"
#import "TUILiveFloatWindow.h"
#import "TUILiveAudienceVideoRenderView.h"

@implementation TUILiveRoomAudienceViewController (FloatView)

- (void)prepareToShowFloatView {
    [TUILiveFloatWindow sharedInstance].renderView = self.renderView;
    [[TUILiveFloatWindow sharedInstance] show];
    [TUILiveFloatWindow sharedInstance].backController = self;
    BOOL isPK = self.roomStatus == TRTCLiveRoomLiveStatusRoomPK;
    [[TUILiveFloatWindow sharedInstance] switchPKStatus:isPK];
}

@end
