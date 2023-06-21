package com.tencent.cloud.tuikit.roomkit.model;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.activity.PrepareActivity;
import com.tencent.cloud.tuikit.roomkit.utils.UserModel;
import com.tencent.cloud.tuikit.roomkit.utils.UserModelManager;
import com.tencent.cloud.tuikit.roomkit.view.activity.RoomMainActivity;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKit;
import com.tencent.cloud.tuikit.roomkit.TUIRoomKitListener;

import java.util.ArrayList;
import java.util.List;

public class TUIRoomKitImpl extends TUIRoomKit implements RoomEngineManager.Listener {
    private static final String TAG = "TUIRoomKitImpl";

    private static TUIRoomKit sInstance;

    private Context                  mContext;
    private List<TUIRoomKitListener> mListenerList;

    private boolean mIsBanAutoRaiseUiOnce = false;

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
    public void login(int sdkAppId, String userId, String userSig) {
        RoomEngineManager.sharedInstance(mContext).login(sdkAppId, userId, userSig);
    }

    @Override
    public void logout() {
        mListenerList.clear();
        sInstance = null;
        RoomEngineManager.sharedInstance(mContext).logout();
    }

    @Override
    public void setSelfInfo(String userName, String avatarURL) {
        RoomEngineManager.sharedInstance(mContext).setSelfInfo(userName, avatarURL);
    }

    @Override
    public void enterPrepareView(boolean enablePreview) {
        Intent intent = new Intent(mContext, PrepareActivity.class);
        intent.putExtra(PrepareActivity.INTENT_ENABLE_PREVIEW, enablePreview);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }

    @Override
    public void createRoom(final RoomInfo roomInfo, RoomScene scene) {
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
        if (listener != null) {
            mListenerList.add(listener);
        }
    }

    @Override
    public void removeListener(TUIRoomKitListener listener) {
        if (listener != null) {
            mListenerList.remove(listener);
        }
    }

    @Override
    public void banAutoRaiseUiOnce() {
        mIsBanAutoRaiseUiOnce = true;
    }

    private boolean isBanAutoRaiseUi() {
        if (mIsBanAutoRaiseUiOnce) {
            mIsBanAutoRaiseUiOnce = false;
            return true;
        }
        return false;
    }

    @Override
    public void raiseUi() {
        Intent intent = new Intent(mContext, RoomMainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mContext.startActivity(intent);
    }

    @Override
    public void onLogin(int code, String message) {
        Log.i(TAG, "onLogin: code" + code + " message" + message);
        final List<TUIRoomKitListener> list = copyListener();
        for (TUIRoomKitListener listener : list) {
            listener.onLogin(code, message);
        }
    }

    @Override
    public void onCreateEngineRoom(int code, String message, RoomInfo roomInfo) {
        Log.i(TAG, "onCreateEngineRoom: code" + code + " message" + message);
        if (roomInfo == null) {
            Log.e(TAG, "onCreateEngineRoom: " + "room info is null");
            notifyCreateRoomResult(code, message);
            return;
        }
        if (TextUtils.isEmpty(roomInfo.roomId)) {
            Log.e(TAG, "onCreateEngineRoom: " + "room id is null ");
            notifyCreateRoomResult(code, message);
            return;
        }
        notifyCreateRoomResult(code, message);
    }

    private void notifyCreateRoomResult(int code, String message) {
        final List<TUIRoomKitListener> list = copyListener();
        for (TUIRoomKitListener listener : list) {
            listener.onRoomCreate(code, message);
        }
    }

    @Override
    public void onEnterEngineRoom(int code, String message, RoomInfo roomInfo) {
        Log.i(TAG, "onEnterEngineRoom: code" + code + " message" + message);
        if (roomInfo == null) {
            Log.e(TAG, "onEnterEngineRoom: " + "room info is null");
            notifyEnterRoomResult(code, message);
            return;
        }
        if (TextUtils.isEmpty(roomInfo.roomId)) {
            Log.e(TAG, "onEnterEngineRoom: " + "room id is null ");
            notifyEnterRoomResult(code, message);
            return;
        }
        if (mContext != null && code == 0 && !isBanAutoRaiseUi()) {
            Intent intent = new Intent(mContext, RoomMainActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            mContext.startActivity(intent);
        }
            UserModelManager.getInstance().getUserModel().userType = UserModel.UserType.ROOM;
        notifyEnterRoomResult(code, message);
    }

    private void notifyEnterRoomResult(int code, String message) {
        final List<TUIRoomKitListener> list = copyListener();
        for (TUIRoomKitListener listener : list) {
            listener.onRoomEnter(code, message);
        }
    }

    @Override
    public void onDestroyEngineRoom() {
        final List<TUIRoomKitListener> list = copyListener();
        for (TUIRoomKitListener listener : list) {
            listener.onDestroyRoom();
        }
    }

    @Override
    public void onExitEngineRoom() {
        final List<TUIRoomKitListener> list = copyListener();
        for (TUIRoomKitListener listener : list) {
            listener.onExitRoom();
        }
    }

    private List<TUIRoomKitListener> copyListener() {
        List<TUIRoomKitListener> list = new ArrayList<>();
        for (TUIRoomKitListener item: mListenerList) {
            list.add(item);
        }
        return list;
    }
}
