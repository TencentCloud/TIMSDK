package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.Context;
import android.content.Intent;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.utils.RoomPermissionUtil;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserModel;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.utils.IntentUtils;
import com.tencent.cloud.tuikit.roomkit.view.activity.PrepareActivity;
import com.tencent.cloud.tuikit.roomkit.view.component.PrepareView;
import com.tencent.cloud.tuikit.roomkit.view.activity.CreateRoomActivity;
import com.tencent.cloud.tuikit.roomkit.view.activity.EnterRoomActivity;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.trtc.TRTCCloudDef;

import java.util.Locale;


public class PrepareViewModel {
    private Context       mContext;
    private PrepareView   mPrepareView;
    private RoomStore     mRoomStore;
    private RoomInfo      mRoomInfo;
    private TUIRoomEngine mRoomEngine;

    public PrepareViewModel(Context context, PrepareView prepareView) {
        mContext = context;
        mPrepareView = prepareView;
        initRoomStore();
    }

    public UserModel getUserModel() {
        return mRoomStore.userModel;
    }

    public void finishActivity() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.EXIT_PREPARE_ACTIVITY, null);
    }

    public void changeLanguage() {
        boolean isEnglish = Locale.ENGLISH.equals(TUIThemeManager.getInstance().getLocale(mContext));
        String language = isEnglish ? Locale.CHINESE.getLanguage() : Locale.ENGLISH.getLanguage();
        TUIThemeManager.getInstance().changeLanguage(mContext, language);
        Intent intent = new Intent(mContext, PrepareActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        IntentUtils.safeStartActivity(mContext, intent);
    }

    public void setVideoView(TUIVideoView view) {
        mRoomEngine.setLocalVideoView(TUIRoomDefine.VideoStreamType.CAMERA_STREAM, view);
    }

    public void initMicAndCamera() {
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                mPrepareView.updateMicPhoneButton(true);
                mRoomEngine.openLocalMicrophone(TUIRoomDefine.AudioQuality.DEFAULT, null);
                openLocalCamera();
                mRoomInfo.isOpenMicrophone = true;
            }

            @Override
            public void onDenied() {
                mPrepareView.updateMicPhoneButton(false);
                mRoomInfo.isOpenMicrophone = false;

                mPrepareView.updateVideoView(false);
                mRoomInfo.isOpenCamera = false;
            }
        };

        RoomPermissionUtil.requestAudioPermission(mContext, callback);
    }

    public void initRoomStore() {
        RoomEngineManager engineManager = RoomEngineManager.sharedInstance(mContext);
        mRoomEngine = engineManager.getRoomEngine();
        mRoomStore = engineManager.getRoomStore();
        mRoomInfo = mRoomStore.roomInfo;
    }

    public void switchMirrorType() {
        mRoomStore.videoModel.isMirror = !mRoomStore.videoModel.isMirror;
        TRTCCloudDef.TRTCRenderParams param = new TRTCCloudDef.TRTCRenderParams();
        param.mirrorType = mRoomStore.videoModel.isMirror ? TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE
                : TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE;
        mRoomEngine.getTRTCCloud().setLocalRenderParams(param);
    }

    public void switchCamera() {
        mRoomStore.videoModel.isFrontCamera = !mRoomStore.videoModel.isFrontCamera;
        mRoomEngine.getDeviceManager().switchCamera(mRoomStore.videoModel.isFrontCamera);
    }

    public void changeCameraState() {
        mRoomInfo.isOpenCamera = !mRoomInfo.isOpenCamera;
        if (mRoomInfo.isOpenCamera) {
            openLocalCamera();
        } else {
            closeLocalCamera();
        }
        mPrepareView.updateVideoView(mRoomInfo.isOpenCamera);
    }

    public void changeMicrophoneState() {
        mRoomInfo.isOpenMicrophone = !mRoomInfo.isOpenMicrophone;
        if (mRoomInfo.isOpenMicrophone) {
            openLocalMicrophone();
        } else {
            closeLocalMicrophone();
        }
        mPrepareView.updateMicPhoneButton(mRoomInfo.isOpenMicrophone);
    }

    public void closeLocalCamera() {
        mRoomEngine.closeLocalCamera();
    }

    public void closeLocalMicrophone() {
        mRoomEngine.closeLocalMicrophone();
    }

    public void createRoom(Context context) {
        Intent intent = new Intent(context, CreateRoomActivity.class);
        context.startActivity(intent);
    }

    public void enterRoom(Context context) {
        Intent intent = new Intent(context, EnterRoomActivity.class);
        context.startActivity(intent);
    }

    private void openLocalCamera() {
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                mPrepareView.updateVideoView(true);
                mRoomEngine.openLocalCamera(mRoomStore.videoModel.isFrontCamera, TUIRoomDefine.VideoQuality.Q_720P,
                        null);
                mRoomInfo.isOpenCamera = true;
            }

            @Override
            public void onDenied() {
                mPrepareView.updateVideoView(false);
                mRoomInfo.isOpenCamera = false;
            }
        };

        RoomPermissionUtil.requestCameraPermission(mContext, callback);
    }

    private void openLocalMicrophone() {
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                mPrepareView.updateMicPhoneButton(true);
                mRoomEngine.openLocalMicrophone(TUIRoomDefine.AudioQuality.DEFAULT, null);
            }

            @Override
            public void onDenied() {
                mPrepareView.updateMicPhoneButton(false);
            }
        };

        RoomPermissionUtil.requestAudioPermission(mContext, callback);
    }
}
