package com.tencent.cloud.tuikit.roomkit.view.page.widget.Dialog;

import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter.RoomKitUIEvent.DISMISS_INVITE_PANEL;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceSessionImpl;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseBottomDialog;

import java.util.Map;

public class InviteDialog extends BaseBottomDialog implements ConferenceEventCenter.RoomKitUIEventResponder {
    
    private RelativeLayout mLayoutAddUser;
    private RelativeLayout mLayoutShareRoom;

    public InviteDialog(@NonNull Context context) {
        super(context);
        ConferenceEventCenter.getInstance().subscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(CONFIGURATION_CHANGE, this);
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_INVITE_PANEL, null);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_invite;
    }

    @Override
    protected void initView() {
        mLayoutAddUser = findViewById(R.id.ll_add_user);
        mLayoutShareRoom = findViewById(R.id.ll_share_room);
        mLayoutAddUser.setVisibility(ConferenceSessionImpl.sharedInstance().mContactsActivity == null ? View.GONE : View.VISIBLE);

        mLayoutAddUser.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ConferenceEventCenter.getInstance().notifyUIEvent(
                        ConferenceEventCenter.RoomKitUIEvent.SHOW_SELECT_USER_TO_CALL_VIEW, null);
                dismiss();
            }
        });

        mLayoutShareRoom.setOnClickListener(view -> {
            ConferenceEventCenter.getInstance().notifyUIEvent(
                    ConferenceEventCenter.RoomKitUIEvent.SHOW_SHARE_ROOM_PANEL, null);
            dismiss();
        });
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (TextUtils.equals(key, CONFIGURATION_CHANGE)) {
            if (params == null || !isShowing()) {
                return;
            }
            Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
            changeConfiguration(configuration);
        }
    }
}
