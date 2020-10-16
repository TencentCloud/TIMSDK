package com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui.widget;


import java.util.List;

/**
 * 视频播放View的管理类
 */
public class VideoViewController {
    private List<LiveVideoView> mVideoViews;
    private LiveVideoView mPKVideoView;

    public VideoViewController(List<LiveVideoView> videoViewList, final LiveVideoView.OnRoomViewListener l) {
        // 连麦拉流
        mVideoViews = videoViewList;
        for (LiveVideoView videoView : mVideoViews) {
            videoView.setOnRoomViewListener(l);
        }
    }

    public synchronized void clearPKView() {
        mPKVideoView = null;
    }

    public synchronized LiveVideoView getPKUserView() {
        if (mPKVideoView != null) {
            return mPKVideoView;
        }
        boolean foundUsed = false;
        for (LiveVideoView item : mVideoViews) {
            if (item.isUsed) {
                foundUsed = true;
                mPKVideoView = item;
                break;
            }
        }
        if (!foundUsed) {
            mPKVideoView = mVideoViews.get(0);
        }
        return mPKVideoView;
    }

    public synchronized boolean containUserId(String id) {
        for (LiveVideoView item : mVideoViews) {
            if (item.isUsed && item.userId.equals(id)) {
                return true;
            }
        }
        return false;
    }

    public synchronized LiveVideoView applyVideoView(String id) {
        if (id == null) {
            return null;
        }

        if (mPKVideoView != null) {
            mPKVideoView.setUsed(true);
            mPKVideoView.showKickoutBtn(false);
            mPKVideoView.userId = id;
            return mPKVideoView;
        }

        for (LiveVideoView item : mVideoViews) {
            if (!item.isUsed) {
                item.setUsed(true);
                item.userId = id;
                return item;
            } else {
                if (item.userId != null && item.userId.equals(id)) {
                    item.setUsed(true);
                    return item;
                }
            }
        }
        return null;
    }

    public synchronized void recycleVideoView(String id) {
        for (LiveVideoView item : mVideoViews) {
            if (item.userId != null && item.userId.equals(id)) {
                item.userId = null;
                item.setUsed(false);
            }
        }
    }

    public synchronized void recycleVideoView() {
        for (LiveVideoView item : mVideoViews) {
            item.userId = null;
            item.setUsed(false);
        }
    }

    public synchronized void showLog(boolean show) {
        for (LiveVideoView item : mVideoViews) {
            if (item.isUsed) {
                item.showLog(show);
            }
        }
    }
}
