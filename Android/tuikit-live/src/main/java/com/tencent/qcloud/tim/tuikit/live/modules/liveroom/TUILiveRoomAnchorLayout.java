package com.tencent.qcloud.tim.tuikit.live.modules.liveroom;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.base.Config;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.model.TRTCLiveRoomDef;
import com.tencent.qcloud.tim.tuikit.live.modules.liveroom.ui.LiveRoomAnchorFragment;

import java.util.List;

/**
 * 实现了直播间的主播端界面
 */
public class TUILiveRoomAnchorLayout extends FrameLayout {
    private TUILiveRoomAnchorLayoutDelegate mLiveRoomAnchorLayoutDelegate;
    private FragmentManager                 mFragmentManager;
    private LiveRoomAnchorFragment          mLiveRoomAnchorFragment;

    public TUILiveRoomAnchorLayout(@NonNull Context context) {
        super(context);
    }

    public TUILiveRoomAnchorLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        inflate(context, R.layout.live_layout_live_room_archor, this);
        mLiveRoomAnchorFragment = new LiveRoomAnchorFragment();
    }

    /**
     * 通过 roomId 初始化主播端
     * @param fragmentManager 用于管理fragment，activity 请通过 getSupportFragmentManager() 传入
     * @param roomId 会以该 roomId 创建直播房间
     */
    public void initWithRoomId(FragmentManager fragmentManager, int roomId) {
        Bundle bundle = new Bundle();
        bundle.putInt("room_id", roomId);
        mLiveRoomAnchorFragment.setArguments(bundle);

        mFragmentManager = fragmentManager;
        mFragmentManager.beginTransaction()
                .add(R.id.live_anchor_container, mLiveRoomAnchorFragment, "tuikit-live-anchor-fragment")
                .commit();
    }

    /**
     * 设置 UI 回调接口
     * @param liveRoomAnchorLayoutDelegate
     */
    public void setLiveRoomAnchorLayoutDelegate(TUILiveRoomAnchorLayoutDelegate liveRoomAnchorLayoutDelegate) {
        mLiveRoomAnchorLayoutDelegate = liveRoomAnchorLayoutDelegate;
        mLiveRoomAnchorFragment.setLiveRoomAnchorLayoutDelegate(mLiveRoomAnchorLayoutDelegate);
    }

    /**
     * 请在 Activity 的 onBackPress 函数中调用该函数，这里会实现界面返回提醒
     */
    public void onBackPress() {
        if (mLiveRoomAnchorFragment != null) {
            mLiveRoomAnchorFragment.onBackPressed();
        }
    }

    /**
     * 调用该接口会强制停止
     */
    public void unInit() {
        if (mLiveRoomAnchorFragment != null) {
            mLiveRoomAnchorFragment.stopLive();
        }
    }

    /**
     * 是否打开PK按钮
     * @param enable true:打开
     */
    public void enablePK(boolean enable){
        Config.setPKButtonStatus(enable);
    }

    public interface TUILiveRoomAnchorLayoutDelegate {
        /**
         * 点击界面中的关闭按钮等会回调该通知，可以在Activity中调用finish方法
         */
        void onClose();

        /**
         *  UI 组件内部产生错误会通过该接口回调出来
         * @param roomInfo 房间信息
         * @param errorCode 错误码
         * @param errorMsg 错误信息
         */
        void onError(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo, int errorCode, String errorMsg);

        /**
         * 房间创建成功后会通过该接口回调出来
         * @param roomInfo 房间信息
         */
        void onRoomCreate(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo);

        /**
         * 房间销毁成功后会通过该接口回调出来
         * @param roomInfo 房间信息
         */
        void onRoomDestroy(TRTCLiveRoomDef.TRTCLiveRoomInfo roomInfo);

        /**
         * 获取PK列表，如果您有PK需求，可以将符合PK的房间列表通过 callback 传入 UI 控件
         * @param callback
         */
        void getRoomPKList(OnRoomListCallback callback);
    }

    public interface OnRoomListCallback {
        /**
         * 获取PK列表成功
         * @param roomIdList 符合PK的房间列表
         */
        void onSuccess(List<String> roomIdList);

        /**
         * 获取PK列表失败
         */
        void onFailed();
    }
}
