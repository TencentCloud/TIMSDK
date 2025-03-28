package com.tencent.cloud.tuikit.roomkit.view.main.share;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_SHARE_ROOM_PANEL;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.CommonUtils;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.Locale;
import java.util.Map;

public class ShareRoomDialog extends BaseBottomDialog implements ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String           URL_ROOM_KIT_WEB  = "https://web.sdk.qcloud.com/component/tuiroom/index.html";
    private              Context          mContext;
    private              ConferenceState  mRoomStore;
    private              TextView         mTextRoomId;
    private              TextView         mTextRoomLink;
    private              TextView         mTextRoomType;
    private              TextView         mTextRoomName;
    private              TextView         mTextRoomPassword;
    private              TextView         mTextRoomTime;
    private              RelativeLayout   mRlPasswordLayout;
    private              LinearLayout     mButtonCopyRoomId;
    private              LinearLayout     mButtonCopyRoomLink;
    private              LinearLayout     mButtonCopyRoomPassword;
    private              TextView         mButtonCopyRoomIdAndLink;
    private              RelativeLayout   mRootCopyRoomLink;
    private final        Observer<String> mRoomNameObserver = this::updateRoomNameView;

    public ShareRoomDialog(@NonNull Context context) {
        super(context);
        ConferenceEventCenter.getInstance().subscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(CONFIGURATION_CHANGE, this);
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_SHARE_ROOM_PANEL, null);

        ConferenceController.sharedInstance().getRoomState().roomName.removeObserver(mRoomNameObserver);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_share_room;
    }

    @Override
    protected void initView() {
        mContext = getContext();
        mRoomStore = ConferenceController.sharedInstance(mContext).getConferenceState();
        mTextRoomId = findViewById(R.id.invite_room_id);
        mRootCopyRoomLink = findViewById(R.id.tuiroomkit_root_room_link);
        mTextRoomLink = findViewById(R.id.invite_room_link);
        mButtonCopyRoomId = findViewById(R.id.btn_invite_copy_room_id);
        mButtonCopyRoomLink = findViewById(R.id.btn_invite_copy_room_link);
        mButtonCopyRoomIdAndLink = findViewById(R.id.btn_copy_room_id_and_link);
        mButtonCopyRoomPassword = findViewById(R.id.btn_invite_copy_room_password);
        mTextRoomName = findViewById(R.id.invite_room_name);
        mTextRoomPassword = findViewById(R.id.invite_room_password);
        mTextRoomType = findViewById(R.id.invite_room_type);
        mTextRoomTime = findViewById(R.id.invite_room_time);
        mRlPasswordLayout = findViewById(R.id.tuiroomkit_rl_invite_room_password);

        ConferenceController.sharedInstance().getRoomState().roomName.observe(mRoomNameObserver);
        mTextRoomId.setText(mRoomStore.roomInfo.roomId);
        mTextRoomType.setText(mRoomStore.roomInfo.isSeatEnabled ? getContext().getString(R.string.tuiroomkit_room_raise_hand) : getContext().getString(R.string.tuiroomkit_room_free_speech));
        if (!TextUtils.isEmpty(mRoomStore.roomInfo.password)) {
            mRlPasswordLayout.setVisibility(View.VISIBLE);
            mTextRoomPassword.setText(mRoomStore.roomInfo.password);
        } else {
            mRlPasswordLayout.setVisibility(View.GONE);
        }

        mTextRoomLink.setText(getRoomURL());
        mRootCopyRoomLink.setVisibility(needShowRoomLink() ? View.VISIBLE : View.GONE);

        mButtonCopyRoomId.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                CommonUtils.copyToClipboard(mTextRoomId.getText().toString(), mContext.getString(R.string.tuiroomkit_copy_room_id_success));
            }
        });

        mButtonCopyRoomPassword.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                CommonUtils.copyToClipboard(mTextRoomPassword.getText().toString(), mContext.getString(R.string.tuiroomkit_copy_room_password_success));
            }
        });

        mButtonCopyRoomLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                CommonUtils.copyToClipboard(mTextRoomLink.getText().toString(), mContext.getString(R.string.tuiroomkit_copy_room_line_success));
            }
        });
        mButtonCopyRoomIdAndLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                CommonUtils.copyToClipboard(getInviteLinkInfo(), mContext.getString(R.string.tuiroomkit_copy_room_invitation_link_success));
            }
        });
    }

    private String getInviteLinkInfo() {
        String selfName = ConferenceController.sharedInstance().getUserState().selfInfo.get().userName;
        if (TextUtils.isEmpty(mTextRoomPassword.getText())) {
            return String.format(Locale.getDefault(), getContext().getString(R.string.tuiroomkit_format_copy_room_info_without_password), selfName, mTextRoomName.getText().toString(), mTextRoomId.getText().toString());
        }
        return String.format(Locale.getDefault(), getContext().getString(R.string.tuiroomkit_format_copy_room_info_with_password), selfName, mTextRoomName.getText().toString(), mTextRoomId.getText().toString(), mTextRoomPassword.getText().toString());
    }

    public String getRoomURL() {
        String packageName = mContext.getPackageName();
        if (TextUtils.equals(packageName, "com.tencent.liteav.tuiroom")) {
            return "https://web.sdk.qcloud.com/trtc/webrtc/test/tuiroom-inner/index.html#/room?roomId=" + mRoomStore.roomInfo.roomId;
        } else if (TextUtils.equals(packageName, "com.tencent.trtc")) {
            return "https://web.sdk.qcloud.com/component/tuiroom/index.html#/room?roomId=" + mRoomStore.roomInfo.roomId;
        } else {
            return null;
        }
    }

    public boolean needShowRoomLink() {
        String packageName = mContext.getPackageName();
        return TextUtils.equals(packageName, "com.tencent.liteav.tuiroom") || TextUtils.equals(packageName, "com.tencent.trtc");
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

    private void updateRoomNameView(String name) {
        mTextRoomName.setText(name);
    }
}
