package com.tencent.cloud.tuikit.roomkit.model;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKitListener;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.service.KeepAliveService;
import com.tencent.cloud.tuikit.roomkit.utils.RoomPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.utils.UserModel;
import com.tencent.cloud.tuikit.roomkit.utils.UserModelManager;
import com.tencent.cloud.tuikit.roomkit.view.activity.PrepareActivity;
import com.tencent.cloud.tuikit.roomkit.view.activity.RoomMainActivity;
import com.tencent.cloud.tuikit.roomkit.view.service.RoomFloatWindowManager;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class TUIRoomKitImpl extends TUIRoomKit implements RoomEngineManager.Listener {
    private static final String TAG = "TUIRoomKitImpl";

    private static TUIRoomKit sInstance;

    private Context                  mContext;
    private List<TUIRoomKitListener> mListenerList;

    private RoomFloatWindowManager mRoomFloatWindowManager;

    public static TUIRoomKit sharedInstance(Context context) {
        if (sInstance == null) {
            synchronized (TUIRoomKitImpl.class) {
                if (sInstance == null) {
                    sInstance = new TUIRoomKitImpl(context);
                }
            }
        }
        return sInstance;
    }

    private TUIRoomKitImpl(Context context) {
        mContext = context.getApplicationContext();
        mListenerList = new ArrayList<>();
        RoomEngineManager.sharedInstance(mContext).setListener(this);
    }

    @Override
    public void setSelfInfo(String userName, String avatarURL) {
        Log.i(TAG, "set self info userName=" + userName + " avatarURL=" + avatarURL);
        RoomEngineManager.sharedInstance(mContext).setSelfInfo(userName, avatarURL);
    }

    @Override
    public void enterPrepareView(boolean enablePreview) {
        Log.i(TAG, "enter prepare view enablePreview=" + enablePreview);
        if (RoomEngineManager.sharedInstance(mContext).getRoomStore().isInFloatWindow()) {
            ToastUtil.toastLongMessage(mContext.getString(R.string.tuiroomkit_room_msg_joined));
            return;
        }
        Intent intent = new Intent(mContext, PrepareActivity.class);
        intent.putExtra(PrepareActivity.INTENT_ENABLE_PREVIEW, enablePreview);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }

    @Override
    public void createRoom(final RoomInfo roomInfo, RoomScene scene) {
        Log.i(TAG, "create room roomInfo=" + roomInfo + " scene=" + scene);
        if (roomInfo == null || TextUtils.isEmpty(roomInfo.roomId)) {
            final List<TUIRoomKitListener> list = copyListener();
            for (TUIRoomKitListener listener : list) {
                listener.onRoomEnter(-1, "roomInfo is empty");
            }
            return;
        }
        RoomEngineManager.sharedInstance(mContext).createRoom(roomInfo, scene);
    }

    @Override
    public void enterRoom(RoomInfo roomInfo) {
        Log.i(TAG, "enter room roomInfo=" + roomInfo);
        if (roomInfo == null || TextUtils.isEmpty(roomInfo.roomId)) {
            final List<TUIRoomKitListener> list = copyListener();
            for (TUIRoomKitListener listener : list) {
                listener.onRoomEnter(-1, "roomInfo or room id is empty");
            }
            return;
        }
        RoomEngineManager.sharedInstance(mContext).enterRoom(roomInfo);
    }

    @Override
    public void addListener(TUIRoomKitListener listener) {
        Log.i(TAG, "add listener : " + listener);
        if (listener != null) {
            mListenerList.add(listener);
        }
    }

    @Override
    public void removeListener(TUIRoomKitListener listener) {
        Log.i(TAG, "remove listener : " + listener);
        if (listener != null) {
            mListenerList.remove(listener);
        }
    }

    @Override
    public void onCreateEngineRoom(int code, String message, RoomInfo roomInfo) {
        Log.i(TAG, "onCreateEngineRoom code=" + code + " message=" + message);
        if (roomInfo == null) {
            Log.e(TAG, "onCreateEngineRoom roomInfo is null");
            notifyCreateRoomResult(code, message);
            return;
        }
        if (TextUtils.isEmpty(roomInfo.roomId)) {
            Log.e(TAG, "onCreateEngineRoom roomId is empty");
            notifyCreateRoomResult(code, message);
            return;
        }
        notifyCreateRoomResult(code, message);
        KeepAliveService.startKeepAliveService(mContext.getString(mContext.getApplicationInfo().labelRes),
                mContext.getString(R.string.tuiroomkit_app_running));
    }

    private void notifyCreateRoomResult(int code, String message) {
        final List<TUIRoomKitListener> list = copyListener();
        for (TUIRoomKitListener listener : list) {
            listener.onRoomCreate(code, message);
        }
    }

    @Override
    public void onEnterEngineRoom(int code, String message, RoomInfo roomInfo) {
        Log.i(TAG, "onEnterEngineRoom code=" + code + " message=" + message);
        if (roomInfo == null) {
            Log.e(TAG, "onEnterEngineRoom roomInfo is null");
            notifyEnterRoomResult(code, message);
            return;
        }
        if (TextUtils.isEmpty(roomInfo.roomId)) {
            Log.e(TAG, "onEnterEngineRoom roomId is empty ");
            notifyEnterRoomResult(code, message);
            return;
        }
        if (code == 0 && RoomEngineManager.sharedInstance(mContext).getRoomStore().isAutoShowRoomMainUi()) {
            goRoomMainActivity();
        }
        UserModelManager.getInstance().getUserModel().userType = UserModel.UserType.ROOM;
        KeepAliveService.startKeepAliveService(mContext.getString(mContext.getApplicationInfo().labelRes),
                mContext.getString(R.string.tuiroomkit_app_running));
        mRoomFloatWindowManager = new RoomFloatWindowManager(mContext);
        decideMediaStatus();
        notifyEnterRoomResult(code, message);
    }

    private void decideMediaStatus() {
        RoomStore roomStore = RoomEngineManager.sharedInstance().getRoomStore();
        if (roomStore.roomInfo.isOpenMicrophone && (roomStore.userModel.role == TUIRoomDefine.Role.ROOM_OWNER
                || !roomStore.roomInfo.isMicrophoneDisableForAllUser)) {
            RoomEngineManager.sharedInstance().openLocalMicrophone(new TUIRoomDefine.ActionCallback() {
                @Override
                public void onSuccess() {
                    decideCameraStatus();
                }

                @Override
                public void onError(TUICommonDefine.Error error, String s) {
                    decideCameraStatus();
                }
            });
        } else {
            decideCameraStatus();
        }
    }

    private void decideCameraStatus() {
        RoomStore roomStore = RoomEngineManager.sharedInstance().getRoomStore();
        if (roomStore.roomInfo.isOpenCamera && (roomStore.userModel.role == TUIRoomDefine.Role.ROOM_OWNER
                || !roomStore.roomInfo.isCameraDisableForAllUser)) {
            RoomEngineManager.sharedInstance().openLocalCamera(null);
        }
    }

    private void notifyEnterRoomResult(int code, String message) {
        final List<TUIRoomKitListener> list = copyListener();
        for (TUIRoomKitListener listener : list) {
            listener.onRoomEnter(code, message);
        }
    }

    private void goRoomMainActivity() {
        Intent intent = new Intent(mContext, RoomMainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }

    @Override
    public void onDestroyEngineRoom() {
        Log.i(TAG, "onDestroyEngineRoom");
        final List<TUIRoomKitListener> list = copyListener();
        for (TUIRoomKitListener listener : list) {
            listener.onDestroyRoom();
        }
        KeepAliveService.stopKeepAliveService();
    }

    @Override
    public void onExitEngineRoom() {
        Log.i(TAG, "onExitEngineRoom");
        final List<TUIRoomKitListener> list = copyListener();
        for (TUIRoomKitListener listener : list) {
            listener.onExitRoom();
        }
        KeepAliveService.stopKeepAliveService();
        mRoomFloatWindowManager.destroy();
        mRoomFloatWindowManager = null;
    }

    private List<TUIRoomKitListener> copyListener() {
        List<TUIRoomKitListener> list = new ArrayList<>();
        for (TUIRoomKitListener item: mListenerList) {
            list.add(item);
        }
        return list;
    }
}
