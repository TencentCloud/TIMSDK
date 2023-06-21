package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.widget.Toast;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.RoomInfoView;

import java.util.HashMap;
import java.util.Map;

public class RoomInfoViewModel implements RoomEventCenter.RoomKitUIEventResponder {
    //这个提供Web端RoomKit的体验链接，您可以按照自己的业务需求将房间的链接更改，我们会根据此链接为您生成房间二维码
    private static final String URL_ROOM_KIT_WEB = "https://web.sdk.qcloud.com/component/tuiroom/index.html";
    private static final String LABEL            = "Label";

    private Context       mContext;
    private RoomStore     mRoomStore;
    private TUIRoomEngine mRoomEngine;
    private RoomInfoView  mRoomInfoView;

    public RoomInfoViewModel(Context context, RoomInfoView view) {
        mContext = context;
        mRoomInfoView = view;
        mRoomStore = RoomEngineManager.sharedInstance(context).getRoomStore();
        mRoomEngine = RoomEngineManager.sharedInstance(context).getRoomEngine();
        RoomEventCenter.getInstance().subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        RoomEventCenter.getInstance().unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void copyContentToClipboard(String content, String msg) {
        ClipboardManager cm = (ClipboardManager) mContext.getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData mClipData = ClipData.newPlainText(LABEL, content);
        cm.setPrimaryClip(mClipData);
        Toast.makeText(mContext, msg, Toast.LENGTH_SHORT).show();
    }

    public RoomInfo getRoomInfo() {
        return mRoomStore.roomInfo;
    }

    public void setMasterName() {
        mRoomEngine.getUserInfo(mRoomStore.roomInfo.owner, new TUIRoomDefine.GetUserInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.UserInfo userInfo) {
                String name = TextUtils.isEmpty(userInfo.userName) ? userInfo.userId : userInfo.userName;
                mRoomInfoView.setMasterName(name);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String s) {
                mRoomInfoView.setMasterName(mRoomStore.roomInfo.owner);
            }
        });
    }

    public String getRoomType() {
        String roomType;
        if (TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT.equals(mRoomStore.roomInfo.speechMode)) {
            roomType = mContext.getString(R.string.tuiroomkit_room_raise_hand);
        } else {
            roomType = mContext.getString(R.string.tuiroomkit_room_free_speech);
        }
        return roomType;
    }

    public String getRoomURL() {
        return mContext.getString(R.string.tuiroomkit_room_link_params,
                URL_ROOM_KIT_WEB,
                mRoomStore.roomInfo.roomId);
    }

    public void showQRCodeView() {
        Map<String, Object> params = new HashMap<>();
        params.put(RoomEventConstant.KEY_ROOM_URL, getRoomURL());
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_QRCODE_VIEW, params);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE.equals(key)
                && params != null && mRoomInfoView.isShowing()) {
            Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
            mRoomInfoView.changeConfiguration(configuration);
        }
    }
}
