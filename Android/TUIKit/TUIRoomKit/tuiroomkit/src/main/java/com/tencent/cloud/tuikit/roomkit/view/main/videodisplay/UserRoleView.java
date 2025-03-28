package com.tencent.cloud.tuikit.roomkit.view.main.videodisplay;

import android.content.Context;
import android.util.AttributeSet;

import androidx.constraintlayout.utils.widget.ImageFilterView;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.trtc.tuikit.common.livedata.LiveData;
import com.trtc.tuikit.common.livedata.Observer;

public class UserRoleView extends ImageFilterView {
    private LiveData<TUIRoomDefine.Role> mRoleData;

    private Observer<TUIRoomDefine.Role> mRoleObserver = this::onUserRoleChanged;

    public UserRoleView(Context context) {
        super(context);
    }

    public UserRoleView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public void onBindToRecyclerView(LiveData<TUIRoomDefine.Role> roleData) {
        mRoleData = roleData;
        mRoleData.observe(mRoleObserver);
    }

    public void onRecycledByRecyclerView() {
        mRoleData.removeObserver(mRoleObserver);
    }

    private void onUserRoleChanged(TUIRoomDefine.Role role) {
        if (role == TUIRoomDefine.Role.GENERAL_USER) {
            setVisibility(GONE);
            return;
        }
        setVisibility(VISIBLE);
        if (role == TUIRoomDefine.Role.MANAGER) {
            setBackgroundResource(R.drawable.tuiroomkit_icon_video_room_manager);
            return;
        }
        setBackgroundResource(R.drawable.tuiroomkit_icon_video_room_owner);
    }
}
