package com.tencent.cloud.tuikit.roomkit.view.main.videodisplay;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.manager.MediaController;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.List;

public class LiveCameraStreamView extends TUIVideoView {
    private final ConferenceController mController = ConferenceController.sharedInstance();

    private String                        mUserId;
    private TUIRoomDefine.VideoStreamType mStreamType;

    private final List<String> mCameras = mController.getUserState().hasCameraStreamUsers.getList();

    private final LiveListObserver<String> mCameraStreamObserver = new LiveListObserver<String>() {
        @Override
        public void onDataChanged(List<String> list) {
            boolean hasCameraStream = list.contains(mUserId);
            handleCameraStreamChanged(hasCameraStream);
        }

        @Override
        public void onItemInserted(int position, String item) {
            if (!TextUtils.equals(item, mUserId)) {
                return;
            }
            handleCameraStreamChanged(true);
        }

        @Override
        public void onItemRemoved(int position, String item) {
            if (!TextUtils.equals(item, mUserId)) {
                return;
            }
            handleCameraStreamChanged(false);
        }
    };

    public LiveCameraStreamView(Context context) {
        super(context);
    }

    public LiveCameraStreamView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public void onBindToRecyclerView(String userId, int position) {
        mUserId = userId;
        mStreamType = getVideoStreamType(position);
        mController.getUserState().hasCameraStreamUsers.observe(mCameraStreamObserver);
    }

    public void onRecycledByRecyclerView() {
        mController.getUserState().hasCameraStreamUsers.removeObserver(mCameraStreamObserver);
        stopPlayCameraStreamIfNeeded();
    }

    private void stopPlayCameraStreamIfNeeded() {
        if (!mCameras.contains(mUserId)) {
            return;
        }
        mController.getMediaController().stopPlayRemoteVideo(mUserId, mStreamType);
    }

    public TUIRoomDefine.VideoStreamType getVideoStreamType(int position) {
        if (position > 0) {
            return TUIRoomDefine.VideoStreamType.CAMERA_STREAM_LOW;
        }
        if (TextUtils.isEmpty(mController.getUserState().screenStreamUser.get())) {
            return TUIRoomDefine.VideoStreamType.CAMERA_STREAM;
        }
        return TUIRoomDefine.VideoStreamType.SCREEN_STREAM;
    }

    private void handleCameraStreamChanged(boolean hasCameraStream) {
        setVisibility(hasCameraStream ? VISIBLE : INVISIBLE);
        MediaController mediaController = mController.getMediaController();
        if (hasCameraStream) {
            mediaController.startPlayRemoteVideo(mUserId, mStreamType, this);
        } else {
            mediaController.stopPlayRemoteVideo(mUserId, mStreamType);
        }
    }
}
