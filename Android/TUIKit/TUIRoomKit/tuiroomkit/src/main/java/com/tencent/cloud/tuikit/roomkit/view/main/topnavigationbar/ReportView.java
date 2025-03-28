package com.tencent.cloud.tuikit.roomkit.view.main.topnavigationbar;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.common.utils.RTCubeUtils;
import com.tencent.cloud.tuikit.roomkit.state.RoomState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.Observer;

import java.lang.reflect.Method;

public class ReportView extends androidx.appcompat.widget.AppCompatImageView {

    private final Observer<TUIRoomDefine.Role> mRoleObserver = this::updateReportView;

    public ReportView(Context context) {
        this(context, null);
    }

    public ReportView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setOnClickListener(v -> report());
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceController.sharedInstance().getUserState().selfInfo.get().role.observe(mRoleObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getUserState().selfInfo.get().role.removeObserver(mRoleObserver);
    }

    private void updateReportView(TUIRoomDefine.Role role) {
        boolean isGeneralUser = TUIRoomDefine.Role.GENERAL_USER.equals(role);
        boolean isShow = isGeneralUser && RTCubeUtils.isRTCubeApp(getContext());
        setVisibility(isShow ? VISIBLE : GONE);
    }

    private void report() {
        RoomState roomState = ConferenceController.sharedInstance().getRoomState();
        if (TextUtils.isEmpty(roomState.roomId.get())) {
            return;
        }
        try {
            Class clz = Class.forName("com.tencent.liteav.demo.report.ReportDialog");
            Method method = clz.getDeclaredMethod("showReportDialog", Context.class, String.class, String.class);
            method.invoke(null, getContext(), String.valueOf(roomState.roomId.get()), roomState.ownerId.get());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
