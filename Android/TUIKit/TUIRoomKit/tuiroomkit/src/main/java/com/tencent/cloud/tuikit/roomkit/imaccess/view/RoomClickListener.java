package com.tencent.cloud.tuikit.roomkit.imaccess.view;

import com.tencent.cloud.tuikit.roomkit.R;

import com.tencent.cloud.tuikit.roomkit.imaccess.presenter.RoomPresenter;
import com.tencent.cloud.tuikit.roomkit.imaccess.utils.BusinessSceneUtil;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.Map;

public class RoomClickListener extends TUIExtensionEventListener {
    @Override
    public void onClicked(Map<String, Object> param) {
        if (BusinessSceneUtil.canJoinRoom()) {
            RoomPresenter.getInstance().createRoom();
        } else {
            ToastUtil.toastLongMessage(
                    TUILogin.getAppContext().getResources().getString(R.string.tuiroomkit_can_not_join_room_tip));
        }
    }
}
