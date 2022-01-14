package com.tencent.liteav.trtccalling.ui.videocall;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Window;
import android.view.WindowManager;

import com.tencent.liteav.trtccalling.model.TUICalling;
import com.tencent.liteav.trtccalling.model.util.TUICallingConstants;
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;

public class TRTCVideoCallActivity extends Activity {

    private BaseTUICallView mCallView;
    private Window          mWindow;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mWindow = this.getWindow();
        mWindow.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        Intent intent = getIntent();
        TUICalling.Role role = (TUICalling.Role) intent.getExtras().get(TUICallingConstants.PARAM_NAME_ROLE);
        String[] userIds = intent.getExtras().getStringArray(TUICallingConstants.PARAM_NAME_USERIDS);
        String sponsorID = intent.getExtras().getString(TUICallingConstants.PARAM_NAME_SPONSORID);
        String groupID = intent.getExtras().getString(TUICallingConstants.PARAM_NAME_GROUPID);
        boolean isFromGroup = intent.getExtras().getBoolean(TUICallingConstants.PARAM_NAME_ISFROMGROUP);
        if (isGroupCall(groupID, userIds, role, isFromGroup)) {
            mCallView = new TUIGroupCallVideoView(this, role, userIds, sponsorID, groupID, isFromGroup) {
                @Override
                public void finish() {
                    super.finish();
                    TRTCVideoCallActivity.this.finish();
                }
            };
        } else {
            mCallView = new TUICallVideoView(this, role, userIds, sponsorID, groupID, isFromGroup) {
                @Override
                public void finish() {
                    super.finish();
                    TRTCVideoCallActivity.this.finish();
                }
            };
        }
        setContentView(mCallView);
    }

    private boolean isGroupCall(String groupID, String[] userIDs, TUICalling.Role role, boolean isFromGroup) {
        if (!TextUtils.isEmpty(groupID)) {
            return true;
        }
        if (TUICalling.Role.CALL == role) {
            return userIDs.length >= 2;
        } else {
            return userIDs.length >= 1 || isFromGroup;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mWindow.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    @Override
    public void onBackPressed() {

    }
}
