package com.tencent.cloud.tuikit.roomkit.view.main.roominfo;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;

import java.util.HashMap;
import java.util.Map;

public class RoomInfoViewModel implements ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String URL_ROOM_KIT_WEB = "https://web.sdk.qcloud.com/component/tuiroom/index.html";
    private static final String LABEL            = "Label";

    private Context         mContext;
    private ConferenceState mConferenceState;
    private TUIRoomEngine   mRoomEngine;
    private RoomInfoDialog  mRoomInfoView;

    public RoomInfoViewModel(Context context, RoomInfoDialog view) {
        mContext = context;
        mRoomInfoView = view;
        mConferenceState = ConferenceController.sharedInstance(context).getConferenceState();
        mRoomEngine = ConferenceController.sharedInstance(context).getRoomEngine();
        ConferenceEventCenter.getInstance().subscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void copyContentToClipboard(String content, String msg) {
        ClipboardManager cm = (ClipboardManager) mContext.getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData mClipData = ClipData.newPlainText(LABEL, content);
        cm.setPrimaryClip(mClipData);
        RoomToast.toastShortMessageCenter(msg);
    }

    public void setMasterName() {
        String ownerId = ConferenceController.sharedInstance().getConferenceState().roomInfo.ownerId;
        mRoomEngine.getUserInfo(ownerId, new TUIRoomDefine.GetUserInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                String alternativeName = TextUtils.isEmpty(userInfo.userName) ? userInfo.userId : userInfo.userName;
                String name = TextUtils.isEmpty(userInfo.nameCard) ? alternativeName : userInfo.nameCard;
                mRoomInfoView.setMasterName(name);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                mRoomInfoView.setMasterName(ownerId);
            }
        });
    }

    public String getRoomType() {
        String roomType;
        if (mConferenceState.roomInfo.isSeatEnabled) {
            roomType = mContext.getString(R.string.tuiroomkit_room_raise_hand);
        } else {
            roomType = mContext.getString(R.string.tuiroomkit_room_free_speech);
        }
        return roomType;
    }

    public String getRoomURL() {
        String packageName = mContext.getPackageName();
        if (TextUtils.equals(packageName, "com.tencent.liteav.tuiroom")) {
            return "https://web.sdk.qcloud.com/trtc/webrtc/test/tuiroom-inner/index.html#/room?roomId="
                    + mConferenceState.roomInfo.roomId;
        } else if (TextUtils.equals(packageName, "com.tencent.trtc")) {
            return "https://web.sdk.qcloud.com/component/tuiroom/index.html#/room?roomId=" + mConferenceState.roomInfo.roomId;
        } else {
            return null;
        }
    }

    public boolean needShowRoomLink() {
        String packageName = mContext.getPackageName();
        return TextUtils.equals(packageName, "com.tencent.liteav.tuiroom") || TextUtils.equals(packageName,
                "com.tencent.trtc");
    }

    public void showQRCodeView() {
        Map<String, Object> params = new HashMap<>();
        params.put(ConferenceEventConstant.KEY_ROOM_URL, getRoomURL());
        ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_QRCODE_VIEW, params);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key)
                && params != null && mRoomInfoView.isShowing()) {
            Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
            mRoomInfoView.changeConfiguration(configuration);
        }
    }
}
