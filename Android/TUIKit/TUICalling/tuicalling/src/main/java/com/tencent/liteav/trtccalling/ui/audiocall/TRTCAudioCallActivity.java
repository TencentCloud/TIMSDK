package com.tencent.liteav.trtccalling.ui.audiocall;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.tencent.liteav.trtccalling.model.TUICalling;
import com.tencent.liteav.trtccalling.model.util.TUICallingConstants;
import com.tencent.liteav.trtccalling.ui.base.BaseTUICallView;

public class TRTCAudioCallActivity extends Activity {

    private BaseTUICallView mCallView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = getIntent();
        TUICalling.Role role = (TUICalling.Role) intent.getExtras().get(TUICallingConstants.PARAM_NAME_ROLE);
        String[] userIds = intent.getExtras().getStringArray(TUICallingConstants.PARAM_NAME_USERIDS);
        String sponsorID = intent.getExtras().getString(TUICallingConstants.PARAM_NAME_SPONSORID);
        String groupID = intent.getExtras().getString(TUICallingConstants.PARAM_NAME_GROUPID);
        boolean isFromGroup = intent.getExtras().getBoolean(TUICallingConstants.PARAM_NAME_ISFROMGROUP);
        if (isGroupCall(groupID, userIds, role, isFromGroup)) {
            mCallView = new TUIGroupCallAudioView(this, role, userIds, sponsorID, groupID, isFromGroup) {
                @Override
                public void finish() {
                    super.finish();
                    TRTCAudioCallActivity.this.finish();
                }
            };
        } else {
            mCallView = new TUICallAudioView(this, role, userIds, sponsorID, groupID, isFromGroup) {
                @Override
                public void finish() {
                    super.finish();
                    TRTCAudioCallActivity.this.finish();
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
}
